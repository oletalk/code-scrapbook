# frozen_string_literal: true

require 'securerandom'
# require 'base64'
require_relative 'db'
require_relative '../data/doctype'
require_relative '../data/document'
require_relative '../constants'

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
          s = Sender.new(result_row['sender_id'], nil)
          s.name = result_row['sender_name']
          ret = Document.new(
            result_row['id'], nil,
            result_row['received_date'], dt, s
          )
          ret.fill_out_from(result_row)
          next unless result_row['sender_account_id']

          sa_id = result_row['sender_account_id']
          sa_an = result_row['acdcount_number']
          sa = SenderAccount.new(sa_id, sa_an)
          ret.sender_account = sa
        end
      end
    end
    ret
  end

  def fetch_documents
    ret = []
    connect_for('fetching all documents') do |conn|
      sql = File.read('./sql/fetch_all_documents.sql')
      conn.exec(sql) do |result|
        result.each do |result_row|
          dt = DocType.new(result_row['doc_type_id'], result_row['doc_type_name'])
          s = Sender.new(result_row['sender_id'], nil)
          s.name = result_row['sender_name']
          doc = Document.new(
            result_row['id'], nil,
            result_row['received_date'], dt, s
          )
          doc.fill_out_from(result_row)
          ret.push(doc)
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
      docroot = Bills::Config::File::DOC_ROOT
      file_loc = "#{docroot}/#{floc}"

      begin
        File.delete(file_loc)
      rescue StandardError => e
        ret = { result: e.to_s }
      end

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
        puts 'file not found!'
      else
        ret = floc
      end
    end

    if floc.nil?
      puts "no file location for document id #{doc_id} found"
    else
      docroot = Bills::Config::File::DOC_ROOT
      ret = "#{docroot}/#{floc}"
      puts "file location is #{ret}"
    end
    ret
  end

  def upload_file(doc_id, file_name, file_contents, mode)
    # mode is 'stream' (file contents) or 'copy' (from temp file)
    # (id, fileupload['filename'], fileupload['tempfile'])

    ret = { result: 'success' }

    docroot = Bills::Config::File::DOC_ROOT
    newbasename1 = SecureRandom.urlsafe_base64(4)
    newbasename2 = File.extname(file_name)
    filelocation = "#{doc_id}/#{newbasename1}#{newbasename2}"
    filename = "#{docroot}/#{filelocation}"
    puts "new file to be saved in #{filename}"
    sql = 'update bills.document set file_location = $1 where id = $2'

    # create the subfolder in the doc root and then
    # write the file to the document root
    begin
      Dir.mkdir("#{docroot}/#{doc_id}/") unless File.exist?("#{docroot}/#{doc_id}/")
      # File.binwrite(filename, file_contents)
      case mode
      when 'stream'
        File.open(filename, 'wb') do |f|
          f.write(file_contents)
        end
      when 'copy'
        FileUtils.cp(file_contents, filename)
      else
        raise "unknown mode #{mode} - should be stream or raise"
      end
    rescue StandardError => e
      ret = { result: e.to_s }
    end

    # record this file location in the database
    if ret[:result] == 'success'
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
    str.empty? ? nil : str
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
                           doc.sender_account.nil? ? nil : doc.sender_account.id,
                           doc.summary,
                           doc.id
                         ])
    rescue StandardError => e
      ret = { result: e.to_s }
    end
    ret
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
