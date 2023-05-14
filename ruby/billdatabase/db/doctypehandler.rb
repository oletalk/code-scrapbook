# frozen_string_literal: true

require_relative 'db'
require_relative '../data/doctype'

# fetches document type information from the db
class DocTypeHandler
  include Db

  # doctypes
  def update_doctype(id)
    ret = { result: 'success' }
    sql = 'UPDATE bills.doc_type SET name = $1 WHERE id = $1'
    connect_for('updating a doctype') do |conn|
      conn.prepare('upd_doctype', sql)
      conn.exec_prepared('upd_doctype', [id])
    rescue StandardError => e
      ret = { result: e.to_s }
    end
    ret
  end

  def add_doctype(name)
    ret = { result: 'success' }
    sql = 'INSERT INTO bills.doc_type(name) VALUES ($1)'
    connect_for('adding a doctype') do |conn|
      conn.prepare('add_doctype', sql)
      conn.exec_prepared('add_doctype', [name])
    rescue StandardError => e
      ret = { result: e.to_s }
    end
    ret
  end

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
