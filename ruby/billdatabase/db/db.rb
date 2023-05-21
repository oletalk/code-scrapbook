# frozen_string_literal: true

require 'pg'
require_relative '../constants'
require_relative '../util/logging'

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
    log_error "problem connecting for #{description}"
    raise e
  ensure
    conn&.close # i.e., "conn.close if conn" (Style/SafeNavigation)
  end

  def new_connection
    PG.connect(host: Bills::Config::Db::SERVER_HOST, dbname: Bills::Config::Db::NAME,
               user: Bills::Config::Db::USER, password: Bills::Config::Db::PASSWORD)
  end
end
