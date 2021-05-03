# frozen_string_literal: true

require 'sinatra/base'
require_relative '../common/comms/fetch'
require_relative '../common/text/manip'
require 'json'

module Sinatra
  module TagEditorGUI
    def self.registered(app)
      app.get '/tag/:hash/:pid' do |hash, pid|
        f = Fetch.new
        tags = JSON.parse(f.tag(hash))
        @taginfo = tags[0]
        @hash = hash
        @playlist_id = pid
        erb :tagedit
      end

      app.post '/tag/save' do
        tag_artist = params['artist']
        tag_title = params['title']
        tag_hash = params['hash']
        playlist_id = params['playlist_id']
        if tag_artist.nil? || tag_title.nil?
          'Error: tag info missing :-/'
        else
          f = Fetch.new
          f.savetag(tag_artist, tag_title, tag_hash, playlist_id)
          redirect "/playlist/#{playlist_id}"
        end
      end
    end
  end
  register TagEditorGUI
end
