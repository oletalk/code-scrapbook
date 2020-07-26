require_relative '../util/logging'
require_relative '../util/config'
require_relative 'base_fetcher'

class Fetch < BaseFetcher

  PLAY = '/play/'
  LIST = '/list/'
  INFO = '/info/'
  PLAYLIST = '/playlist/'
  PLAYLISTS = '/playlists'
  SEARCH = '/search/'

  PLAYLIST_SAVE = '/playlist/save'

  def playlist(playlist_id)
    if playlist_id.nil?
      go_get(PLAYLISTS)
    elsif playlist_id == 'new'
      go_get(PLAYLIST + 'new')
    else
      go_get(PLAYLIST + playlist_id)
    end
  end

  def dellist(playlist_id)
    go_get(PLAYLIST + playlist_id + '/del')
    'Delete complete'
  end

  def savelist(playlist_id, playlist_name, playlist_songids)
    # pid pname songids
    go_post(PLAYLIST_SAVE, {
      pid: playlist_id, pname: playlist_name, songids: playlist_songids
      })
  end

  def fetch(hash, downsample: false)
    ds_extra = ""
    if downsample
      ds_extra = "/downsampled"
    end
    go_get(PLAY + hash + ds_extra)
  end

  def playlist_m3u(spec, downsample: false)
    stg = go_get(PLAYLIST + 'm3u/' + spec)
    stg = stg.force_encoding('UTF-8')
    # TODO: need to replace internal HTTP_HOST - following is v hacky...
    stg.gsub!(/http:\/\/\d+\.\d+\.\d+\.\d+:\d+\//, 'http://' + @hostheader + '/')
  end

  def info(hash)
    stg = go_get(INFO + hash)
    stg
  end

  def list(spec, downsample: false)
    stg = go_get(LIST + spec)
    stg = stg.force_encoding('UTF-8')
    # TODO: need to replace internal HTTP_HOST - following is v hacky...
    stg.gsub!(/http:\/\/\d+\.\d+\.\d+\.\d+:\d+\//, 'http://' + @hostheader + '/')
  end

  def search(name, format)
    if format == 'm3u'
      stg = go_get(SEARCH + 'm3u/' + name)
    else
      stg = go_get(SEARCH + name)
    end
    stg
  end

end
