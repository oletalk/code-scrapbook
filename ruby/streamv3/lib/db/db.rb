# frozen_string_literal: true

require 'pg'
require_relative '../constants'

# standard database utility class.
module Db
  def connect_for(description)
    conn = new_connection
    conn.transaction do |conn2|
      # pass the connection to the block being called
      # so it can use conn.exec and result processing here
      yield conn2
    end
  rescue StandardError => e
    puts "problem connecting for #{description}"
    puts e.message
    puts e.backtrace
  ensure
    conn&.close # i.e., "conn.close if conn" (Style/SafeNavigation)
  end

  def new_connection
    PG.connect(host: MP3S::Config::Db::SERVER_HOST, dbname: MP3S::Config::Db::NAME,
               user: MP3S::Config::Db::USER, password: MP3S::Config::Db::PASSWORD)
  end

  def check_db
    begin
      conn = new_connection
      conn.exec('select 1')
      puts 'database test ok'
    rescue StandardError => e
      raise 'problem with database connection'
    ensure
      conn&.close
    end
  end

end
