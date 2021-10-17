# frozen_string_literal: true

require 'sinatra/base'
require_relative '../common/comms/fetch'
require_relative '../common/text/manip'
require 'json'

# Sinatra module
module Sinatra
  # REST methods for the tag editor screens
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

      app.post '/tags/del' do
        # this is coming from axios so
        payload = JSON.parse(request.body.read)
        t_hash = payload['hash']
        t_tag_id = payload['tag_id']
        f = Fetch.new
        f.del_desc_tag(t_hash, t_tag_id)
      end

      app.post '/tags/add' do
        # this is coming from axios so
        payload = JSON.parse(request.body.read)
        t_hash = payload['hash']
        t_tag_id = payload['tag_id']
        f = Fetch.new
        f.add_desc_tag(t_hash, t_tag_id)
      end

      app.get '/tags/list' do
        f = Fetch.new
        f.all_desc_tags
      end

      app.get '/tags/:hash' do |hash|
        f = Fetch.new
        f.song_tags(hash)
      end
    end
  end
  register TagEditorGUI
end
