# frozen_string_literal: true

require_relative '../stream/sftpget'

# utility to copy a list of files from the SFTP store
class CopyFromSftp
  include SftpGet

  def self.main
    puts 'hello world'
  end
end

CopyFromSftp.main
