# frozen_string_literal: true

module Bills
  module Config
    module Db
      SERVER_HOST = '192.168.0.3'
      NAME = 'postgres'
      USER = 'web'
      PASSWORD = File.read('config/db_pw.txt').chomp
    end

    module Sftp
      SERVER_HOST = '192.168.1.3'
      USER = 'billsdb'
      REMOTE_ROOT = '/home/db/docs'
      PASSWORD = File.read('config/sftp_pw.txt').chomp
    end

    module File
      DOC_ROOT = '/Users/colin/docs'
    end
  end
end
