# frozen_string_literal: true

module Bills
  module Config
    module Db
      SERVER_HOST = '192.168.0.2'
      NAME = 'postgres'
      USER = 'web'
      PASSWORD = File.read('config/db_pw.txt').chomp
    end
  end
end
