module MP3S
    module Config
        WEB_ROOT = './public'
        MP3_ROOT = '/opt/gulfport/mp3'
        SERVER_HOST = '0.0.0.0'
        SERVER_PORT = 2345
	    DB_NAME = 'maindb'
	    DB_USER = 'web'
        CACHE_SECS = 259200
        PLAY_RAW = '/bin/cat XXXX'
        PLAY_DOWNSAMPLED_MP3 = '/usr/local/bin/lame --nohist --mp3input -b 32 XXXX - '
	    PLAY_DOWNSAMPLED_OGG = '/usr/local/bin/sox -t ogg XXXX -t raw - | oggenc --raw --downmix -b 64 - '
        # PLAY_DOWNSAMPLED_OGG = '/usr/local/bin/ffmpeg -loglevel quiet -i XXXX -acodec libvorbis -f ogg -ac 2 -ab 64k - < /dev/null'
		RSC = 'BCE$21^&'
        LOGFILE = '/var/tmp/streamserver.log'
    end
end
