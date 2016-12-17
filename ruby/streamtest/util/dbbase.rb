require 'pg'
require_relative 'config'

class DbBase

    def new_connection
        PG.connect(dbname: MP3S::Config::DB_NAME, user:  MP3S::Config::DB_USER)
    end

end
