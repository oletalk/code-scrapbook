module FetchPlaylistMixin

  PLAYLIST = '/playlist/'
  PLAYLISTS = '/playlists'
  TAG = '/tag/'
  PLAYLIST_SAVE = '/playlist/save'
  TAG_SAVE = '/tag/save'
  QUERY = '/query/'
  SEARCH = '/search/'


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

  def latestsongs
    go_get(QUERY + 'latest')
  end

  def randomlist(number)
    stg = go_get(QUERY + 'random/' + number.to_s)
    stg
  end

  def tag(hash)
    go_get(TAG + hash)
  end

  def savetag(tag_artist, tag_title, tag_hash, playlist_id)
    go_post(TAG_SAVE, {
      artist: tag_artist, title: tag_title, hash: tag_hash, playlist: playlist_id
      })
  end

end
