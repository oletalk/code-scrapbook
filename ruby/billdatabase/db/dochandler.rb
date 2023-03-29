# frozen_string_literal: true

require_relative 'db'
require_relative '../data/doctype'

# fetches document information from the db
class DocHandler
  include Db

  def fetch_doctypes
    ret = []
    connect_for('fetching all document types') do |conn|
      sql = 'select id, name from bills.doc_type order by name'
      conn.exec(sql) do |result|
        result.each do |result_row|
          ret.push(DocType.new(result_row['id'], result_row['name']))
        end
      end
    end
    ret
  end
end
