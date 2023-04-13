# frozen_string_literal: true

require 'json'
require 'sinatra/base'
require_relative 'db/dochandler'
require_relative 'db/senderhandler'
require_relative 'data/sender'
require_relative 'data/senderaccount'

# main app
class BillDatabase < Sinatra::Base
  # writing functionality
  # 1. write or add method to write to db in a handler
  # 2. add method that accesses handler here VV
  # 3. add method in entity.js (or wherever) that does axios call to this
  # 4. add element in erb that calls that method in js

  before do
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Accept, Authorization, Origin'
    content_type 'text/html'
  end

  get '/main' do
    erb :main
  end

  get '/documents' do
    dh = DocHandler.new
    @documents = dh.fetch_documents
    erb :documents
  end

  get '/document_new' do
    dh = DocHandler.new
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
      puts new_id
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
    ret.to_json
  end

  get '/document/:id' do |id|
    content_type 'text/html'

    d = DocHandler.new
    @doc = d.fetch_document(id)
    s = SenderHandler.new
    @sender = s.fetch_sender(@doc.sender.id)

    erb :single_document
  end

  get '/doctypes' do
    d = DocHandler.new
    @doctypes = d.fetch_doctypes
    erb :doctype
  end

  get '/senders' do
    s = SenderHandler.new
    @senders = s.fetch_senders
    erb :senders
  end

  get '/sender/:id' do |id|
    s = SenderHandler.new
    @sender = s.fetch_sender(id)
    erb :single_sender
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
    sa.comments = params['comments']
    s.upd_sender_account(sa)
  end

  # non-erb (axios-only) calls here
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

  run! if app_file == $PROGRAM_NAME
end
