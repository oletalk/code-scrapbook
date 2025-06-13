# frozen_string_literal: true

require 'digest/sha1'
require 'net/sftp'
# require 'stringio'
require 'securerandom'
require_relative '../constants'
require_relative '../util/logging'

# module for uploading/downloading files from a remote SFTP server (use in dochandler)
module Sftp
  def download_remote_file_location(file_location_in_db)
    docroot = Bills::Config::Sftp::REMOTE_ROOT
    "#{docroot}/#{file_location_in_db}"
  end

  def upload_file_to_remote(doc_id, file_name, file_contents)
    ret = {
      filename: nil,
      result: 'success'
    }

    docroot = Bills::Config::Sftp::REMOTE_ROOT
    newbasename1 = SecureRandom.urlsafe_base64(4)
    newbasename2 = File.extname(file_name)
    filelocation = "#{doc_id}/#{newbasename1}#{newbasename2}"
    filename = "#{docroot}/#{filelocation}"
    log_info "new file to be saved in #{filename}"
    ret[:filename] = filelocation
    # and save
    begin
      log_info 'logging into remote server'
      sftp = new_sftp_connection
      log_info 'login complete.'
      # io = StringIO.new(file_contents)
      localfile = file_contents.path
      log_info "remotefile = #{filename}"
      # check dir is there first
      fdir = File.dirname(filename)
      sftp.mkdir(fdir, permissions: 0o0550).wait
      sftp.upload!(localfile, filename)
    rescue StandardError => e
      log_error "Error: #{e}"
      ret[:result] = e
    end
    ret
  end

  def sftp_file_location(file_location_in_db)
    docroot = Bills::Config::Sftp::REMOTE_ROOT
    "#{docroot}/#{file_location_in_db}"
  end

  def file_contents(remoteurl)
    log_info "remote location = #{remoteurl}"
    log_info 'logging into remote server'
    sftp = new_sftp_connection
    log_info 'login complete.'
    dirhash = Digest::SHA1.hexdigest(File.dirname(remoteurl))
    bname = File.basename(remoteurl)
    fname1 = "/tmp/bdb_#{dirhash}_#{bname}"
    begin
      sftp.download!(remoteurl, fname1) do |event, _downloader, *args|
        case event
        when :open
          log_info '   ## starting download'
        when :finish
          log_info '   ## complete'
        end
      end
    rescue Exception => e
      log_error 'SFTP download failed'
      log_error e.message
      fname1 = 'DOWNLOAD_FAILED'
    end

    fname1
  end

  def delete_remote(file_location_in_db)
    ret = true
    docroot = Bills::Config::Sftp::REMOTE_ROOT
    file_loc = "#{docroot}/#{file_location_in_db}"

    sftp = new_sftp_connection

    begin
      sftp.remove(file_loc).wait
    rescue StandardError => e
      log_error "Problem deleting file: #{e}"
      ret = false
    end
    ret
  end

  def new_sftp_connection
    Net::SFTP.start(
      Bills::Config::Sftp::SERVER_HOST, Bills::Config::Sftp::USER,
      password: Bills::Config::Sftp::PASSWORD
    )
  end
end
