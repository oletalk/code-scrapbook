require 'pg'
require_relative './config.rb'

module Db

    def self.new_connection
        PG.connect(dbname: MP3S::Config::DB_NAME, user:  MP3S::Config::DB_USER)
    end

    def self.find_song(given_hash)
        ret = nil
        conn = new_connection
        conn.exec_params(' SELECT song_filepath FROM mp3s_tags WHERE file_hash = $1', [given_hash]) do | result |
            result.each do |row|
                #ret = row.values_at('song_filepath', 'file_hash')
                ret = row['song_filepath']
            end
        end
        conn.finish
        ret
    end

    def self.list_songs(partial_spec)
        ret = []
        conn = new_connection
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
            }.gsub(/\s+/, " ").strip
        conn.exec_params(sql, [ "#{partial_spec}%" ]) do | result |
            result.each do |row|
                ret.push({ hash: row['file_hash'], title: row['display_title'], secs: row['secs']} )
            end
        end
        conn.finish
        ret
    end

    def self.get_tag_for(hash, filename)
        ret = nil
        conn = new_connection
        conn.exec_params(' SELECT artist, title, secs FROM mp3s_tags WHERE file_hash = $1 and song_filepath = $2', [hash, filename]) do | result |
            result.each do |row|
                #ret = row.values_at('song_filepath', 'file_hash')
                ret = { artist: row['artist'], title: row['title'], secs: row['secs']}
            end
        end
        conn.finish
        ret
    end

    def self.write_tag(hash, filename, tagobj)
        # check hash/filename is not already in database
        found_song = find_song(hash)
        if found_song.nil?
            # save tag info to database
            conn = new_connection
            sql = %{
                INSERT into mp3s_tags (song_filepath, file_hash, artist, title, secs)
                VALUES ($1, $2, $3, $4, $5)
                }.gsub(/\s+/, " ").strip
            begin
                conn.prepare('ins_tag1', sql)
                conn.exec_prepared('ins_tag1', [ filename, hash, tagobj[:artist], tagobj[:title], tagobj[:secs]])
                conn.close if conn
            rescue PG::Error => e
                res = e.result
                puts "Problem saving new tag: #{e.error_field( PG::Result::PG_DIAG_MESSAGE_PRIMARY )}"
                conn.close if conn
            end
        else
            if found_song != filename
                raise 'Given tag and hash do not match!'
            else
                puts 'Hash/filename already in database, nothing done.'
            end
        end
    end
end
