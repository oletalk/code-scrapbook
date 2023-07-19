# frozen_string_literal: true

require 'net/sftp'
require_relative '../constants'
require_relative './player'

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
    unless File.exists?(tempfile)
      puts "#{tempfile} not found. downloading and downsampling."
      sftp = Net::SFTP.start(MP3S::Config::Sftp::SERVER_HOST, MP3S::Config::Sftp::USER, password: MP3S::Config::Sftp::PASSWORD)
    
      # f = File.open(@file, "rb")
      sftp.download!(ftpfile, tempfile)
      time_end_download = Time.now
      puts "Download completed in #{time_end_download - time_start} seconds."

      # TODO - do we want to make downsampling optional?
      p = Player.new
      p.play_downsampled(tempfile)
    else
      puts 'we already have cached file'
      f = File.open(tempfile)
      f.read
    end
  end
  
end
