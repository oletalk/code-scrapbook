require 'pg'
require_relative 'config'
require_relative 'logging'
require_relative 'basedb' # common db methods

class Db < BaseDb

  #SQL snippet constants
  TITLE_TERM_SNIPPET = %{
    case
        when (title is null or title = '') then substring(song_filepath from '[^/]*$')
        else COALESCE(artist, 'unknown') || ' - ' || COALESCE(title, 'unknown')
    end as display_title
  }

  TAG_SELECT_SNIPPET = %{
  SELECT
      file_hash,
      secs,
      #{TITLE_TERM_SNIPPET}
  FROM mp3s_tags
          }.gsub(/\s+/, " ").strip

  # method defs
  def fetch_playlists
    sql = 'select id, name from mp3s_playlist order by name'
    res = collection_from_sql(
      sql: sql,
      params: nil,
      result_map: {
        id: true,
        name: true
      },
      description: "fetching playlists"
    )
    res
  end

  def get_new_playlist_id
    sql = 'select max(id) + 1 as next_id from mp3s_playlist'
    ret = nil
    connect_for('finding next playlist id') do

      res = @conn.exec(sql) do | result |
       result.each do |result_row|
         ret = result_row['next_id']
       end
     end

    end

    ret
  end

  def fetch_playlist(playlist_id, by: 'id')
    if by == 'name'
      criteria = 'p.name'
    else
      criteria = 'ps.playlist_id'
    end

    sql = %{
      select p.name, ps.file_hash, secs,
      #{TITLE_TERM_SNIPPET}
      from mp3s_playlist p, mp3s_playlist_song ps, mp3s_tags t
      where ps.file_hash = t.file_hash
      and p.id = ps.playlist_id
      and #{criteria} = $1
    }.gsub(/\s+/, " ").strip
    #puts "sql: #{sql}"
    collection_from_sql(
      sql: sql,
      params: [ playlist_id ],
      result_map: {
        name: true,
        hash: "file_hash",
        secs: true,
        title: "display_title"
      },
      description: "fetching playlists"
    )
  end

  def delete_playlist(p_id)
    connect_for('deleting playlist') do
      sql = "delete from mp3s_playlist_song where playlist_id = $1"
      @conn.prepare('delete_list', sql)
      res = @conn.exec_prepared('delete_list', [ p_id ])

      sql = "delete from mp3s_playlist where id = $1"
      @conn.prepare('delete_entry', sql)
      res = @conn.exec_prepared('delete_entry', [ p_id ])

    end
  end

  def save_playlist(p_id, p_name, a_songs)
    connect_for('saving playlist') do
      # STEP 1 - remove old playlist entries
      sql = "delete from mp3s_playlist_song where playlist_id = $1"
      @conn.prepare('delete_list', sql)
      res = @conn.exec_prepared('delete_list', [ p_id ])

      # STEP 2 - insert (or update name of) playlist main record
      sql = %{
        insert into mp3s_playlist (id, name, owner)
        values ($1, $2, 'public')
        on conflict (id)
        do update
        set name = excluded.name
      }.gsub(/\s+/, " ").strip
      @conn.prepare('update_listrec', sql)
      res = @conn.exec_prepared('update_listrec', [ p_id, p_name ])

      # STEP 3 - insert playlist entries
      sql = "insert into mp3s_playlist_song(playlist_id, file_hash) values ($1, $2)"
      @conn.prepare('insert_ps1', sql)
      a_songs.each do |sid|
        res = @conn.exec_prepared('insert_ps1', [ p_id, sid ])
      end
    end # connect_for
  end

  def record_stat(category, item)
      # NOTE does not work on pre-9.5 versions of PostgreSQL
      if item == nil
          Log.log.error "Item for category #{category} not recorded because it is nil"
      else
        connect_for('recording statistic') do
          sql = "insert into mp3s_stats (category, item) values ($1, $2) on conflict (category, item) do update set plays = mp3s_stats.plays+1, last_played = current_timestamp;"
          @conn.prepare('record_stat1', sql)
          res = @conn.exec_prepared('record_stat1', [ category, item ])
        end
      end
  end

  def find_song(given_hash)
    sql = 'SELECT song_filepath, artist, title FROM mp3s_tags WHERE file_hash = $1'

    collection_from_sql(
      sql: sql,
      params: [given_hash],
      result_map: {
        song_filepath: true,
        artist: true,
        title: true
      },
      description: "finding song"
    )
  end

  def list_songs(partial_spec)
    sql = %{
      #{TAG_SELECT_SNIPPET}
      WHERE song_filepath like $1
      ORDER by display_title
    }.gsub(/\s+/, " ").strip

    collection_from_sql(
      sql: sql,
      params: [ "#{partial_spec}%" ],
      result_map: {
        hash: "file_hash",
        secs: true,
        title: "display_title"
      },
      description: "fetching song list"
    )
  end
  # TODO: write method for fetching playlist
  # (need DBServer, fetch, StreamServer methods too)
  def fetch_search(search)
    sql = %{
    #{TAG_SELECT_SNIPPET}
    WHERE upper(song_filepath) like upper($1)
    ORDER by display_title
            }.gsub(/\s+/, " ").strip

    collection_from_sql(
      sql: sql,
      params: [ "%#{search}%" ],
      result_map: {
        hash: "file_hash",
        secs: true,
        title: "display_title"
      },
      description: "fetching search result"
)
  end

end

class DbError < StandardError
end
