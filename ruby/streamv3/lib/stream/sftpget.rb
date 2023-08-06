# frozen_string_literal: true

require 'net/sftp'
require_relative '../constants'
require_relative '../common/logging'

GROUP = 5

# mixin to separate out SFTP code
module SftpGet
  include Logging

  def sftpbulkget(filelist, destdir)
    logger.info 'Logging into server'
    sftp = Net::SFTP.start(
      MP3S::Config::Sftp::SERVER_HOST, MP3S::Config::Sftp::USER,
      password: MP3S::Config::Sftp::PASSWORD
    )
    logger.info 'Login complete.'

    @ctr = 0
    @total = filelist.length
    dls = filelist.map do |file|
      bn = File.basename(file)
      destfile = "#{destdir}/#{bn}"
      logger.debug "Starting download #{file} --> #{destfile}"
      sftp.download(file, destfile) do |event, _downloader, _args|
        case event
        when :finish
          @ctr += 1
          logger.debug "[progress] #{@@ctr} / #{@@total} complete." if (@ctr % GROUP).zero?
        end
      end
    end
    # dls.each { |d| d.wait }
    dls.each(&:wait)
    logger.info 'Downloads complete.'
  end

  def sftpget(remotefile, localfile)
    sftp = Net::SFTP.start(
      MP3S::Config::Sftp::SERVER_HOST, MP3S::Config::Sftp::USER,
      password: MP3S::Config::Sftp::PASSWORD
    )

    # f = File.open(@file, "rb")
    sftp.download!(remotefile, localfile) do |event, _downloader, *args|
      case event
      when :open
        logger.debug "  ## starting download from #{args[0].remote}"
      # when :get then <-- further detail, progress
      when :close
        logger.debug "  ## finished with #{args[0].remote}"
      when :finish
        logger.debug '  ## complete'
      end
    end
  end
end
