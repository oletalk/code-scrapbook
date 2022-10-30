# frozen_string_literal: true

require_relative 'db/listgen'
require_relative 'util/crypt'
require 'sinatra/base'

# lg = ListGen.new
# puts lg.fetch_playlist('programming')

# main app to take requests for playlists and songs from clients
class StreamServer < Sinatra::Base
  enable :dump_errors
  enable :sessions
  # TODO: -
  # 1. introduce ERBs including login screen
  # 2. include code to check sessions in login screens

  def initialize
    @users = PwCrypt.new('./config/pw.txt')
    puts 'loaded users'
    super
  end

  # initialising
  # configure do
  # end

  before do
    content_type 'text/plain'
  end

  # PLAYLISTS (JSON)
  get '/playlists' do
    plg = PlaylistGen.new(hostheader: request.env['HTTP_HOST'])
    plg.fetch_all_playlists
  end

  get '/playlist/:name' do |name|
    plg = PlaylistGen.new(hostheader: request.env['HTTP_HOST'])
    plg.fetch_tunes(name: name)
  end

  # PLAYLISTS (M3U)
  get '/m3u/all' do
    lg = ListGen.new(hostheader: request.env['HTTP_HOST'])
    lg.fetch_all
  end

  get '/m3u/:name' do |name|
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
      puts "login succeeded for user #{params['username']}"
      redirect '/main'
    else
      @error = 'User name or password is incorrect.'
      puts "login failure for user #{params['username']}"
      content_type 'text/html'
      erb :signin
    end
  end

  get '/main' do
    content_type 'text/html'
    @user = current_user

    if @user
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
        puts 'sorry, no session...'
      end
    end
  end

  run! if app_file == $PROGRAM_NAME
end
