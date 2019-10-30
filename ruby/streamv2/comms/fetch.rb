require 'httparty'
require_relative '../util/logging'
require_relative '../util/config'

class Fetch
  
  # get the address of the mp3 server from config
  def initialize
    @base_url = 'http://' + MP3S::Config::DB_SERVER_HOST + ':' + MP3S::Config::DB_SERVER_PORT.to_s + '/play/'
    Log.log.info "Fetching mechanism loaded base url of #{@base_url}"

  end
  
  def fetch(hash)
    url = @base_url + hash
    response = HTTParty.get(url, format: :plain)
    response.body
  end
  
end