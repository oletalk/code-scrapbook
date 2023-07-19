# frozen_string_literal: true

module MP3S
  module Config
    module Db
      SERVER_HOST = '192.168.0.2'
      NAME = 'postgres'
      USER = 'web'
      PASSWORD = File.read('config/db_pw.txt').chomp
    end
    
    module Sftp
      SERVER_HOST = '192.168.1.3'
      USER = 'andr0id'
      PASSWORD = File.read('config/sftp_pw.txt').chomp
    end

    module Cache
      TEMP_ROOT = '/var/tmp/files'
      MAX_SIZE = '100M'
    end
  end
end
