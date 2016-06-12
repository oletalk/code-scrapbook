require 'sinatra'
require 'logger'
require_relative 'util/config'
require_relative 'util/db'
require_relative 'util/player'
require_relative 'text/format'
require_relative 'util/ipwl'

configure do
    set :bind, MP3S::Config::SERVER_HOST
    set :port, MP3S::Config::SERVER_PORT

    $logger = Logger.new(STDOUT) # non production
    $logger.level = Logger::INFO

    $ipwl = IPWhitelist.new(MP3S::Clients::List, MP3S::Clients::Default)
end

get '/' do
    'Hello world'
end

get '/play/:hash' do |req_hash|
    # go find the song with this hash - see _pgtest.rb
    song_loc = Db.find_song(req_hash)

    # TODO: might want to invoke this check in some sort of area common to ALL requests?
    remote_ip = request.env['REMOTE_ADDR']
    action = $ipwl.action(remote_ip)
    $logger.info("Action for #{remote_ip} is #{action}.")

    # stream song in output to client
    $logger.info("Song '#{song_loc}' (#{req_hash}) requested")
    if song_loc.nil?
        "404 Sorry, that song was not found"
    elsif !action[:allow]
        "403 Access denied"
    else
        response.headers['Cache-Control'] = 'no-cache'

        # how should we play this song? if client list says downsample, do it
        command = Player.get_command(action[:downsample], song_loc)
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
    if spec == 'all'
        spec = ''
    end
    song_list = Db.list_songs("#{MP3S::Config::MP3_ROOT}/#{spec}")
    Format.html_list(song_list)
end

get '/m3u/:spec' do
    # list all the mp3s in the system which match the given spec
    # basically MP3S_ROOT/{foo}
    spec = params['spec']
    if spec == 'all'
        spec = ''
    end
    song_list = Db.list_songs("#{MP3S::Config::MP3_ROOT}/#{spec}")
    response.headers['Content-Type'] = 'text/plain'
    Format.play_list(song_list, request.env['HTTP_HOST'])
end

