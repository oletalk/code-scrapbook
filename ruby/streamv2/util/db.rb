require 'pg'
require_relative 'config'
require_relative 'logging'

class Db

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

  def fetch_playlist(playlist_id)
    sql = %{
      select ps.file_hash, artist, title, song_filepath
      from mp3s_playlist_song ps, mp3s_tags t
      where ps.file_hash = t.file_hash
      and ps.playlist_id = $1
      order by artist, title
    }.gsub(/\s+/, " ").strip

    collection_from_sql(
      sql: sql,
      params: [ playlist_id ],
      result_map: {
        id: true,
        name: true
      },
      description: "fetching playlists"
    )
  end

  def record_stat(category, item)
      # NOTE does not work on pre-9.5 versions of PostgreSQL
      @conn = new_connection
      sql = "insert into mp3s_stats (category, item) values ($1, $2) on conflict (category, item) do update set plays = mp3s_stats.plays+1, last_played = current_timestamp;"

      if item == nil
          Log.log.error "Item for category #{category} not recorded because it is nil"
      else
          begin
              @conn.prepare('record_stat1', sql)
              res = @conn.exec_prepared('record_stat1', [ category, item ])
              @conn.close if @conn
          rescue PG::Error => e
              Log.log.error "Problem recording stat: #{e}"
              @conn.close if @conn
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
      SELECT
          file_hash,
          secs,
          case
              when (title is null or title = '') then split_part(right(song_filepath, position('/' IN REVERSE(song_filepath))-1), '.', 1)
              else artist || ' - ' || title
          end as display_title
      FROM mp3s_tags
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

  def fetch_search(search)
    sql = %{
    SELECT
        file_hash,
        secs,
        case
            when (title is null or title = '') then substring(song_filepath from '[^/]*$')
            else artist || ' - ' || title
        end as display_title
    FROM mp3s_tags
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

  # GENERIC SQL FETCH - use only for *parametrised* statements.
  def collection_from_sql(sql: , params: , result_map: , description:)
    ret = []

    #result_map is like { "hash" => "file_hash", "title" => "display_title"}
    begin
      @conn = new_connection

      @conn.exec_params(sql, params) do | result |
        result.each do |result_row|
          new_row = {}
          result_map.each do |key,result_key|
            if result_key == true
              #puts "#{key} -> #{key} (#{result_row[key.to_s]})"
              new_row[key] = result_row[key.to_s]
            else
              #puts "#{key} -> #{result_key} (#{result_row[result_key]})"
              new_row[key] = result_row[result_key]
            end
          end
          ret.push(new_row)
        end
      end
      #puts 'finishing up'
      @conn.finish
    rescue PG::Error => e
        error_description = description
        if error_description == nil
          Log.log.error "Problem performing operation: #{e}"
        else
          Log.log.error "Problem #{error_description}: #{e}"
        end
        @conn.close if @conn
    end
    #puts 'returning result'
    ret
  end

  def new_connection
    PG.connect(dbname: MP3S::Config::DB::NAME, user: MP3S::Config::DB::USER)
  end

end
