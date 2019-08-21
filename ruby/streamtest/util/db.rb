require 'pg'
require_relative 'config'
require_relative 'logging'
require_relative '../data/user'
require_relative '../excep/password'
require_relative '../excep/playlist'

class Db

    def new_connection
        PG.connect(dbname: MP3S::Config::DB_NAME, user:  MP3S::Config::DB_USER)
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
        @conn.exec_params(sql, [ "%#{search}%" ]) do |result|
            result.each do |row|
                ret.push({ hash: row['file_hash'], title: row['display_title'], secs: row['secs']} )
            end
        end
        @conn.finish
        ret
    end

    def fetch_lastweek_songs
      ret = []
      @conn = new_connection
      sql = %{
        SELECT 
          substring(s.item from '[^/]*$') item, last_played, t.file_hash 
        FROM mp3s_stats s, mp3s_tags t 
        WHERE s.category = 'SONG' 
        AND s.item = t.song_filepath 
        AND last_played > current_date - INTERVAL '7 days' 
        ORDER BY last_played DESC
      }.gsub(/\s+/, " ").strip
      @conn.exec_params(sql) do |result|
          result.each do |row|
              ret.push({ item: row['item'], last_played: row['last_played'], file_hash: row['file_hash']} )
          end
      end
      @conn.finish
      ret
    end

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

    def find_song(given_hash)
        ret = nil
        @conn = new_connection
        @conn.exec_params(' SELECT song_filepath, artist, title FROM mp3s_tags WHERE file_hash = $1', [given_hash]) do | result |
            result.each do |row|
                #ret = row.values_at('song_filepath', 'file_hash')
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

    def find_user(user)
        @conn = new_connection
        ret = nil
        @conn.exec_params(' SELECT username,pass FROM users WHERE username = $1', [ user]) do | result |
            result.each do |row|
                ret = User.new(row['username'], row['pass'])
            end
        end
        @conn.finish
        ret
    end

    def authenticate_user(username, plainpass)
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

    def add_user(user, cryptedpass)
        @conn = new_connection
        if find_user(user) != nil
            raise UserCreationError.new("That user already exists")
        end

        @conn = new_connection
        sql = %{ INSERT into users (username, pass)
                 VALUES ($1, $2) }.gsub(/\s+/, " ").strip
        begin
            @conn.prepare('add_user1', sql)
            @conn.exec_prepared('add_user1', [ user, cryptedpass ])
            @conn.close if @conn
        rescue PG::Error => e
            Log.log.error "Problem saving new user: #{e}"
            @conn.close if @conn
        end

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
