require 'sinatra/base'
require_relative 'util/config'
require_relative 'comms/fetch'
require_relative 'util/ipwl'

# so, this server should be publicly accessible
# but the other, with access to the mp3s, shouldn't
class StreamServer < Sinatra::Base
  set :bind, MP3S::Config::SERVER_HOST
  set :port, MP3S::Config::SERVER_PORT
  enable :sessions
  enable :logging
  enable :dump_errors
  
  # init stuff
  before do
    @ipwl = IPWhitelist.new(MP3S::Clients::List, MP3S::Clients::Default)
    
    remote_ip = request.env['REMOTE_ADDR']
    action = @ipwl.action(remote_ip)
    Log.log.info("Action for #{remote_ip} is #{action}.")
    if !action[:allow]
      halt 403, {'Content-Type' => 'text/plain'}, '403 Access Denied'
    end
    @downsample = action[:downsample]
  end

  get '/play/:hash' do |req_hash|
    if @downsample
      Log.log.error "ip whitelist indicates we should request downsampled tunes"
      halt 403, {'Content-Type' => 'text/plain'}, '403 Access Denied'
    else
  
  # PASS REQUEST ON TO DB MODULE
      f = Fetch.new
      f.fetch(req_hash)
    end
  end
  
  get '/play/:hash/downsampled' do |req_hash|
    if !@downsample
      Log.log.error "ip whitelist indicates we should NOT request downsampled tunes"
      halt 403, {'Content-Type' => 'text/plain'}, '403 Access Denied'
    else
  
  # PASS REQUEST ON TO DB MODULE
      f = Fetch.new
      f.fetch(req_hash, downsample: true)
    end
  end
  run! if app_file == $0
end