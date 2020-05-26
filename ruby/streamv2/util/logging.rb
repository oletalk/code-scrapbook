require_relative 'config'
require 'logger'

class Log
    def self.log
        if @logger.nil?
            logfile_loc = MP3S::Config::Misc::LOGFILE
            if logfile_loc.nil?
                @logger = Logger.new STDOUT
            else
                @logger = Logger.new( logfile_loc )
            end
            @logger.level = Logger::INFO # TODO: make configurable
        end
        @logger
    end

    def self.init(file_loc)
      @logger = Logger.new( file_loc )
    end
end
