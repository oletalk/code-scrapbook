# frozen_string_literal: true

require_relative 'db'
require_relative '../data/doctype'
require_relative '../data/document'

# fetches document information from the db
class DocHandler
  include Db

  def fetch_document(id)
    ret = {}
    connect_for('fetching a document') do |conn|
      sql = File.read('./sql/fetch_document.sql')
      conn.prepare('fetch_document', sql)
      conn.exec_prepared('fetch_document', [id]) do |result|
        result.each do |result_row|
          dt = DocType.new(result_row['doc_type_id'], result_row['doc_type_name'])
          s = Sender.new(result_row['sender_id'], result_row['sender_name'])
          ret = Document.new(
            result_row['id'], nil,
            result_row['received_date'], dt, s
          )
        end
      end
    end
    ret
  end

  def fetch_documents
    ret = []
    connect_for('fetching all documents') do |conn|
      sql = 'select id, received_date, doc_type_id, sender_id, due_date, paid_date, '\
      'file_location, comments, sender_account_id from bills.document'
      conn.exec(sql) do |result|
        result.each do |result_row|
          # TODO
        end
      end
    end
    ret
  end

  def add_document(doc)
    ret = nil
    raise TypeError, 'add_document expects a Document' unless doc.is_a?(Document)
    raise ArgumentError, 'supplied Document does not have a DocType' if doc.doc_type.nil?
    raise ArgumentError, 'supplied Document does not have a Sender' if doc.sender.nil?

    sql = 'INSERT into bills.document (received_date, doc_type_id, sender_id, due_date,'\
    'paid_date, file_location, comments, sender_account_id) values ($1, $2, $3, $4, $5,'\
    '$6, $7, $8) returning id'
    connect_for('adding a document') do |conn|
      conn.prepare('add_document', sql)
      conn.exec_prepared('add_document', [
                           doc.received_date,
                           doc.doc_type.id, # check?
                           doc.sender.id, # check?
                           nil_if_empty(doc.due_date),
                           nil_if_empty(doc.paid_date),
                           doc.file_location,
                           doc.comments,
                           doc.sender_account.nil? ? nil : doc.sender_account.id

                         ]) do |result|
        result.each do |result_row|
          ret = result_row['id']
        end
      end
    rescue StandardError => e
      ret = { result: e.to_s }
    end

    puts "new id returned: #{ret}"
    ret
  end

  def nil_if_empty(str)
    str.empty? ? nil : str
  end

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
