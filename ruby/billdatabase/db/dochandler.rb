# frozen_string_literal: true

# require 'securerandom'
# require 'base64'
require_relative 'db'
require_relative '../util/logging'
require_relative '../file/upload'
require_relative '../data/doctype'
require_relative '../data/document'
require_relative '../data/mappers/documentmapper'

# fetches document information from the db
class DocHandler
  include Upload
  include Db
  include Logging

  def fetch_document(id)
    ret = {}
    connect_for('fetching a document') do |conn|
      sql = File.read('./sql/fetch_document.sql')
      conn.prepare('fetch_document', sql)
      conn.exec_prepared('fetch_document', [id]) do |result|
        ret = DocumentMapper.new.create_from_result(result)[0]
      end
    end
    ret
  end

  def fetch_documents(d_from, d_to)
    ret = []
    today = Time.now.strftime('%Y-%m-%d')
    date_from = d_from.nil? ? '1970-01-01' : d_from
    date_to = d_to.nil? ? today : d_to
    log_info "fetching documents from #{date_from} to #{date_to}"
    connect_for('fetching all documents') do |conn|
      sql = File.read('./sql/fetch_all_documents.sql')
      conn.prepare('fetch_docs', sql)
      conn.exec_prepared('fetch_docs', [date_from, date_to]) do |result|
        ret = DocumentMapper.new.create_from_result(result)
      end
    end
    ret
  end

  def fetch_sender_documents(sender_id)
    ret = []
    log_info "fetching documents for sender #{sender_id}"
    connect_for('fetching documents for sender') do |conn|
      sql = File.read('./sql/fetch_sender_documents.sql')
      conn.prepare('fetch_senderdocs', sql)
      conn.exec_prepared('fetch_senderdocs', [sender_id]) do |result|
        ret = DocumentMapper.new.create_from_result(result)
      end
    end
    ret
  end

  def add_document(doc)
    ret = nil
    raise TypeError, 'add_document expects a Document' unless doc.is_a?(Document)
    raise ArgumentError, 'supplied Document does not have a DocType' if doc.doc_type.nil?
    raise ArgumentError, 'supplied Document does not have a Sender' if doc.sender.nil?

    sql = File.read('./sql/insert_document.sql')
    connect_for('adding a document') do |conn|
      conn.prepare('add_document', sql)
      conn.exec_prepared('add_document', [
                           doc.received_date,
                           doc.doc_type.id,
                           doc.sender.id,
                           doc.summary,
                           nil_if_empty(doc.due_date),
                           nil_if_empty(doc.paid_date),
                           doc.file_location,
                           doc.comments,
                           doc.sender_account&.id

                         ]) do |result|
        result.each do |result_row|
          ret = result_row['id']
        end
      end
    rescue StandardError => e
      ret = { result: e.to_s }
    end

    log_info "new id returned: #{ret}"
    ret
  end

  def delete_file(doc_id)
    ret = { result: 'success' }
    floc = nil
    connect_for('fetching file location for the document') do |conn|
      sql = 'select file_location from bills.document where id = $1'
      conn.prepare('fetch_file_location', sql)
      conn.exec_prepared('fetch_file_location', [doc_id]) do |result|
        result.each do |result_row|
          floc = result_row['file_location']
        end
      end
    end
    if floc.nil?
      ret = { result: 'file not found' }
    else
      # remove file
      remove_file(floc)

      # remove database entry
      connect_for('updating file location for deleted document') do |conn|
        sql = 'update bills.document set file_location = null where id = $1'
        conn.prepare('upd_file_location', sql)
        conn.exec_prepared('upd_file_location', [doc_id])
      end
    end
    ret
  end

  def download_file(doc_id)
    floc = nil
    ret = nil
    # so far can't think of why you'd want > 1 file per document
    connect_for('fetching file location for the document') do |conn|
      sql = 'select file_location from bills.document where id = $1'
      conn.prepare('fetch_file_location', sql)
      conn.exec_prepared('fetch_file_location', [doc_id]) do |result|
        result.each do |result_row|
          floc = result_row['file_location']
        end
      end
      if floc.nil?
        log_error 'file not found!'
      else
        ret = download_file_location(floc)
      end
    end

    log_error "no file location for document id #{doc_id} found" if floc.nil?
    ret
  end

  def upload_file(doc_id, file_name, file_contents)
    ret = { result: 'success' }

    sql = 'update bills.document set file_location = $1 where id = $2'

    # create the subfolder in the doc root and then
    # write the file to the document root
    res = upload_file_to_filesystem(doc_id, file_name, file_contents)

    # record this file location in the database
    log_info res
    if res[:result] == 'success'
      filelocation = res[:filename]
      connect_for('updating a document with the filename') do |conn|
        conn.prepare('updfile_document', sql)
        conn.exec_prepared('updfile_document', [filelocation, doc_id])
      rescue StandardError => e
        ret = { result: e.to_s }
      end
    end

    ret
  end

  def nil_if_empty(str)
    str.nil? || str.empty? ? nil : str
  end

  def update_document(doc)
    ret = { result: 'success' }
    raise TypeError, 'add_document expects a Document' unless doc.is_a?(Document)
    raise ArgumentError, 'supplied Document does not have a DocType' if doc.doc_type.nil?
    raise ArgumentError, 'supplied Document does not have a Sender' if doc.sender.nil?

    sql = File.read('./sql/update_document.sql')
    connect_for('updating a document') do |conn|
      conn.prepare('upd_document', sql)
      conn.exec_prepared('upd_document',
                         [
                           doc.received_date,
                           nil_if_empty(doc.due_date),
                           nil_if_empty(doc.paid_date),
                           doc.comments,
                           doc.sender_account&.id,
                           doc.summary,
                           doc.id
                         ])
    rescue StandardError => e
      ret = { result: e.to_s }
    end
    ret
  end
end
