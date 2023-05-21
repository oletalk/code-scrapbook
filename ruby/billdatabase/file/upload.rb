# frozen_string_literal: true

require 'securerandom'
require_relative '../constants'
require_relative '../util/logging'

# module for uploading/downloading files (use in dochandler)
module Upload
  def remove_file(file_location_in_db)
    ret = true
    docroot = Bills::Config::File::DOC_ROOT
    file_loc = "#{docroot}/#{file_location_in_db}"

    begin
      File.delete(file_loc)
    rescue StandardError => e
      log_error "Problem deleting file: #{e}"
      ret = false
    end
    ret
  end

  def download_file_location(file_location_in_db)
    docroot = Bills::Config::File::DOC_ROOT
    "#{docroot}/#{file_location_in_db}"
  end

  def upload_file_to_filesystem(doc_id, file_name, file_contents)
    ret = {
      filename: nil,
      result: 'success'
    }

    docroot = Bills::Config::File::DOC_ROOT
    newbasename1 = SecureRandom.urlsafe_base64(4)
    newbasename2 = File.extname(file_name)
    filelocation = "#{doc_id}/#{newbasename1}#{newbasename2}"
    filename = "#{docroot}/#{filelocation}"
    log_info "new file to be saved in #{filename}"
    ret[:filename] = filelocation
    begin
      Dir.mkdir("#{docroot}/#{doc_id}/") unless File.exist?("#{docroot}/#{doc_id}/")
      # File.binwrite(filename, file_contents)

      log_info "Source tempfile path: #{file_contents.path}"
      log_info "Source: #{file_contents.path} -> Target: #{filename}"
      FileUtils.cp(file_contents.path, filename)
    rescue StandardError => e
      log_error "Error: #{e}"
      ret[:result] = e
    end
    ret
  end
end
