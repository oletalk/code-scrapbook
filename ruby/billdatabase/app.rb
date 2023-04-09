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
    '<h1>hello world</h1>'
  end

  get '/document_new' do
    dh = DocHandler.new
    sh = SenderHandler.new
    @doctypes = dh.fetch_doctypes
    @senders = sh.fetch_senders
    erb :document_new
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
