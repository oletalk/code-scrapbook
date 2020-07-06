require 'httparty'
require 'jwt'

require_relative '../util/logging'
require_relative '../util/config'

class BaseFetcher

  # get the address of the mp3 server from config
  def initialize(hh = nil)
    @base_url = 'http://' + MP3S::Config::DB::SERVER_HOST + ':' + MP3S::Config::DB::SERVER_PORT.to_s
    @hostheader = hh
    Log.log.info "Fetching mechanism loaded base url of #{@base_url}"
  end

  def start(stuff)
    @hmac_secret = stuff
    payload = { data: MP3S::Config::Misc::SHARED_SECRET }
    token = JWT.encode payload, @hmac_secret, 'HS256'
    go_get('/pass/' + token)
  end

  def go_post(url, params)
    handle_httparty_call(url) do
      HTTParty.post(@base_url + url, body: params)
    end
  end

  def go_get(url)
    handle_httparty_call(url) do
      HTTParty.get(@base_url + url, format: :plain)
    end
  end

  def handle_httparty_call(url)
    begin
      response = yield
      Log.log.debug("Requested url: #{url}")
      do_answer(response)
    rescue Errno::ECONNREFUSED => e
      Log.log.error "Couldn't connect to DBServer :-( "
      'no connection X-( '
    end
  end

  def do_answer(response)
    case response.code
      when 200
        response.body
      when 404
        Log.log.error("*** NOT FOUND: #{url}")
        '404 Not Found'
      when 500...600
        puts 'DBServer had an error - check its logs'
        Log.log.error("DBServer had an error!")
        '500 Internal error'
    end
  end


end
