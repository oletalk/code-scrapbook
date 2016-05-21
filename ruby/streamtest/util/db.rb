require 'pg'
require_relative './config.rb'

# TODO: parametrize, parametrize, parametrize
def find_song(given_hash)
    ret = nil
    conn = PG.connect(dbname: MP3S::Config::DB_NAME, user:  MP3S::Config::DB_USER)
    conn.exec_params(' SELECT song_filepath FROM mp3s_tags WHERE file_hash = $1', [given_hash]) do | result |
        result.each do |row|
            #ret = row.values_at('song_filepath', 'file_hash')
            ret = row['song_filepath']
        end
    end
    ret
end

def list_songs(partial_spec)
    ret = []
    conn = PG.connect(dbname: MP3S::Config::DB_NAME, user:  MP3S::Config::DB_USER)
    sql = %{
        SELECT 
            file_hash, 
            case 
                when (title is null or title = '') then substring(song_filepath from '[^/]*$') 
                else artist || ' - ' || title 
            end as display_title 
        FROM mp3s_tags 
        WHERE song_filepath like $1
        }.gsub(/\s+/, " ").strip
    conn.exec_params(sql, [ "#{partial_spec}%" ]) do | result |
        result.each do |row|
            ret.push({ hash: row['file_hash'], title: row['display_title']} )
        end
    end
    ret
end
