# frozen_string_literal: true

module MP3S
  module Config
    module Db
      SERVER_HOST = '192.168.0.3'
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
      CACHE_INTERVAL_SECS = 300
      MAX_SIZE = '100M'
    end

    module Play
      RAW = '/bin/cat XXXX'
      DOWNSAMPLED_MP3 = '/usr/local/bin/lame --nohist --mp3input -b 32 XXXX - '
      DOWNSAMPLED_OGG = '/usr/local/bin/sox -t ogg XXXX -t raw - | oggenc --raw --downmix -b 64 - '
    end
  end
end
