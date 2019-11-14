require 'sinatra/base'
require 'sysrandom/securerandom'
require 'jwt'
require_relative 'util/config'
require_relative 'util/db'
require_relative 'util/player'
require_relative 'util/logging'
require_relative 'text/format'

# this server should not be publicly accessible
class DBServer < Sinatra::Base
  set :bind, MP3S::Config::DB_SERVER_HOST
  set :port, MP3S::Config::DB_SERVER_PORT
  enable :sessions
  enable :logging
  enable :dump_errors
  
  # init stuff
  configure do
    @@streamserver = nil
    set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
  end

  before do
    @db   = Db.new
    @player = Player.new
    
    @remote_ip = request.env['REMOTE_ADDR']
    if @remote_ip != @@streamserver
      pass if request.path_info.start_with? '/pass/'
      
      puts 'Remote IP mismatch! Denying request.'
      Log.log.error "Remote IP not streamserver! #@remote_ip"
      halt
    end
  end
    
  get '/search/:name' do |name|
    song_list = @db.fetch_search(name)
    if song_list.size > 0
      Format.play_list(song_list, request.env['HTTP_HOST'], request.env["downsample"])
    else
      '{ "error" : "That playlist was not found" }'
    end
    
  end
  
  
  get '/list/:spec' do |req_spec|
    puts '..... ####'
    puts @@streamserver
    if req_spec == 'all'
      req_spec = ''
    end
    song_list = @db.list_songs("#{MP3S::Config::MP3_ROOT}/#{req_spec}")
    Format.play_list(song_list, request.env['HTTP_HOST'], request.env['downsample'])
  end
  
  get '/play/:hash' do |req_hash|
    # locate hash in db
    do_downsample = request.env['downsample']
    process_songdata(req_hash, do_downsample)
   
  end
  
  get '/play/:hash/downsampled' do |req_hash|
    # locate hash in db
    do_downsample = request.env['downsample']
    process_songdata(req_hash, do_downsample, true)
  end
  
  get '/pass/:jwt' do |token|
    hmac_secret = ENV.fetch('HMAC_SECRET')
    begin
      if @@streamserver.nil?
        Log.log.info "Stream server connected from #@remote_ip"
      else
        Log.log.error "Extraneous connection from #@remote_ip"
        halt 401, 'Stream server is already connected elsewhere :-P'
      end
 
      decoded_token = JWT.decode token, hmac_secret, true, { algorithm: 'HS256' }
      pass = decoded_token[0]['data']
      if pass == MP3S::Config::SHARED_SECRET
        puts 'Shared secret is OK!'
        Log.log.info "Stream server successfully verified from #@remote_ip"
        @@streamserver = @remote_ip #TODO something else?
     end
      'OK'
    rescue JWT::VerificationError
      Log.log.error "Verification from #@remote_ip failed"
      'FAIL'
    end
  end
  
  helpers do
    def process_songdata(req_hash, do_downsample, req_downsample=false)
      songdata = @db.find_song(req_hash)
      if songdata.nil?
        "404 Sorry, that song was not found"
      else
        song_loc = songdata[:song_filepath]
    
        Log.log.info("Song '#{song_loc}' (#{req_hash}) requested")
  
        Log.log.info("Downsample info from the request: #{do_downsample}")
        songresponse(req_hash, song_loc, req_downsample)
      end
    end
    
    def songresponse(req_hash, song_loc, downsample=false )
      
      if (downsample)
          Log.log.error("Action for client is to downsample but it is asking for raw file")
          "403 Forbidden"
        else
          # play it (stream server will be calling this method)
          command = @player.get_command(downsample, song_loc)
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
  
  run! if app_file == $0
end