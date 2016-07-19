require 'shellwords'
require 'open3'
require_relative 'config'
require_relative 'logging'

module Player

    def self.play_song(command, song)
        escaped = Shellwords.escape( song )
        escaped.gsub!(/\'/, %q(\\\'))
        escaped.gsub!(/\&/, %q(\\\&))

        cmdexec = command.sub(/XXXX/, escaped)
        Log.log.info("Command to send: #{cmdexec}")
        stdout, stderr, status = Open3.capture3("#{cmdexec}", binmode: true)
        { songdata: stdout, command: cmdexec, warnings: stderr }
    end

    def self.get_command(downsample, song)
        if downsample
            # check if downsampling mp3/ogg
            if ( song =~ /mp3$/i )
                command = MP3S::Config::PLAY_DOWNSAMPLED_MP3
            elsif ( song =~ /ogg$/i )
                command = MP3S::Config::PLAY_DOWNSAMPLED_OGG
            else
                Log.log.error ("No idea how to downsample given file type #{song}")
                command = nil
            end
        else
            command = MP3S::Config::PLAY_RAW
        end
        command
    end
end