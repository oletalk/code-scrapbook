require 'shellwords'
require 'open3'
require_relative 'config'
require_relative 'logging'

class Player

    def play_song(command, song)
        escaped = Shellwords.escape( song )
        escaped.gsub!(/\'/, %q(\\\'))
        escaped.gsub!(/\&/, %q(\\\&))

        cmdexec = command.sub(/XXXX/, escaped)
        Log.log.info("Command to send: #{cmdexec}")
        stdout, stderr, status = Open3.capture3("#{cmdexec}", binmode: true)
        Log.log.info("return status: #{status}, stdout.length = #{stdout.length}, stderr.length = #{stderr.length}")
        puts stderr if stderr
        { songdata: stdout, command: cmdexec, warnings: stderr }
    end

    def get_command(downsample, song)
        if downsample
            # check if downsampling mp3/ogg
            if ( song =~ /mp3$/i )
                command = MP3S::Config::Play::DOWNSAMPLED_MP3
            elsif ( song =~ /ogg$/i )
                command = MP3S::Config::Play::DOWNSAMPLED_OGG
            else
                Log.log.error ("No idea how to downsample given file type #{song}")
                command = nil
            end
        else
            command = MP3S::Config::Play::RAW
        end
        command
    end
end
