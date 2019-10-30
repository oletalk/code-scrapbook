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
end