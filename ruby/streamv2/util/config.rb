module MP3S
    module Config
        module Net
          WEB_ROOT = './public'
          MP3_ROOT = '/opt/gulfport/mp3'
          SERVER_HOST = '0.0.0.0'
          SERVER_PORT = 2345
        end
        module DB
          SERVER_HOST = '192.168.0.2'
          SERVER_PORT = 2351
    	    NAME = 'postgres'
    	    USER = 'web'
        end
        module Play
          RAW = '/bin/cat XXXX'
          DOWNSAMPLED_MP3 = '/usr/local/bin/lame --nohist --mp3input -b 32 XXXX - '
	        DOWNSAMPLED_OGG = '/usr/local/bin/sox -t ogg XXXX -t raw - | oggenc --raw --downmix -b 64 - '
          # PLAY_DOWNSAMPLED_OGG = '/usr/local/bin/ffmpeg -loglevel quiet -i XXXX -acodec libvorbis -f ogg -ac 2 -ab 64k - < /dev/null'
		    end
		    module Misc
          DATE_FORMAT = '%a %-d %b, %I:%M %P'
          SHARED_SECRET = 'stuff'
		      RSC = 'BCE$21^&'
          LOGFILE = '/var/tmp/streamer_server.log'
          DB_LOGFILE = '/var/tmp/db_server.log'
        end
    end
end
