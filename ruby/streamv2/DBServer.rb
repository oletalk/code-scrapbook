require 'sinatra/base'
require 'jwt'
require 'cgi'
require_relative 'util/config'
require_relative 'util/db'
require_relative 'util/player'
require_relative 'util/logging'
require_relative 'text/format'

# this server should not be publicly accessible
class DBServer < Sinatra::Base
  set :bind, MP3S::Config::DB::SERVER_HOST
  set :port, MP3S::Config::DB::SERVER_PORT
  enable :dump_errors

  # init stuff
  configure do
    @@streamserver = nil
  end

  before do
    @db   = Db.new
    @player = Player.new
    Log.init( MP3S::Config::Misc::DB_LOGFILE )
    @remote_ip = request.env['REMOTE_ADDR']
    if @remote_ip != @@streamserver
      pass if request.path_info.start_with? '/pass/'

      puts 'Remote IP mismatch! Denying request.'
      Log.log.error "Remote IP not streamserver! #@remote_ip"
      halt
    end
  end

  get '/pass/:jwt' do |token|
    hmac_secret = ENV.fetch('HMAC_SECRET')
    begin
      if @@streamserver.nil?
        Log.log.info "Stream server connected from #@remote_ip"
      else
        Log.log.error "Extraneous connection from #@remote_ip"
        halt 401, 'Stream server is already connected elsewhere :-P'
      end

      decoded_token = JWT.decode token, hmac_secret, true, { algorithm: 'HS256' }
      pass = decoded_token[0]['data']
      if pass == MP3S::Config::Misc::SHARED_SECRET
        puts 'Shared secret is OK!'
        Log.log.info "Stream server successfully verified from #@remote_ip"
        @@streamserver = @remote_ip #TODO something else?
     end
      'OK'
    rescue JWT::VerificationError
      Log.log.error "Verification from #@remote_ip failed"
      'FAIL'
    end
  end

  get '/list/:spec' do |req_spec|
    if req_spec == 'all'
      req_spec = ''
    end
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

  get '/playlist/:id' do |id|
    x = @db.fetch_playlist(id)
    Format.json(x)
  end

  get '/playlist/:id/del' do |id|
    @db.delete_playlist(id)
    'Delete complete'
  end

  get '/playlist/new' do
    res = @db.get_new_playlist_id
    res
  end

  post '/playlist/save' do
    p_id = params['pid']
    p_name = params['pname']
    playlist_songids = params['songids']
    puts 'songids: ' + playlist_songids
    a_songs = playlist_songids.split(',')
    @db.save_playlist(p_id, p_name, a_songs)
    'Save complete'
  end

  get '/playlists' do
    @db.fetch_playlists
    Format.json(@db.fetch_playlists)
  end

  get '/search/:name' do |name|
    song_list = @db.fetch_search(CGI::unescape(name))
    if song_list.size > 0
      puts song_list
      Format.json(song_list)
    else
      '{ "error" : "That playlist was not found" }'
    end
  end

  get '/search/m3u/:name' do |name|
    song_list = @db.fetch_search(CGI::unescape(name))
    if song_list.size > 0
      Format.play_list(song_list, request.env['HTTP_HOST'])
    else
      '{ "error" : "That playlist was not found" }'
    end
  end

  helpers do
    def process_songdata(req_hash, req_downsample=false)
      songdata = @db.find_song(req_hash)
      # NOTE! This result is an array (albeit of one)
      if songdata.nil?
        "404 Sorry, that song was not found"
      else
        songrow = songdata[0]
        song_loc = songrow[:song_filepath]
        song_artist = songrow[:artist]
        song_title = songrow[:title]

        Log.log.info("Song '#{song_loc}' (#{req_hash}) requested")

        # record stats
        # $stdout.sync = true
        @db.record_stat('SONG', song_loc)
        @db.record_stat('ARTIST', song_artist)
        @db.record_stat('TITLE', song_title)
        songresponse(req_hash, song_loc, req_downsample)
      end
    end

    def songresponse(req_hash, song_loc, downsample=false )

          # play it (stream server will be calling this method)
          command = @player.get_command(downsample, song_loc)
          Log.log.info("Fetched command template, #{command}")

          # $stdout.sync = true
          played = @player.play_song(command, song_loc)
          puts "songdata length: #{played[:songdata].length}"
          warnings = played[:warnings]
          Log.log.warn(warnings) unless (warnings.nil? or warnings == '')
          played[:songdata]
    end
  end

  run! if app_file == $0
end
