# frozen_string_literal: true

require 'json'
require 'sinatra/base'
require_relative 'util/date_util'
require_relative 'db/dochandler'
require_relative 'db/doctypehandler'
require_relative 'db/senderhandler'
require_relative 'db/pmthandler'
require_relative 'data/sender'
require_relative 'data/senderaccount'
require_relative 'constants'
require_relative 'util/logging'

# main app
class BillDatabase < Sinatra::Base
  include DateUtil
  include Logging
  # writing functionality
  # 1. write or add method to write to db in a handler
  # 2. add method that accesses handler here VV
  # 3. add method in entity.js (or wherever) that does axios call to this
  # 4. add element in erb that calls that method in js

  configure do
    set :root, File.dirname(__FILE__)
  end

  before do
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Accept, Authorization, Origin'
    content_type 'text/html'
  end

  get '/' do
    redirect '/spa/index.html'
  end

  get '/main' do
    erb :main
  end

  get '/documents' do
    dh = DocHandler.new
    @documents = dh.fetch_documents(nil, nil)
    @documents.to_json
  end

  get '/documents/:fromdate/:todate' do |fromdate, todate|
    if check_ymd(fromdate) && check_ymd(todate)
      dh = DocHandler.new
      @documents = dh.fetch_documents(fromdate, todate)
      @documents.to_json
    else
      { 'error': 'dates not formatted correctly' }
    end
  end

  get '/document_new' do
    dh = DocTypeHandler.new
    sh = SenderHandler.new
    @doctypes = dh.fetch_doctypes
    @senders = sh.fetch_senders
    erb :document_new
  end

  post '/document_new' do
    # the photo/pdf should probably be handled separately
    params = JSON.parse(request.body.read)
    dt = DocType.new(params['doc_type_id'], nil)
    s = Sender.new(params['sender_id'], nil)
    sa_p = params['sender_account_id']
    sa = sa_p.nil? || sa_p.empty? ? nil : SenderAccount.new(sa_p, nil)
    d = Document.new(nil, nil, params['received_date'], dt, s)
    d.summary = params['summary']
    d.due_date = params['due_date']
    d.paid_date = params['paid_date']
    d.comments = params['comments']
    d.sender_account = sa unless sa.nil?
    dh = DocHandler.new
    new_id = dh.add_document(d)
    if new_id.instance_of?(Hash)
      # uh - oh
      log_info new_id
      ret = new_id
    else
      ret = { 'id': new_id }
    end

    ret.to_json
  end

  post '/document/:id' do |id|
    params = JSON.parse(request.body.read)
    dt = DocType.new(params['doc_type_id'], nil)
    s = Sender.new(params['sender_id'], nil)
    sa_p = params['sender_account_id']
    sa = sa_p.nil? || sa_p.empty? ? nil : SenderAccount.new(sa_p, nil)
    d = Document.new(id, nil, params['received_date'], dt, s)
    d.summary = params['summary']
    d.due_date = params['due_date'] if params['due_date']
    d.paid_date = params['paid_date'] if params['paid_date']
    d.comments = params['comments']
    d.sender_account = sa unless sa.nil?
    dh = DocHandler.new
    ret = dh.update_document(d)
    puts ret.to_json
    ret.to_json
  end

  get '/document/:id' do |id|
    content_type 'text/html'

    d = DocHandler.new
    @doc = d.fetch_document(id)
    #   s = SenderHandler.new
    #   @sender = s.fetch_sender(@doc.sender.id)
    @doc.to_json
    #   erb :single_document
  end

  get '/document/:id/file' do |id|
    d = DocHandler.new
    doc = d.download_file(id)
    #       send_file(filename, :filename => "t.cer", :type => "application/octet-stream")
    fname = File.basename(doc)
    opts = {
      filename: fname,
      type: 'application/octet-stream'
    }
    if File.exist?(doc)
      content_type 'application/octet-stream'
      attachment fname

      send_file doc, opts: opts
    else
      'sorry, file link is broken'
    end
  end

  post '/document/:id/file' do |id|
    # this is no longer a JSON request as of 22/04/2023
    log_info "received file upload for document id #{id}"
    fileupload = params['file']
    # log_info fileupload['filename']
    # the FormData object in js seems to reassemble the file in a temp dir
    # inside of fileupload['tempfile'] so just copy it

    d = DocHandler.new
    ret = d.upload_file(id, fileupload['filename'], fileupload['tempfile'])
    ret.to_json
  end

  delete '/document/:id/file' do |id|
    log_info "received file #{params['name']} for document #{id}"

    d = DocHandler.new
    ret = d.delete_file(id)
    ret.to_json
  end

  get '/doctypes' do
    d = DocTypeHandler.new
    ret = d.fetch_doctypes
    ret.to_json
  end

  get '/senders_with_tags' do
    s = SenderHandler.new
    ret = s.fetch_senders_with_tags
    ret.to_json
  end

  get '/senders' do
    # CONVERTED
    s = SenderHandler.new
    ret = s.fetch_senders
    # erb :senders
    ret.to_json
  end

  get '/sender/:id' do |id|
    # CONVERTED
    s = SenderHandler.new
    # @sender = s.fetch_sender(id)
    # erb :single_sender
    ret = s.fetch_sender(id)
    ret.to_json
  end

  get '/sender_new' do
    erb :sender_new
  end

  post '/sender_new' do
    params = JSON.parse(request.body.read)
    s = SenderHandler.new
    sender = Sender.new(nil, nil)
    sender.name = params['name']
    sender.username = params['username']
    sender.password_hint = params['password_hint']
    sender.comments = params['comments']
    new_id = s.add_sender(sender)
    ret = { 'id': new_id }
    ret.to_json
  end

  post '/sender/:id' do |id|
    # if you use axios, params is empty!!
    params = JSON.parse(request.body.read)
    s = SenderHandler.new
    sender = Sender.new(id, nil)

    sender.username = params['username']
    sender.password_hint = params['password_hint']
    sender.comments = params['comments']
    s.update_sender(sender)
  end

  post '/sender/:id/account_new' do |id|
    params = JSON.parse(request.body.read)
    s = SenderHandler.new
    sa = SenderAccount.new(nil, id)
    sa.account_number = params['account_number']
    sa.account_details = params['account_details']
    sa.comments = params['comments']
    s.add_sender_account(sa)
  end

  post '/sender/:id/contact_new' do |id|
    params = JSON.parse(request.body.read)
    s = SenderHandler.new
    sc = SenderContact.new(nil, id)
    sc.name = params['name']
    sc.contact = params['contact']
    sc.comments = params['comments']
    s.add_sender_contact(sc)
  end

  post '/sendertag/:id/:tagid' do |id, tag_id|
    s = SenderHandler.new
    s.add_sender_tag(id, tag_id)
  end

  delete '/sendertag/:id/:tagid' do |id, tag_id|
    s = SenderHandler.new
    s.del_sender_tag(id, tag_id)
  end

  get '/sendercontacts' do
    s = SenderHandler.new
    @senders = s.fetch_all_contacts # contacts grouped by sender
    erb :contacts
  end

  delete '/senderaccount/:acc_id' do |acc_id|
    s = SenderHandler.new
    s.del_sender_account(acc_id)
  end

  post '/senderaccount/:acc_id' do |acc_id|
    params = JSON.parse(request.body.read)
    s = SenderHandler.new
    sa = SenderAccount.new(acc_id, nil) # don't need sender_id for update
    sa.account_number = params['account_number']
    sa.account_details = params['account_details']
    sa.closed = params['account_closed']
    sa.comments = params['comments']
    s.upd_sender_account(sa)
  end

  delete '/sendercontact/:ctc_id' do |ctc_id|
    s = SenderHandler.new
    s.del_sender_contact(ctc_id)
  end

  post '/sendercontact/:ctc_id' do |ctc_id|
    params = JSON.parse(request.body.read)
    s = SenderHandler.new
    sc = SenderContact.new(ctc_id, nil) # don't need sender_id for update
    sc.name = params['name']
    sc.contact = params['contact']
    sc.comments = params['comments']
    s.upd_sender_contact(sc)
  end

  get '/taglist' do
    # CONVERTED
    s = SenderHandler.new
    @tags = s.fetch_all_tags
    @tags.to_json
  end

  post '/tagtype_new' do
    params = JSON.parse(request.body.read)
    s = SenderHandler.new
    st = SenderTag.new(nil, params['tag_type'], params['color'])
    res = s.add_tagtype(st)
    res.to_json
  end

  post '/tagtype/:id' do |id|
    params = JSON.parse(request.body.read)
    s = SenderHandler.new
    st = SenderTag.new(id, nil, params['color'])
    res = s.upd_tagtype(st)
    res.to_json
  end

  get '/payments' do
    p = PmtHandler.new
    @payments = p.fetch_payments
    @payments.to_json
  end

  # non-erb (axios-only) GET calls here
  get '/json/sendertags' do
    content_type 'application/json'
    s = SenderHandler.new
    ret = s.fetch_senders_and_tags
    ret.to_json
  end

  get '/json/sender/:id/documents' do |sender_id|
    content_type 'application/json'
    d = DocHandler.new
    ret = d.fetch_sender_documents(sender_id)
    ret.to_json
  end

  get '/json/sender/:id/accounts' do |id|
    content_type 'application/json'
    s = SenderHandler.new
    sender = s.fetch_sender(id)
    if sender.nil?
      []
    else
      sender.sender_accounts.to_json
    end
  end

  get '/json/sendersbytag' do
    content_type 'application/json'
    s = SenderHandler.new
    data = s.fetch_sender_tags_and_ids
    data.to_json
  end

  get '/tags' do
    content_type 'application/json'
    s = SenderHandler.new
    tags = s.fetch_all_tags
    tags.to_json
  end

  run! if app_file == $PROGRAM_NAME
end
