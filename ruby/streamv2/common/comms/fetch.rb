require_relative '../util/logging'
require_relative '../util/config'
require_relative 'base_fetcher'

class Fetch < BaseFetcher

  PLAY = '/play/'
  LIST = '/list/'
  PLAYLIST = '/playlist/'
  PLAYLISTS = '/playlists'
  SEARCH = '/search/'
  TAG = '/tag/'

  PLAYLIST_SAVE = '/playlist/save'
  TAG_SAVE = '/tag/save'

  def tag(hash)
    go_get(TAG + hash)
  end

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

  def savetag(tag_artist, tag_title, tag_hash, playlist_id)
    go_post(TAG_SAVE, {
      artist: tag_artist, title: tag_title, hash: tag_hash, playlist: playlist_id
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
