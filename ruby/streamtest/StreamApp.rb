require 'sinatra/base'
require_relative 'util/config'
require_relative 'util/db'
require_relative 'util/player'
require_relative 'text/format'
require_relative 'util/ipwl'
require_relative 'util/logging'

class StreamApp < Sinatra::Base
    set :bind, MP3S::Config::SERVER_HOST
    set :port, MP3S::Config::SERVER_PORT
    set :sessions, true

    $ipwl = IPWhitelist.new(MP3S::Clients::List, MP3S::Clients::Default)

    get '/play/:hash' do |req_hash|
        # go find the song with this hash - see _pgtest.rb
        song_loc = Db.find_song(req_hash)

        # TODO: might want to invoke this check in some sort of area common to ALL requests?
        remote_ip = request.env['REMOTE_ADDR']
        action = $ipwl.action(remote_ip)
        Log.log.info("Action for #{remote_ip} is #{action}.")

        # stream song in output to client
        Log.log.info("Song '#{song_loc}' (#{req_hash}) requested")
        if song_loc.nil?
            "404 Sorry, that song was not found"
        elsif !action[:allow]
            "403 Access denied"
        else
            response.headers['Cache-Control'] = 'no-cache'

            # how should we play this song? if client list says downsample, do it
            command = Player.get_command(action[:downsample], song_loc)
            Log.log.info("Fetched command template, #{command}")

            $stdout.sync = true
            played = Player.play_song(command, song_loc)
            warnings = played[:warnings]
            Log.log.warn(warnings) unless (warnings.nil? or warnings == '')
            played[:songdata]
        end
    end

#          'Cache-Control' => 'no-cache ',
#               'Pragma' => 'no-cache ',

    get '/json/:spec' do
        # json format for fetching list from js front end
        spec = params['spec']
        if spec == 'all'
            spec = ''
        end
        song_list = Db.list_songs("#{MP3S::Config::MP3_ROOT}/#{spec}")
        Format.json_list(song_list)
    end

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

    run! if app_file == $0
end
