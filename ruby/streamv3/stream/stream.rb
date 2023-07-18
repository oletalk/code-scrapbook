# frozen_string_literal: true

require 'net/sftp'
require_relative '../constants'

# A class for handling streaming from a file
class SongStream
  def initialize(filename)
    @file = filename
  end

  def readall
    ftpfile = @file.sub(/\/opt\/gulfport/, '/rockport')
    time_start = Time.now
    # TODO - something better than dumping all the mp3s over the lifetime of the process in 1 big dir!
    tempfile = "#{MP3S::Config::Cache::TEMP_ROOT}/#{File.basename(ftpfile)}"
    sftp = Net::SFTP.start(MP3S::Config::Sftp::SERVER_HOST, MP3S::Config::Sftp::USER, password: MP3S::Config::Sftp::PASSWORD)
    
    # f = File.open(@file, "rb")
    sftp.download!(ftpfile, tempfile)
    time_end = Time.now
    puts "Download completed in #{time_end - time_start} seconds."
    f = File.open(tempfile)
    f.read
  end
  
end
