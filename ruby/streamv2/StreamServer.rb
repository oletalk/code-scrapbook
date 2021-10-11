# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require 'cgi'
require_relative 'common/util/config'
require_relative 'common/comms/fetch'
require_relative 'common/text/manip'
require_relative 'common/comms/connector'
require_relative 'streamserver/util/ipwl'
require_relative 'helpers/ss_playlist'
require_relative 'helpers/ss_tageditor'
# so, this server should be publicly accessible
# but the other, with access to the mp3s, shouldn't
class StreamServer < Sinatra::Base
  MAX_ITEM_LENGTH = 80

  set :bind, MP3S::Config::Net::SERVER_HOST
  set :port, MP3S::Config::Net::SERVER_PORT
  enable :dump_errors

  register Sinatra::PlaylistEditorGUI
  register Sinatra::TagEditorGUI

  # init stuff
  configure do
    f = Fetch.new
    result = f.start(Connector.get_hmac_secret)
    if result != 'OK'
      Log.log.error("Fetch start returned: '#{result}'")
      puts ' *******************************************************************'
      puts ' *                                                                 *'
      puts ' * ERROR! Did not establish connection with DBServer! Check logs.  *'
      puts ' *                                                                 *'
      puts ' *******************************************************************'
    else
      puts 'Successfully connected to DBServer!'
    end
  end

  # before each request...
  before do
    @ipwl = IPWhitelist.new(MP3S::Clients::List, MP3S::Clients::Default)

    remote_ip = request.env['REMOTE_ADDR']
    puts 'ipwl is nil' if @ipwl.nil?
    action = @ipwl.action(remote_ip)
    Log.log.info("Action for #{remote_ip} is #{action}.")
    halt 403, { 'Content-Type' => 'text/plain' }, '403 Access Denied' unless action[:allow]
    # @playlist = action[:playlist]
    # @downsample = action[:downsample]
    @actions = action
  end

  get '/play/:hash' do |req_hash|
    # PASS REQUEST ON TO DB MODULE
    f = Fetch.new
    f.fetch(req_hash, downsample: @actions[:downsample])
  end

  get '/m3u/:spec' do |spec|
    response.headers['Content-Type'] = 'text/plain'
    f = Fetch.new(request.env['HTTP_HOST'])
    f.list(spec)
  end

  get '/search/m3u/:name' do |name|
    f = Fetch.new(request.env['HTTP_HOST'])
    response.headers['Content-Type'] = 'text/plain'
    f.search(name, 'm3u')
  end

  # json
  get '/playlist/json/:id' do |id|
    f = Fetch.new
    foo = Manip.shorten_titles(JSON.parse(f.playlist(id)), MAX_ITEM_LENGTH)
    # each row has the playlist name (yeah, i know...)
    @pname = foo[0]['name']
    foo.each { |s| s['secs_display'] = Manip.time_display(s['secs']) }
    foo.to_json
  end

  get '/search/:name' do |name|
    f = Fetch.new(request.env['HTTP_HOST'])
    name = CGI.escape(name)
    response.headers['Content-Type'] = 'text/plain'
    f.search(name, nil)
  end

  get '/query/latest' do
    f = Fetch.new(request.env['HTTP_HOST'])
    f.latestsongs
  end

  get '/query/random/:number' do |number|
    f = Fetch.new(request.env['HTTP_HOST'])
    f.randomlist(number)
  end

  run! if app_file == $PROGRAM_NAME
end
