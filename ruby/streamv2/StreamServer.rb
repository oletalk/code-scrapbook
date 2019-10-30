require 'sinatra/base'
require_relative 'util/config'
require_relative 'comms/fetch'

# so, this server should be publicly accessible
# but the other, with access to the mp3s, shouldn't
class StreamServer < Sinatra::Base
  set :bind, MP3S::Config::SERVER_HOST
  set :port, MP3S::Config::SERVER_PORT
  enable :sessions
  enable :logging
  enable :dump_errors
  
  get '/play/:hash' do |req_hash|
    # PASS REQUEST ON TO DB MODULE
    f = Fetch.new
    f.fetch(req_hash)
  end
  
  get '/play/:hash/downsampled' do |req_hash|
    "fetch hash #{req_hash} downsampled"
  end
  run! if app_file == $0
end