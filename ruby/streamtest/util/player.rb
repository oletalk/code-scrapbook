require 'shellwords'
require 'open3'
require 'logger'

module Player

    def self.play_song(command, song)
        escaped = Shellwords.escape( song )
        escaped.gsub!(/\'/, %q(\\\'))

        cmdexec = command.sub(/XXXX/, escaped)
        $logger = Logger.new(STDOUT)
        $logger.info("Command to send: #{cmdexec}")
        stdout, stderr, status = Open3.capture3("#{cmdexec}", binmode: true)
        { songdata: stdout, command: cmdexec, warnings: stderr }
    end
end
