require 'httparty'
require 'jwt'

require_relative '../util/logging'
require_relative '../util/config'

class Fetch

  PLAY = '/play/'
  LIST = '/list/'
  PLAYLIST = '/playlist/'
  PLAYLISTS = '/playlists'
  SEARCH = '/search/'

  # get the address of the mp3 server from config
  def initialize
    @base_url = 'http://' + MP3S::Config::DB::SERVER_HOST + ':' + MP3S::Config::DB::SERVER_PORT.to_s
    @hostheader = nil
    Log.log.info "Fetching mechanism loaded base url of #{@base_url}"
  end

  def set_hostheader(hh)
    @hostheader = hh
  end

  def playlist(playlist_id)
    if playlist_id.nil?
      go_get(@base_url + PLAYLISTS)
    else
      go_get(@base_url + PLAYLIST + playlist_id)
    end
  end

  def fetch(hash, downsample: false)
    ds_extra = ""
    if downsample
      ds_extra = "/downsampled"
    end
    go_get(@base_url + PLAY + hash + ds_extra)
  end

  def list(spec, downsample: false)
    stg = go_get(@base_url + LIST + spec)
    stg = stg.force_encoding('UTF-8')
    # TODO: need to replace internal HTTP_HOST - following is v hacky...
    stg.gsub!(/http:\/\/\d+\.\d+\.\d+\.\d+:\d+\//, 'http://' + @hostheader + '/')
  end

  def search(name, format)
    if format == 'm3u'
      stg = go_get(@base_url + SEARCH + 'm3u/' + name)
    else
      stg = go_get(@base_url + SEARCH + name)
    end
    stg
  end

  def start(stuff)
    @hmac_secret = stuff
    payload = { data: MP3S::Config::Misc::SHARED_SECRET }
    token = JWT.encode payload, @hmac_secret, 'HS256'
    go_get(@base_url + '/pass/' + token)
  end

  def go_get(url)
    begin

      response = HTTParty.get(url, format: :plain)
      Log.log.debug("Requested url: #{url}")
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
