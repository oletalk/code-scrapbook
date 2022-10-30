# frozen_string_literal: true

require 'pg'
require_relative '../constants'

# standard database utility class.
module Db
  def connect_for(_description)
    conn = new_connection
    conn.transaction do
      # pass the connection to the block being called
      # so it can use conn.exec and result processing here
      yield conn
    end
  rescue StandardError => e
    puts e.message
  ensure
    conn&.close # i.e., "conn.close if conn" (Style/SafeNavigation)
  end

  def new_connection
    PG.connect(host: MP3S::Config::Db::SERVER_HOST, dbname: MP3S::Config::Db::NAME,
               user: MP3S::Config::Db::USER, password: MP3S::Config::Db::PASSWORD)
  end
end
