require 'pg'
require_relative 'config'
require_relative 'logging'

class Db
  
  def new_connection
    PG.connect(dbname: MP3S::Config::DB_NAME, user: MP3S::Config::DB_USER)
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
    sql = %{}.gsub(/\s+/, " ").strip
    @conn.exec_params(sql, [ "%#{search}%" ]) do | result |
      result.each do | row |
        ret.push({ hash: row['file_hash'], title: row['display_title'], secs: row['secs']} )
      end
    end
    @conn.finish
  end
  
end