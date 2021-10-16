# frozen_string_literal: true

require 'pg'
require_relative '../../common/util/config'
require_relative '../../common/util/logging'
require_relative 'basedb' # module of common db methods
require_relative '../../common/text/manip'

# This class contains SQL statements used within DBServer and StreamServer (via Fetch)
class Db
  include BaseDb

  # SQL snippet constants
  TITLE_TERM_SNIPPET = %{
    case
        when (title is null or title = '') then substring(song_filepath from '[^/]*$')
        else COALESCE(artist, 'unknown') || ' - ' || COALESCE(title, 'unknown')
    end as display_title
  }
  DERIVED_TITLE_SNIPPET = %{
    case
    when (title is null or title = '') then 1
      else 0
    end as title_derived
  }

  TAG_SELECT_SNIPPET = Manip.collapse(%(
  SELECT
      file_hash,
      secs,
      #{TITLE_TERM_SNIPPET}
  FROM mp3s_metadata
          ))

  # method defs
  def fetch_playlists
    sql = 'select id, name, date_modified from mp3s_playlist order by name'
    collection_from_sql(
      sql: sql,
      params: nil,
      result_map: {
        id: true,
        name: true,
        modified: 'date_modified'
      },
      description: 'fetching playlists'
    )
  end

  # fetch descriptive tags, not the metadata we used to call 'tags' :-)
  def all_tags_list
    sql = Manip.collapse(%(
      select tag_id, tag_desc
      from mp3s_tags
      order by tag_desc
    ))
    collection_from_sql(
      sql: sql,
      params: [hash],
      result_map: {
        tag_id: true,
        tag_desc: true
      },
      description: 'fetching descriptive tag info'
    )
  end

  def get_info_json(hash)
    sql = Manip.collapse(%{
      select plays, last_played
      from mp3s_stats
      where category = 'SONG'
      and item =
        (select song_filepath
         from mp3s_metadata
         where file_hash = $1)
            })
    collection_from_sql(
      sql: sql,
      params: [hash],
      result_map: {
        plays: true,
        last_played: true
      },
      description: 'fetching song info'
    )
  end

  def get_metadata_info(hash)
    sql = Manip.collapse(%(
      select artist, title,
       #{TITLE_TERM_SNIPPET}
       from mp3s_metadata where file_hash = $1
    ))

    collection_from_sql(
      sql: sql,
      params: [hash],
      result_map: {
        artist: true,
        title: true,
        display_title: true
      },
      description: 'fetching tag for song'
    )
  end

  def get_new_playlist_id
    sql = 'select max(id) + 1 as next_id from mp3s_playlist'
    ret = nil
    connect_for('finding next playlist id') do |conn|
      conn.exec(sql) do |result|
        result.each do |result_row|
          ret = result_row['next_id']
        end
      end
    end

    ret
  end

  def fetch_playlist(playlist_id, by: 'id')
    criteria = if by == 'name'
                 'p.name'
               else
                 'ps.playlist_id'
               end

    sql = Manip.collapse(%(
      select p.name, ps.file_hash, secs,
      #{TITLE_TERM_SNIPPET}
      from mp3s_playlist p, mp3s_playlist_song ps, mp3s_metadata t
      where ps.file_hash = t.file_hash
      and p.id = ps.playlist_id
      and #{criteria} = $1
      order by entry_order
    ))
    # puts "sql: #{sql}"
    collection_from_sql(
      sql: sql,
      params: [playlist_id],
      result_map: {
        name: true,
        hash: 'file_hash',
        secs: true,
        title: 'display_title'
      },
      description: 'fetching playlists'
    )
  end

  def delete_playlist(p_id)
    connect_for('deleting playlist') do |conn|
      sql = 'delete from mp3s_playlist_song where playlist_id = $1'
      conn.prepare('delete_list', sql)
      conn.exec_prepared('delete_list', [p_id])

      sql = 'delete from mp3s_playlist where id = $1'
      conn.prepare('delete_entry', sql)
      conn.exec_prepared('delete_entry', [p_id])
    end
  end

  def save_playlist(p_id, p_name, a_songs)
    p "going to insert #{a_songs.length} songs to playlist #{p_id}"
    if a_songs.length.zero?
      p 'WARNING!! song list passed to me is empty'
      raise 'empty song list'
    end
    connect_for('saving playlist') do |conn|
      # STEP 1 - remove old playlist entries
      sql = 'delete from mp3s_playlist_song where playlist_id = $1'
      conn.prepare('delete_list', sql)
      res = conn.exec_prepared('delete_list', [p_id])

      # STEP 2 - insert (or update name of) playlist main record
      sql = Manip.collapse(%{
        insert into mp3s_playlist (id, name, owner)
        values ($1, $2, 'public')
        on conflict (id)
        do update
        set name = excluded.name
      })
      conn.prepare('update_listrec', sql)
      res = conn.exec_prepared('update_listrec', [p_id, p_name])

      # STEP 3 - insert playlist entries
      sql = 'insert into mp3s_playlist_song(playlist_id, file_hash, entry_order)
             values ($1, $2, $3)'
      conn.prepare('insert_ps1', sql)
      entry_order = 0
      a_songs.each do |sid|
        entry_order += 1
        res = conn.exec_prepared('insert_ps1', [p_id, sid, entry_order])
        p "inserting song #{entry_order}"
      end

      # STEP 4 - update playlist entry with new modified date
      sql = 'update mp3s_playlist set date_modified = current_timestamp where id = $1'
      conn.prepare('update_pl', sql)
      res = conn.exec_prepared('update_pl', [p_id])
    end
  end

  def record_stat(category, item)
    # NOTE: does not work on pre-9.5 versions of PostgreSQL
    if item.nil?
      Log.log.error "Item for category #{category} not recorded because it is nil"
    else
      connect_for('recording statistic') do |conn|
        sql = 'insert into mp3s_stats (category, item) values ($1, $2) on conflict (category, item)
               do update set plays = mp3s_stats.plays+1, last_played = current_timestamp;'
        conn.prepare('record_stat1', sql)
        conn.exec_prepared('record_stat1', [category, item])
      end
    end
  end

  def find_song(given_hash)
    sql = 'SELECT song_filepath, artist, title FROM mp3s_metadata WHERE file_hash = $1'

    collection_from_sql(
      sql: sql,
      params: [given_hash],
      result_map: {
        song_filepath: true,
        artist: true,
        title: true
      },
      description: 'finding song'
    )
  end

  def list_songs(partial_spec)
    sql = Manip.collapse(%(
      #{TAG_SELECT_SNIPPET}
      WHERE song_filepath like $1
      ORDER by display_title
    ))

    collection_from_sql(
      sql: sql,
      params: ["#{partial_spec}%"],
      result_map: {
        hash: 'file_hash',
        secs: true,
        title: 'display_title'
      },
      description: 'fetching song list'
    )
  end

  def fetch_latest_metadata
    sql = Manip.collapse(%(
      SELECT
          date_added,
          file_hash,
          secs,
          #{TITLE_TERM_SNIPPET}
      FROM mp3s_metadata
      where date_added > current_date - interval '1 month'
      order by date_added desc, song_filepath
      ))

    collection_from_sql(
      sql: sql,
      params: nil,
      result_map: {
        date_added: true,
        hash: 'file_hash',
        secs: true,
        title: 'display_title'
      },
      description: 'fetching latest tags'
    )
  end

  def fetch_all_metadata
    sql = Manip.collapse(%(
      SELECT
          date_added,
          file_hash,
          secs,
          #{TITLE_TERM_SNIPPET}
      FROM mp3s_metadata
    ORDER by display_title
            ))

    collection_from_sql(
      sql: sql,
      params: nil,
      result_map: {
        date_added: true,
        hash: 'file_hash',
        secs: true,
        title: 'display_title'
      },
      description: 'fetching all tags'
    )
  end

  def fetch_search(search)
    sql = Manip.collapse(%{
      SELECT
          plays, last_played,
          file_hash,
          secs, date_added,
          #{TITLE_TERM_SNIPPET},
          #{DERIVED_TITLE_SNIPPET}
      FROM mp3s_metadata t
      LEFT OUTER JOIN mp3s_stats s
      ON s.item = t.song_filepath
        WHERE (upper(song_filepath) like upper($1)
       OR  upper(title) like upper($1)
       OR  upper(artist) like upper($1))
    ORDER by COALESCE(plays, 0) desc, display_title
            })

    collection_from_sql(
      sql: sql,
      params: ["%#{search}%"],
      result_map: {
        plays: true,
        last_played: true,
        hash: 'file_hash',
        secs: true,
        date_added: true,
        title: 'display_title',
        title_derived: true
      },
      description: 'fetching search result'
    )
  end

  def save_tag(t_artist, t_title, t_hash)
    sql = Manip.collapse(%(
      update mp3s_metadata
      set artist = $1, title = $2
      where file_hash = $3
      ))
    connect_for('saving tag') do |conn|
      conn.prepare('save_tag1', sql)
      conn.exec_prepared('save_tag1', [t_artist, t_title, t_hash])
    end
  end

  def update_tag_date(file_hash, dte)
    sql = 'update mp3s_metadata set date_added = $1 where file_hash = $2'
    connect_for('updating date on tag') do |conn|
      conn.prepare('update_tag1', sql)
      conn.exec_prepared('update_tag1', [dte, file_hash])
    end
  end

  def write_tag(hash, filename, tagobj)
    # check hash/filename is not already in database
    found_songs = find_song(hash)
    if found_songs.nil? || found_songs.empty?
      connect_for('writing tag') do |conn|
        sql = Manip.collapse(%{
            INSERT into mp3s_metadata
            (song_filepath, file_hash, artist, title,secs)
            VALUES ($1, $2, $3, $4, $5)
            })
        conn.prepare('write_tag1', sql)
        conn.exec_prepared('write_tag1', [
                             filename, hash, tagobj[:artist],
                             tagobj[:title], tagobj[:secs]
                           ])
      end
    elsif found_songs[0]['song_filepath'] != filename
      raise 'Given tag and hash do not match!'
    else
      Log.log.info 'Hash/filename already in database, nothing done.'
    end
  end
end

class DbError < StandardError
end
