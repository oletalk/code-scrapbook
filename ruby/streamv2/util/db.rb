require 'pg'
require_relative 'config'
require_relative 'logging'

class Db
  
  def new_connection
    PG.connect(dbname: MP3S::Config::DB::NAME, user: MP3S::Config::DB::USER)
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
    ret = nil
    @conn = new_connection
    @conn.exec_params('SELECT song_filepath, artist, title FROM mp3s_tags WHERE file_hash = $1', [given_hash]) do | result |
        result.each do |row|
          ret = {
              :song_filepath => row['song_filepath'],
              :artist        => row['artist'],
              :title         => row['title'],
          }
      end
    end
    @conn.finish
    ret
  end
  
  def list_songs(partial_spec)
    ret = []
    @conn = new_connection
    sql = %{
      SELECT
          file_hash,
          secs,
          case
              when (title is null or title = '') then substring(song_filepath from '[^/]*')
              else artist || ' - ' || title
          end as display_title
      FROM mp3s_tags
      WHERE song_filepath like $1
      ORDER by display_title
    }.gsub(/\s+/, " ").strip
    
    @conn.exec_params(sql, [ "#{partial_spec}%" ]) do | result |
      result.each do |row|
        ret.push({ hash: row['file_hash'], title: row['display_title'], secs: row['secs']} )
      end
    end
    @conn.finish
    ret
  end
  
  def fetch_search(search)
    ret = []
    @conn = new_connection
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
    @conn.exec_params(sql, [ "%#{search}%" ]) do | result |
      result.each do | row |
        ret.push({ hash: row['file_hash'], title: row['display_title'], secs: row['secs']} )
      end
    end
    @conn.finish
    ret
  end
  
end
