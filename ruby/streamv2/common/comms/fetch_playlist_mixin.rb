# frozen_string_literal: true

module FetchPlaylistMixin
  TAGS = '/tags/'
  PLAYLIST = '/playlist/'
  PLAYLISTS = '/playlists'
  METADATA = '/tag/'
  PLAYLIST_SAVE = '/playlist/save'
  METADATA_SAVE = '/tag/save'
  QUERY = '/query/'
  SEARCH = '/search/'

  def playlist(playlist_id)
    if playlist_id.nil?
      go_get(PLAYLISTS)
    elsif playlist_id == 'new'
      go_get("#{PLAYLIST}new")
    else
      go_get(PLAYLIST + playlist_id)
    end
  end

  def dellist(playlist_id)
    go_get("#{PLAYLIST}#{playlist_id}/del")
    'Delete complete'
  end

  def savelist(playlist_id, playlist_name, playlist_songids)
    # pid pname songids
    go_post(PLAYLIST_SAVE, {
              pid: playlist_id, pname: playlist_name, songids: playlist_songids
            })
  end

  def latestsongs
    go_get("#{QUERY}latest")
  end

  def randomlist(number)
    go_get("#{QUERY}random/#{number}")
  end

  def tag(hash)
    go_get(METADATA + hash)
  end

  def savetag(tag_artist, tag_title, tag_hash, playlist_id)
    go_post(METADATA_SAVE, {
              artist: tag_artist, title: tag_title, hash: tag_hash, playlist: playlist_id
            })
  end

  def add_desc_tag(hash, tag_id)
    go_post("#{TAGS}/add", {
              hash: hash,
              tag_id: tag_id
            })
  end

  def del_desc_tag(hash, tag_id)
    go_post("#{TAGS}/del", {
              hash: hash,
              tag_id: tag_id
            })
  end

  def all_desc_tags
    go_get("#{TAGS}list")
  end

  def song_tags(hash)
    go_get(TAGS + hash)
  end
end
