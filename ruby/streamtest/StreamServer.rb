require 'sinatra'
require 'logger'
require_relative 'util/config'
require_relative 'util/db'
require_relative 'text/format'

configure do
    set :bind, MP3S::Config::SERVER_HOST
    set :port, MP3S::Config::SERVER_PORT
   #set :public_folder, MP3S::Config::WEB_ROOT

    $logger = Logger.new(STDOUT) # non production
    $logger.level = Logger::INFO
end

get '/' do
    'Hello world'
end

get '/play/:hash' do |req_hash|
    # go find the song with this hash - see _pgtest.rb
    song_loc = find_song(req_hash)

    # stream song in output to client
    $logger.info("Song '#{song_loc}' (#{req_hash}) requested")
    if song_loc.nil?
        "404 Sorry, that song was not found"
    else
        response.headers['Cache-Control'] = 'no-cache'
        send_file song_loc, :type => 'audio/x-mp3stream', :disposition => 'inline'
    end
end

#          'Cache-Control' => 'no-cache ',
#               'Pragma' => 'no-cache ',


get '/list/:spec' do
    # list all the mp3s in the system which match the given spec
    # basically MP3S_ROOT/{foo}
    spec = params['spec']
    "You want all the songs under the top level folder#{spec}!"
    song_list = list_songs("#{MP3S::Config::MP3_ROOT}/#{spec}")
    html_list(song_list)
end

get '/m3u/:spec' do
    # list all the mp3s in the system which match the given spec
    # basically MP3S_ROOT/{foo}
    spec = params['spec']
    "You want all the songs under the top level folder#{spec}!"
    song_list = list_songs("#{MP3S::Config::MP3_ROOT}/#{spec}")
    response.headers['Content-Type'] = 'text/plain'
    play_list(song_list, request.env['HTTP_HOST'])
end

