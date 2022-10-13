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
    conn&.close # conn.close if conn (Style/SafeNavigation)
  end

  def new_connection
    PG.connect(dbname: MP3S::Config::Db::NAME, user: MP3S::Config::Db::USER)
  end
end
