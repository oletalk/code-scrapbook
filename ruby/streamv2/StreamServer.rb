require 'sinatra/base'
require 'json'
require 'cgi'
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
    @playlist = action[:playlist]
    @downsample = action[:downsample]
  end

  post '/playlist/save' do
    playlist_id = params['pid']
    playlist_name = params['pname']
    playlist_songids = params['songids']
    if playlist_songids.nil?
      'Error: no playlist songs provided :-/'
    else
      f = Fetch.new
      f.savelist(playlist_id, playlist_name, playlist_songids)
      redirect '/playlist/manage'
    end
  end

  get '/playlist/manage' do
    f = Fetch.new
    @foo = JSON.parse(f.playlist(nil))
    erb :manage
  end

  get '/playlist_new' do
    f = Fetch.new
    @foo = []
    res = f.playlist('new')
    @playlist_id = f.playlist('new').to_i
    Log.log.debug "New playlist will have an id of #{@playlist_id} (from #{res})"
    erb :list
  end

  get '/playlist/:id' do |id|
    f = Fetch.new
    @foo = JSON.parse(f.playlist(id))
    puts @foo
    # each row has the playlist name (yeah, i know...)
    @pname = @foo[0]['name']
    @playlist_id = id
    erb :list
  end

  get '/playlist/:id/delete' do |id|
    f = Fetch.new
    f.dellist(id)
    redirect '/playlist/manage'
end

  get '/play/:hash' do |req_hash|
    # PASS REQUEST ON TO DB MODULE
    f = Fetch.new
    f.fetch(req_hash, downsample: @downsample)
  end

  get '/playlist/m3u/:name' do |name|
    response.headers['Content-Type'] = 'text/plain'
    f = Fetch.new
    f.set_hostheader(request.env['HTTP_HOST'])
    f.playlist_m3u(name)
  end

  get '/m3u/:spec' do
    spec = params['spec']
    response.headers['Content-Type'] = 'text/plain'
    f = Fetch.new
    f.set_hostheader(request.env['HTTP_HOST'])
    f.list(spec)
  end

  get '/m3u/search/:name' do
    f = Fetch.new
    f.set_hostheader(request.env['HTTP_HOST'])
    name = params['name']
    response.headers['Content-Type'] = 'text/plain'
    f.search(name, 'm3u')
  end

#json
  get '/search/:name' do
    f = Fetch.new
    f.set_hostheader(request.env['HTTP_HOST'])
    name = CGI.escape(params['name'])
    response.headers['Content-Type'] = 'text/plain'
    puts f.search(name, nil)
    f.search(name, nil)
  end



  run! if app_file == $0
end