require 'pg'
require_relative 'logging'
require_relative '../data/user'
require_relative '../excep/password'
require_relative '../excep/playlist'
require_relative 'dbbase'

class UserDb < DbBase
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

        sql = %{ INSERT into users (username, pass)
                 VALUES ($1, $2) }.gsub(/\s+/, " ").strip
        begin
            @conn.prepare('add_user1', sql)
            @conn.exec_prepared('add_user1', [ user, cryptedpass ])
            @conn.close if @conn
        rescue PG::Error => e
            res = e.result
            Log.log.error "Problem saving new user: #{e}"
            @conn.close if @conn
        end

    end
end

