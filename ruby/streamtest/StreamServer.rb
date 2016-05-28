require 'sinatra'
require 'logger'
require_relative 'util/config'
require_relative 'util/db'
require_relative 'util/player'
require_relative 'text/format'

configure do
    set :bind, MP3S::Config::SERVER_HOST
    set :port, MP3S::Config::SERVER_PORT

    $logger = Logger.new(STDOUT) # non production
    $logger.level = Logger::INFO
end

get '/' do
    'Hello world'
end

get '/play/:hash' do |req_hash|
    # go find the song with this hash - see _pgtest.rb
    song_loc = Db.find_song(req_hash)

    # stream song in output to client
    $logger.info("Song '#{song_loc}' (#{req_hash}) requested")
    if song_loc.nil?
        "404 Sorry, that song was not found"
    else
        response.headers['Cache-Control'] = 'no-cache'

        # if downsampling - PLAY_DOWNSAMPLED_MP3
        command = MP3S::Config::PLAY_RAW
        #command = MP3S::Config::PLAY_DOWNSAMPLED_MP3
        $logger.info("Fetched command template, #{command}")

        played = Player.play_song(command, song_loc)
        warnings = played[:warnings]
        $logger.warn(warnings) unless warnings.nil?
        played[:songdata]
    end
end

#          'Cache-Control' => 'no-cache ',
#               'Pragma' => 'no-cache ',


get '/list/:spec' do
    # list all the mp3s in the system which match the given spec
    # basically MP3S_ROOT/{foo}
    spec = params['spec']
    "You want all the songs under the top level folder#{spec}!"
    song_list = Db.list_songs("#{MP3S::Config::MP3_ROOT}/#{spec}")
    Format.html_list(song_list)
end

get '/m3u/:spec' do
    # list all the mp3s in the system which match the given spec
    # basically MP3S_ROOT/{foo}
    spec = params['spec']
    song_list = Db.list_songs("#{MP3S::Config::MP3_ROOT}/#{spec}")
    response.headers['Content-Type'] = 'text/plain'
    Format.play_list(song_list, request.env['HTTP_HOST'])
end

