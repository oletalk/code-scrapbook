# frozen_string_literal: true

require_relative 'db'
# fetches document information from the db
class PmtHandler
  include Db

  def fetch_payments
    ret = []
    sql = File.read('./sql/fetch_due_payments.sql')
    connect_for('reading a list of payments') do |conn|
      conn.exec(sql) do |result|
        result.each do |result_row|
          ret.push(
            {
              name: result_row['name'],
              summary: result_row['summary'],
              due_date: result_row['due_date'],
              paid_date: result_row['paid_date'],
              document_id: result_row['document_id'],
              status: result_row['status']
            }
          )
        end
      end
    end
    ret
  end
end
