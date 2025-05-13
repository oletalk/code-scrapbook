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
  # see https://github.com/gma/nesta/issues/203 (Sinatra now requires Host Authorization - breaks prod deployments otherwise)
  # mine is what i've configured X-Forwarded-For header on my reverse proxy
  set :host_authorization, { permitted_hosts: ["vega"] }
  # TODO: -
  # 1. introduce ERBs including login screen
  # 2. include code to check sessions in login screens

  def initialize
    @users = PwCrypt.new('./config/pw.txt')
    logger.info 'loaded users'
    @songcache = FileCache.new
    @allow_listen = {}
    @testip = {}
    @currently = NowPlaying.new
    super
  end

  before do
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Accept, Authorization, Origin'
    content_type 'text/plain'
  end

  # PLAY STREAM (main)
  get '/member/play/:hsh' do |hsh|
    # @user = current_user # SESSIONS BROKEN IN HTTPS 15/02/2025

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
        @currently.start(song, request.ip, 'anonymous')
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
      session[:username] = params['username']
      puts 'session username is'
      puts session[:username]
      logger.info "login succeeded for user #{params['username']}"
      @testip[:username] = params['username']
      redirect '/main'
    else
      @error = 'User name or password is incorrect.'
      logger.error "login failure for user #{params['username']}"
      content_type 'text/html'
      erb :signin
    end
  end

  run! if app_file == $PROGRAM_NAME
end
