module MP3S
    module Config
        WEB_ROOT = './public'
        MP3_ROOT = '/opt/gulfport/mp3'
        SERVER_HOST = '0.0.0.0'
        SERVER_PORT = 2345
	    DB_NAME = 'maindb'
	    DB_USER = 'web'
        PLAY_RAW = 'cat XXXX'
        PLAY_DOWNSAMPLED_MP3 = '/usr/local/bin/lame --mp3input -b 32 XXXX - '
	PLAY_DOWNSAMPLED_OGG = '/usr/local/bin/ffmpeg -loglevel quiet -i XXXX -acodec libvorbis -f ogg -ac 2 -ab 64k - < /dev/null'
    end
end