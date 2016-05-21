require 'sinatra'
require 'logger'
require_relative 'util/config'
require_relative 'util/db'

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
    # probably put this in a db utility file - getFileForHash?
    song_loc = find_song(req_hash)

    # stream song in output to client
    $logger.info("Song '#{song_loc}' (#{req_hash}) requested")
    if song_loc.nil?
        "Sorry, that song was not found"
    else
        "You want song #{song_loc}"
    end
end

get '/list/:spec' do
    # list all the mp3s in the system which match the given spec
end
