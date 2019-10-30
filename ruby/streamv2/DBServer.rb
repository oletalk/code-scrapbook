require 'sinatra/base'
require_relative 'util/config'
require_relative 'util/db'
require_relative 'util/player'
require_relative 'util/logging'

# this server should not be publicly accessible
class DBServer < Sinatra::Base
  set :bind, MP3S::Config::DB_SERVER_HOST
  set :port, MP3S::Config::DB_SERVER_PORT
  enable :sessions
  enable :logging
  enable :dump_errors
  
  # init stuff
  before do
    @db   = Db.new
    @player = Player.new
    
  end
  
  
  get '/play/:hash' do |req_hash|
    # locate hash in db
    songdata = @db.find_song(req_hash)
    if songdata.nil?
      "404 Sorry, that song was not found"
    else
      song_loc = songdata[:song_filepath]
  
      Log.log.info("Song '#{song_loc}' (#{req_hash}) requested")

      do_downsample = request.env['downsample']
      Log.log.info("Downsample info from the request: #{do_downsample}")
      if (do_downsample)
        Log.log.error("Action for client is to downsample but it is asking for raw file")
        "403 Forbidden"
      else
        # play it (stream server will be calling this method)
        command = @player.get_command(do_downsample, song_loc)
        Log.log.info("Fetched command template, #{command}")
        
        $stdout.sync = true
        played = @player.play_song(command, song_loc)
        warnings = played[:warnings]
        Log.log warn(warnings) unless (warnings.nil? or warnings == '')
        # TODO record stats
        played[:songdata]
      end


    end
  
  end
  
  get '/play/:hash/downsampled' do |req_hash|
    "fetch hash #{req_hash} downsampled"
  end
  run! if app_file == $0
end