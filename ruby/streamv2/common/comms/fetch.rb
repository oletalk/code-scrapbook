# frozen_string_literal: true

require_relative '../util/logging'
require_relative '../util/config'
require_relative 'base_fetcher'
require_relative 'fetch_playlist_mixin'
require_relative '../util/cacheable'

class Fetch < BaseFetcher
  include Cacheable
  include FetchPlaylistMixin

  PLAY = '/play/'
  LIST = '/list/'
  PLAYLIST = '/playlist/'
  SEARCH = '/search/'

  def fetch(hash, downsample: false)
    ds_extra = ''
    data = ''

    if downsample
      ds_extra = '/downsampled'
      cacheddata = do_cached(hash) { go_get(PLAY + hash + ds_extra) }
      data = cacheddata.songdata
    else
      data = go_get(PLAY + hash + ds_extra)
    end
    data
  end

  def playlist_m3u(spec, downsample: false)
    stg = go_get("#{PLAYLIST}m3u/#{spec}")
    stg = stg.force_encoding('UTF-8')
    # TODO: need to replace internal HTTP_HOST - following is v hacky...
    stg.gsub!(%r{http://\d+\.\d+\.\d+\.\d+:\d+/}, "http://#{@hostheader}/")
  end

  def list(spec, downsample: false)
    stg = go_get(LIST + spec)
    stg = stg.force_encoding('UTF-8')
    # TODO: need to replace internal HTTP_HOST - following is v hacky...
    stg.gsub!(%r{http://\d+\.\d+\.\d+\.\d+:\d+/}, "http://#{@hostheader}/")
  end

  def search(name, format)
    if format == 'm3u'
      go_get("#{SEARCH}m3u/#{name}")
    else
      go_get(SEARCH + name)
    end
  end
end
