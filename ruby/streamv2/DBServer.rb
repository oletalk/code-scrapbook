# frozen_string_literal: true

require 'sinatra/base'
require 'cgi'
require_relative 'common/util/config'
require_relative 'dbserver/util/db'
require_relative 'dbserver/util/player'
require_relative 'common/util/logging'
require_relative 'common/text/manip'
require_relative 'common/text/format'
# require_relative 'common/comms/connector'
require_relative 'common/comms/connected'
require_relative 'dbserver/data/song'

# this server should not be publicly accessible
class DBServer < Sinatra::Base
  include Connected

  set :bind, MP3S::Config::DB::SERVER_HOST
  set :port, MP3S::Config::DB::SERVER_PORT
  enable :dump_errors

  before do
    @db = Db.new
    @player = Player.new
    Log.init(MP3S::Config::Misc::DB_LOGFILE)

    halt unless allowed(request)
  end

  get '/pass/:jwt' do |token|
    set_streamserver?(request, token) ? 'OK' : 'FAIL'
  end

  get '/list/:spec' do |req_spec|
    req_spec = '' if req_spec == 'all'
    song_list = @db.list_songs("#{MP3S::Config::Net::MP3_ROOT}/#{req_spec}")
    Format.play_list(song_list, request.env['HTTP_HOST'])
  end

  get '/playlist/m3u/:name' do |pls_name|
    x = @db.fetch_playlist(pls_name, by: 'name')
    Format.play_list(x, request.env['HTTP_HOST'])
  end

  get '/play/:hash' do |req_hash|
    # locate hash in db
    $stdout.sync = true
    process_songdata(req_hash)
  end

  get '/play/:hash/downsampled' do |req_hash|
    # locate hash in db
    $stdout.sync = true
    process_songdata(req_hash, true)
  end

  # this needs to be BEFORE the other /playlist routes
  # so 'new' gets picked up here rather than below and passed as an id
  get '/playlist/new' do
    res = @db.get_new_playlist_id
    res.to_s
  end

  get '/playlist/:id' do |id|
    x = @db.fetch_playlist(id)
    Format.json(x)
  end

  get '/playlist/:id/del' do |id|
    @db.delete_playlist(id)
    'Delete complete'
  end

  post '/playlist/save' do
    p_id = params['pid']
    p_name = params['pname']
    playlist_songids = params['songids']
    # puts 'songids: ' + playlist_songids
    a_songs = playlist_songids.split(',')
    @db.save_playlist(p_id, p_name, a_songs)
    'Save complete'
  end

  get '/playlists' do
    # db.fetch_playlists
    song_list = @db.fetch_playlists
    if song_list.size.positive?
      song_list.each do |row|
        lp = row[:modified]
        row[:modified] = Manip.timestamp_from_db(lp) unless lp.nil?
      end
    end
    Format.json(song_list)
  end

  get '/info/:hash' do |hash|
    info = @db.get_info_json(hash)
    info.each do |row|
      row[:last_played] = Manip.date_from_db(row[:last_played])
    end
    Format.json(info)
  end

  get '/query/latest' do
    song_list = @db.fetch_latest_tags
    song_list.each do |row|
      row[:date_added] = Manip.date_from_db(row[:date_added])
    end

    Format.json(song_list)
  end

  get '/query/random/:number' do |number|
    song_list = @db.fetch_all_tags
    num = number.to_i
    num = song_list.size if num > song_list.size
    ret = []
    num.times do
      randomrow = song_list.delete(song_list[Random.rand(song_list.size)])
      da = randomrow[:date_added]
      randomrow[:date_added] = Manip.date_from_db(da) unless da.nil?
      ret.push(randomrow)
    end
    Format.json(ret)
  end

  get '/search/:name' do |name|
    song_list = @db.fetch_search(CGI.unescape(name))
    if song_list.size.positive?
      song_list.each do |row|
        lp = row[:last_played]
        da = row[:date_added]
        row[:date_added] = Manip.date_from_db(da) unless da.nil?
        row[:last_played] = Manip.timestamp_from_db(lp) unless lp.nil?
      end
      Format.json(song_list)
    else
      '{ "error" : "That playlist was not found" }'
    end
  end

  get '/search/m3u/:name' do |name|
    song_list = @db.fetch_search(CGI.unescape(name))
    if song_list.size.positive?
      Format.play_list(song_list, request.env['HTTP_HOST'])
    else
      '{ "error" : "That playlist was not found" }'
    end
  end

  get '/tag/:hash' do |hash|
    tag_info = @db.get_tag_info(hash)
    Format.json(tag_info)
  end

  #      artist: tag_artist, title: tag_title, hash: tag_hash, playlist: playlist_id
  post '/tag/save' do
    t_artist = params['artist']
    t_title = params['title']
    t_hash = params['hash']

    @db.save_tag(t_artist, t_title, t_hash)
    'Save complete'
  end

  helpers do
    def process_songdata(req_hash, req_downsample=false)
      songdata = @db.find_song(req_hash)
      # NOTE! This result is an array (albeit of one)
      if songdata.nil?
        '404 Sorry, that song was not found'
      else
        songrow = Song.new(songdata[0])
        #     see the mapping in data/song.rb

        Log.log.info("Song '#{songrow.location}' (#{req_hash}) requested")

        # record stats
        # $stdout.sync = true
        @db.record_stat('SONG', songrow.location)
        @db.record_stat('ARTIST', songrow.artist)
        @db.record_stat('TITLE', songrow.title)
        @player.songresponse(req_hash, songrow.location, req_downsample)
      end
    end

    def self.set_hmac_secret(hmsecret)
      @@connector.set_hmac_secret(hmsecret)
    end
  end

  run! if app_file == $PROGRAM_NAME
end
