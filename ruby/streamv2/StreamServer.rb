require 'sinatra/base'
require_relative 'util/config'
require_relative 'comms/fetch'
require_relative 'util/ipwl'

# so, this server should be publicly accessible
# but the other, with access to the mp3s, shouldn't
class StreamServer < Sinatra::Base
  set :bind, MP3S::Config::Net::SERVER_HOST
  set :port, MP3S::Config::Net::SERVER_PORT
  enable :dump_errors
  
  # init stuff
  configure do
    f = Fetch.new
    result = f.start(ENV.fetch('HMAC_SECRET'))
    if result != 'OK'
      puts " *******************************************************************"
      puts " *                                                                 *"
      puts " * ERROR! Did not establish connection with DBServer! Check logs.  *"
      puts " *                                                                 *"
      puts " *******************************************************************"

    else
      puts "Successfully connected to DBServer!"
    end
  end
  
  
  # before each request...
  before do
    @ipwl = IPWhitelist.new(MP3S::Clients::List, MP3S::Clients::Default)

    remote_ip = request.env['REMOTE_ADDR']
    if @ipwl == nil
      puts "ipwl is nil"
    end
    action = @ipwl.action(remote_ip)
    Log.log.info("Action for #{remote_ip} is #{action}.")
    if !action[:allow]
      halt 403, {'Content-Type' => 'text/plain'}, '403 Access Denied'
    end
    @downsample = action[:downsample]
  end

  get '/play/:hash' do |req_hash|
    # PASS REQUEST ON TO DB MODULE
    f = Fetch.new
    f.fetch(req_hash, downsample: @downsample)
  end
  
  get '/m3u/:spec' do
    spec = params['spec']
    response.headers['Content-Type'] = 'text/plain'
    f = Fetch.new
    f.set_hostheader(request.env['HTTP_HOST'])
    f.list(spec)
  end
  
  get '/search/:name' do
    f = Fetch.new
    name = params['name']
    response.headers['Content-Type'] = 'text/plain'
    f.search(name)
  end
  
  
  run! if app_file == $0
end
