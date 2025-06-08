# frozen_string_literal: true

require 'net/sftp'
require 'securerandom'
require_relative '../constants'
require_relative '../util/logging'

# module for uploading/downloading files from a remote SFTP server (use in dochandler)
module Sftp
  def remove_remote_file(file_location_in_db)
    ret = false
    puts 'NOT YET SUPPORTED'
    ret
  end

  def download_remote_file_location(file_location_in_db)
    docroot = Bills::Config::Sftp::REMOTE_ROOT
    "#{docroot}/#{file_location_in_db}"
  end

  def upload_file_to_remote(doc_id, file_name, file_contents)
    ret = {
      filename: nil,
      result: 'success'
    }

    docroot = Bills::Config::File::REMOTE_ROOT
    ret
  end

  def sftp_file_location(file_location_in_db)
    docroot = Bills::Config::Sftp::REMOTE_ROOT
    "#{docroot}/#{file_location_in_db}"
  end

  def file_contents(remoteurl)
    log_info 'logging into remote server'
    sftp = Net::SFTP.start(
      Bills::Config::Sftp::SERVER_HOST, Bills::Config::Sftp::USER,
      password: Bills::Config::Sftp::PASSWORD
    )
    log_info 'login complete.'
    # FIXME: - use tempfile or something else not hardcoded
    sftp.download!(remoteurl, '/tmp/filefile111') do |event, _downloader, *args|
      case event
      when :open
        log_info '   ## starting download'
      when :finish
        log_info '   ## complete'
      end
    end
  end
end
