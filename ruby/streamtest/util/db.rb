require 'pg'
require_relative 'config'
require_relative 'logging'
require_relative '../data/user'
require_relative '../excep/password'
require_relative '../excep/playlist'

module Db

    def self.new_connection
        PG.connect(dbname: MP3S::Config::DB_NAME, user:  MP3S::Config::DB_USER)
    end

    def self.check_owner_is(listname, ownername)
        # if playlist doesn't exist - nil
        # if playlist exists and it belongs to ownername - true
        # if playlist exists and it belongs to someone else - false
        ret = nil
        conn = new_connection
        conn.exec_params(' SELECT owner, id FROM mp3s_playlist WHERE name = $1', [listname ]) do |result|
            result.each do |row|
                ret = (ownername == row['owner'])
            end
        end
        conn.finish
        ret
    end

    def self.list_songlists_for(owner)
        ret = []
        conn = new_connection
        conn.exec_params('select name from mp3s_playlist where owner = $1', [ owner ]) do | result |
            result.each do |row|
                ret.push({ name: row['name'] })
            end
        end
        ret
    end

#    def self.get_songlist(name)
#        ret = []
#        conn = new_connection
#        conn.exec_params(' SELECT song_filepath FROM mp3s_playlist_song WHERE playlist_id IN (select playlist_id FROM mp3s_playlist WHERE name = $1 ORDER BY song_filepath', [name]) do | result |
#            result.each do |row|
#                ret.push(row['song_filepath'])
#            end
#        end
#        conn.finish
#        ret
#    end

    def self.update_songlist(name, content, owner)
        # basic wrapper to skip the name insert
        save_songlist(name, content, owner, false)
    end

    def self.save_songlist(name, content, owner, insertPlaylistName=true)
        ret = nil
        conn = new_connection
        conn.transaction do |conn|
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
        conn.close if conn
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

    def self.fetch_playlist(name)
        ret = []
        conn = new_connection
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
        conn.exec_params(sql, [ name ]) do | result |
            result.each do |row|
                ret.push({ hash: row['file_hash'], title: row['display_title'], secs: row['secs']} )
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
            ORDER by display_title
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

    def self.find_user(user)
        conn = new_connection
        ret = nil
        conn.exec_params(' SELECT username,pass FROM users WHERE username = $1', [ user]) do | result |
            result.each do |row|
                ret = User.new(row['username'], row['pass'])
            end
        end
        conn.finish
        ret
    end

    def self.authenticate_user(username, plainpass)
        ret = nil
        
        finduser = find_user(username)
        if (!finduser.nil?)
            # check the password!
            if finduser.password_matches(plainpass)
                ret = finduser
            else
                Log.log.error "Wrong password for user #{username}"
            end
        else
            Log.log.error "Invalid user #{username}"
        end
        ret
    end

    def self.add_user(user, cryptedpass)
        conn = new_connection
        if find_user(user) != nil
            raise UserCreationError.new("That user already exists")
        end

        sql = %{ INSERT into users (username, pass)
                 VALUES ($1, $2) }.gsub(/\s+/, " ").strip
        begin
            conn.prepare('add_user1', sql)
            conn.exec_prepared('add_user1', [ user, cryptedpass ])
            conn.close if conn
        rescue PG::Error => e
            res = e.result
            Log.log.error "Problem saving new user: #{e}"
            conn.close if conn
        end

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
                Log.log.error "Problem saving new tag: #{e}"
                conn.close if conn
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
