# frozen_string_literal: true

require 'json'
require 'sinatra/base'
require_relative 'db/dochandler'
require_relative 'db/senderhandler'
require_relative 'data/sender'

# main app
class BillDatabase < Sinatra::Base
  # TODO: -

  before do
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Accept, Authorization, Origin'
    content_type 'text/html'
  end

  get '/main' do
    '<h1>hello world</h1>'
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

  run! if app_file == $PROGRAM_NAME
end
