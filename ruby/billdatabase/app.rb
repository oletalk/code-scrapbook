# frozen_string_literal: true

require 'sinatra/base'
require_relative 'db/dochandler'
require_relative 'db/senderhandler'

# lg = ListGen.new
# puts lg.fetch_playlist('programming')

# main app to take requests for playlists and songs from clients
class StreamServer < Sinatra::Base
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

  run! if app_file == $PROGRAM_NAME
end
