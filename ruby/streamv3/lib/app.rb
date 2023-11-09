# frozen_string_literal: true

require_relative 'db/listgen'
require_relative 'db/playlistgen'
require_relative 'util/crypt'
require_relative 'db/hashsong'
require_relative 'stream/stream'
require_relative 'util/filecache'
require_relative 'common/logging'
require_relative 'stream/nowplaying'
require_relative 'db/generalstats'

require 'sinatra/base'
require 'sinatra/streaming' # so we can use 'stream do'

# lg = ListGen.new
# puts lg.fetch_playlist('programming')

# main app to take requests for playlists and songs from clients
class StreamServer < Sinatra::Base
  include Logging
  helpers Sinatra::Streaming
  enable :dump_errors
  enable :sessions
  # TODO: -
  # 1. introduce ERBs including login screen
  # 2. include code to check sessions in login screens

  def initialize
    @users = PwCrypt.new('./config/pw.txt')
    logger.info 'loaded users'
    @songcache = FileCache.new
    @allow_listen = {}
    @currently = NowPlaying.new
    super
  end

  before '/member/*' do
    req_ip = request.ip
    @allowed = @allow_listen.key?(req_ip)
    allow_desc = @allowed ? 'allowed' : 'not allowed'
    logger.info "Request for #{request.path_info} from #{req_ip} is currently #{allow_desc}."
    halt 403, 'Access Denied' unless @allowed

    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Accept, Authorization, Origin'
    content_type 'text/plain'
  end

  before do
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Accept, Authorization, Origin'
    content_type 'text/plain'
  end

  # PLAY STREAM (main)
  get '/member/play/:hsh' do |hsh|
    @user = current_user

    stream do |out|
      # find file containing that hash
      song = HashSong.new(hash: hsh.to_s)

      # if it exists, stream it back
      if song.found
        # 1/8/2023 TODO call song.record_stat ... but when??
        logger.debug "Streaming #{song.song_filepath}"
        st = SongStream.new(song.song_filepath.to_s)
        out.puts st.readall(@songcache)
        out.flush
        @currently.start(song, request.ip, @user)
      else
        logger.error 'Invalid hash!'
      end
    end
  end

  # PLAYLISTS (JSON)
  get '/member/playlists' do
    plg = PlaylistGen.new(hostheader: request.env['HTTP_HOST'])
    plg.fetch_all_playlists
  end

  get '/member/playlist/:name' do |name|
    plg = PlaylistGen.new(hostheader: request.env['HTTP_HOST'])
    plg.fetch_tunes(name: name)
  end

  get '/member/search/:spec' do |spec|
    plg = PlaylistGen.new(hostheader: request.env['HTTP_HOST'])
    plg.search_playlists(spec: spec.downcase)
  end

  # PLAYLISTS (M3U)
  get '/member/m3u/all' do
    lg = ListGen.new(hostheader: request.env['HTTP_HOST'])
    lg.fetch_all_tunes
  end

  get '/member/m3u/:name' do |name|
    lg = ListGen.new(hostheader: request.env['HTTP_HOST'])
    lg.fetch_playlist(name: name)
  end

  # USER SCREENS
  get '/signin' do
    content_type 'text/html'
    erb :signin
  end

  post '/sign_in' do
    if @users.test_password(params['username'], params['password'])
      session['username'] = params['username']
      logger.info "login succeeded for user #{params['username']}"
      redirect '/main'
    else
      @error = 'User name or password is incorrect.'
      logger.error "login failure for user #{params['username']}"
      content_type 'text/html'
      erb :signin
    end
  end

  get '/allow_listen/:ip' do |ip|
    @user = current_user
    if @user
      logger.info "request to allow listening from #{ip}"
      # add the ip into a whitelist
      @allow_listen[ip] = 1
      'OK, you are allowed - urls under /member'
    else
      halt 403, 'Access Denied'
    end
  end

  get '/main' do
    content_type 'text/html'
    @user = current_user

    if @user
      @curr_ip = request.ip
      @allowed = @allow_listen.key?(@curr_ip)
      @nowplaying = @currently.playing(@curr_ip)
      # run general stats as well
      # is there a better way not to run stats every time this page is called?
      stats = GeneralStats.new
      @top_artists = stats.playing_stats

      erb :main
    else
      @error = 'Please sign in first'
      erb :signin
    end
  end

  helpers do
    def current_user
      if session['username']
        @users.user_info(session['username'])
      else
        logger.info 'sorry, no session...'
        false
      end
    end
  end

  run! if app_file == $PROGRAM_NAME
end
