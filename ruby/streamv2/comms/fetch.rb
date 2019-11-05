require 'httparty'
require_relative '../util/logging'
require_relative '../util/config'

class Fetch
  
  PLAY = '/play/'
  LIST = '/list/'
  SEARCH = '/search/'
  
  # get the address of the mp3 server from config
  def initialize
    @base_url = 'http://' + MP3S::Config::DB_SERVER_HOST + ':' + MP3S::Config::DB_SERVER_PORT.to_s
    Log.log.info "Fetching mechanism loaded base url of #{@base_url}"

  end
  
  def fetch(hash, downsample: false)
    ds_extra = ""
    if downsample
      ds_extra = "/downsampled"
    end
    go_get(@base_url + PLAY + hash + ds_extra)
  end
  
  def list(spec)
    go_get(@base_url + LIST + spec)
  end
  
  def search(name)
    go_get(@base_url + SEARCH + name)
  end
  
  def go_get(url)
    begin
      response = HTTParty.get(url, format: :plain)
      case response.code
        when 200
          response.body
        when 404
          Log.log.error("*** NOT FOUND: #{url}")
          '404 Not Found'
        when 500...600
          Log.log.error("DBServer had an error!")
          '500 Internal error'
      end
    rescue Errno::ECONNREFUSED => e
      Log.log.error "Couldn't connect to DBServer :-( "
      'no connection X-( '
    end
  end
  
  
end