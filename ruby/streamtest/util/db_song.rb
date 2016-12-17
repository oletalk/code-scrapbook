require 'pg'
require_relative 'config'
require_relative 'logging'
require_relative '../data/user'
require_relative '../excep/password'
require_relative '../excep/playlist'
require_relative 'dbbase'

class SongDb < DbBase
    def find_song(given_hash)
        ret = nil
        @conn = new_connection
        @conn.exec_params(' SELECT song_filepath FROM mp3s_tags WHERE file_hash = $1', [given_hash]) do | result |
            result.each do |row|
                #ret = row.values_at('song_filepath', 'file_hash')
                ret = row['song_filepath']
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
                    when (title is null or title = '') then substring(song_filepath from '[^/]*$') 
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

    def get_tag_for(hash, filename)
        ret = nil
        @conn = new_connection
        @conn.exec_params(' SELECT artist, title, secs FROM mp3s_tags WHERE file_hash = $1 and song_filepath = $2', [hash, filename]) do | result |
            result.each do |row|
                #ret = row.values_at('song_filepath', 'file_hash')
                ret = { artist: row['artist'], title: row['title'], secs: row['secs']}
            end
        end
        @conn.finish
        ret
    end

    def write_tag(hash, filename, tagobj)
        # check hash/filename is not already in database
        found_song = find_song(hash)
        if found_song.nil?
            # save tag info to database
            @conn = new_connection
            sql = %{
                INSERT into mp3s_tags (song_filepath, file_hash, artist, title, secs)
                VALUES ($1, $2, $3, $4, $5)
                }.gsub(/\s+/, " ").strip
            begin
                @conn.prepare('ins_tag1', sql)
                @conn.exec_prepared('ins_tag1', [ filename, hash, tagobj[:artist], tagobj[:title], tagobj[:secs]])
                @conn.close if @conn
            rescue PG::Error => e
                res = e.result
                Log.log.error "Problem saving new tag: #{e}"
                @conn.close if @conn
            end
        else
            if found_song != filename
                raise 'Given tag and hash do not match!'
            else
                Log.log.info 'Hash/filename already in database, nothing done.'
            end
        end
    end
end
