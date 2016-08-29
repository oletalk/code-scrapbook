require 'sinatra/base'
require 'warden'
require_relative 'util/config'
require_relative 'util/db'
require_relative 'util/player'
require_relative 'text/format'
require_relative 'util/ipwl'
require_relative 'util/logging'

class StreamApp < Sinatra::Base
    set :bind, MP3S::Config::SERVER_HOST
    set :port, MP3S::Config::SERVER_PORT
    enable :sessions

    use Rack::Session::Cookie, :secret => MP3S::Config::RSC

    use Warden::Manager do |config|
        config.serialize_into_session{|user| user.username }
        config.serialize_from_session{|username| Db.new.find_user(username) }

        config.scope_defaults :default,
        strategies: [:password]
        config.failure_app = self
    end

    Warden::Manager.before_failure do |env, opts|
        # without this we keep getting env['warden'] = nil :-(
        env['REQUEST_METHOD'] = 'POST'
    end

    Warden::Strategies.add(:password) do
        def valid?
            puts 'password strategy valid?'
            user = params["user"]
            user and user != ''
        end

        def authenticate!
            puts 'password strategy authenticate'
            user = params["user"]
            password = params["pass"]
            x = Db.new.authenticate_user(user, password)
            if x != nil
                Log.log.info("authentication succeeded for user #{user}")
                success!(x)
            else
                Log.log.error("authentication failed for user #{user}")
                fail!('could not login')
            end
        end
    end

	before do
		@ipwl = IPWhitelist.new(MP3S::Clients::List, MP3S::Clients::Default)
		@db   = Db.new
		@player = Player.new
	end

    get '/play/:hash' do |req_hash|
        # go find the song with this hash - see _pgtest.rb
        song_loc = @db.find_song(req_hash)

        # TODO: might want to invoke this check in some sort of area common to ALL requests?
        remote_ip = request.env['REMOTE_ADDR']
        action = @ipwl.action(remote_ip)
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
            command = @player.get_command(action[:downsample], song_loc)
            Log.log.info("Fetched command template, #{command}")

            $stdout.sync = true
            played = @player.play_song(command, song_loc)
            warnings = played[:warnings]
            Log.log.warn(warnings) unless (warnings.nil? or warnings == '')
            played[:songdata]
        end
    end

#          'Cache-Control' => 'no-cache ',
#               'Pragma' => 'no-cache ',

    get '/list/:spec' do
        Log.log.info("Fetching list off " + params['spec'] + " for user " + env['warden'].user.username)
        # list all the mp3s in the system which match the given spec
        # basically MP3S_ROOT/{foo}
        spec = params['spec']
        if spec == 'all'
            spec = ''
        end
        song_list = @db.list_songs("#{MP3S::Config::MP3_ROOT}/#{spec}")
        Format.html_list(song_list)
    end

    get '/m3u/:spec' do
        # list all the mp3s in the system which match the given spec
        # basically MP3S_ROOT/{foo}
        spec = params['spec']
        if spec == 'all'
            spec = ''
        end
        song_list = @db.list_songs("#{MP3S::Config::MP3_ROOT}/#{spec}")
        response.headers['Content-Type'] = 'text/plain'
        Format.play_list(song_list, request.env['HTTP_HOST'])
    end

# authentication
    post '/protectedtest/?' do
        env['warden'].authenticate!(:password) # looks like i actually have to specify the strategy
   
    #current_user = env['warden'].user 
        username = env['warden'].user.username
        erb :createpls, :locals => {:name => username }
        # TODO XHRs are not secured until i figure out how to forward on credentials to them...
    end

    post '/unauthenticated' do
        '<b>Login failed.</b><br/>Please <a href="login.html">try again</a>'
    end

    # erb test
    get '/test1' do
        erb :test1
    end

# NOTE these last two methods only deal in JSON
    get '/json/:spec' do
        Log.log.info("Fetching json list off " + params['spec'] )
        # json format for fetching list from js front end
        spec = params['spec']
        if spec == 'all'
            spec = ''
        end
        song_list = @db.list_songs("#{MP3S::Config::MP3_ROOT}/#{spec}")
        Format.json_list(song_list)
    end

    # TODO: update your songlist (given that you are the owner)

    get '/playlist_json/:name' do
        name = params['name']
        song_list = @db.fetch_playlist(name)
        if song_list.size > 0
            Format.json_list(song_list)
        else
            '{ "error" : "That playlist was not found" }'
        end
    end

    get '/json_lists_for/:owner' do
        owner = params['owner']
        lists = @db.list_songlists_for(owner)
        Format.json(lists)
    end

    get '/playlist_m3u/:name' do
        # list mp3s tied to a given playlist
        name = params['name']
        song_list = @db.fetch_playlist(name)
        response.headers['Content-Type'] = 'text/plain'
        if song_list.size > 0
            Format.play_list(song_list, request.env['HTTP_HOST'])
        else
            '404 Not Found'
        end
    end

    post '/songlist' do
        data = JSON.parse(request.body.read.to_s)
        listname = data['listname']
        listcontent = data['listcontent'] # json within json
        listowner = data['listowner']
        Log.log.info("listname = #{listname}, listcontent = #{listcontent}, listowner = #{listowner}")
        # save these off to some song list structure in the db
        Log.log.info("Number of songs in list: #{listcontent.size}")

        ret = nil
        begin
            plschk = @db.check_owner_is(listname, listowner)
            if (plschk != false)
                ret = @db.save_songlist(listname, listcontent, listowner, plschk.nil?)
                if plschk.nil?
                    Log.log.info("Saved playlist!")
                else
                    Log.log.info("Updated playlist!")
                end
            else
                ret = Format.json({error: "Playlist exists and you are not the owner"})
            end
        rescue PlaylistCreationError => msg
            ret = Format.json({error: msg})
        end
        ret
    end
    run! if app_file == $0
end
