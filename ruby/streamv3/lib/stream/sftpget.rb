# frozen_string_literal: true

require 'net/sftp'
require_relative '../constants'
require_relative '../common/logging'


# mixin to separate out SFTP code
module SftpGet
  include Logging

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
