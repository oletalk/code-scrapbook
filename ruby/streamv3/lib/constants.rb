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
      LAME_CMD = `which lame`.strip
      SOX_CMD = `which sox`.strip
      DOWNSAMPLED_MP3 = LAME_CMD << ' --nohist --mp3input -b 32 XXXX - '
      DOWNSAMPLED_OGG = SOX_CMD << ' -t ogg XXXX -t raw - | oggenc --raw --downmix -b 64 - '
    end
  end
end
