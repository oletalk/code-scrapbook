require 'pg'
require_relative 'config'
require_relative 'logging'
require_relative '../data/user'
require_relative '../excep/password'
require_relative '../excep/playlist'
require_relative 'dbbase'

class SongListDb < DbBase
    def check_owner_is(listname, ownername)
        # if playlist doesn't exist - nil
        # if playlist exists and it belongs to ownername - true
        # if playlist exists and it belongs to someone else - false
        ret = nil
        @conn = new_connection
        @conn.exec_params(' SELECT owner, id FROM mp3s_playlist WHERE name = $1', [listname ]) do |result|
            result.each do |row|
                ret = (ownername == row['owner'])
            end
        end
        @conn.finish
        ret
    end

    def list_songlists_for(owner)
        ret = []
        @conn = new_connection
        @conn.exec_params('select name from mp3s_playlist where owner = $1', [ owner ]) do | result |
            result.each do |row|
                ret.push({ name: row['name'] })
            end
        end
        ret
    end

    def update_songlist(name, content, owner)
        # basic wrapper to skip the name insert
        save_songlist(name, content, owner, false)
    end

    def save_songlist(name, content, owner, insertPlaylistName=true)
        ret = nil
        @conn = new_connection
        @conn.transaction do |conn|
            if insertPlaylistName
                sql = %{ INSERT into mp3s_playlist (name, owner)
                         VALUES ($1, $2) }.gsub(/\s+/, " ").strip
                begin
                    conn.prepare('add_pls1', sql)
                    conn.exec_prepared('add_pls1', [ name, owner ])
                rescue PG::Error => e
                    res = e.result
                    Log.log.error "Problem saving new playlist: #{e}"
                    conn.close if conn
                end
            end
            if !conn.finished?
                sql = %{ DELETE from mp3s_playlist_song WHERE playlist_id = (select id FROM mp3s_playlist WHERE name = $1) }
                conn.exec_params(sql, [ name ])
                sql = %{ INSERT into mp3s_playlist_song (playlist_id, file_hash)
                         VALUES ((select id FROM mp3s_playlist WHERE name = $1), $2) }.gsub(/\s+/, " ").strip
                begin
                    conn.prepare('add_pls2', sql)
                    content.each do |jsonrow|
                        conn.exec_prepared('add_pls2', [ name, jsonrow['hash'] ])
                    end
                rescue PG::Error => e
                    res = e.result
                    Log.log.error "Problem saving new playlist: #{e}"
                    conn.close if conn
                end
            else
                Log.log.error "Creating playlist failed at first step so not continuing."
            end
        end
        @conn.close if @conn
    end

    def fetch_playlist(name)
        ret = []
        @conn = new_connection
        sql = %{
            SELECT t.file_hash,
                t.secs,
                case 
                    when (t.title is null or t.title = '') then substring(t.song_filepath from '[^/]*$') 
                    else t.artist || ' - ' || t.title 
                end as display_title 
            FROM mp3s_tags t
            INNER JOIN mp3s_playlist_song ps ON t.file_hash = ps.file_hash
            INNER JOIN mp3s_playlist p ON ps.playlist_id = p.id
            WHERE p.name = $1
            ORDER BY display_title
        }.gsub(/\s+/, " ").strip
        @conn.exec_params(sql, [ name ]) do | result |
            result.each do |row|
                ret.push({ hash: row['file_hash'], title: row['display_title'], secs: row['secs']} )
            end
        end
        @conn.finish
        ret
    end
end
