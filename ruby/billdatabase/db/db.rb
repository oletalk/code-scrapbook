# frozen_string_literal: true

require 'pg'
require_relative '../constants'

# standard database utility class.
module Db
  def connect_for(description)
    conn = new_connection
    conn.transaction do
      # pass the connection to the block being called
      # so it can use conn.exec and result processing here
      yield conn
    end
  rescue StandardError => e
    puts "problem connecting for #{description}"
    puts e.message
  ensure
    conn&.close # i.e., "conn.close if conn" (Style/SafeNavigation)
  end

  def new_connection
    PG.connect(host: Bills::Config::Db::SERVER_HOST, dbname: Bills::Config::Db::NAME,
               user: Bills::Config::Db::USER, password: Bills::Config::Db::PASSWORD)
  end
end
