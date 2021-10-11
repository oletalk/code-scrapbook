# frozen_string_literal: true

require 'sinatra/base'
require_relative '../common/comms/fetch'
require_relative '../common/text/manip'
require 'json'

# Playlist editor REST calls.
module Sinatra
  # REST methods for the playlist editor pages (/playlist/manage)
  module PlaylistEditorGUI
    def self.registered(app)
      app.get '/playlist/m3u/:name' do |name|
        response.headers['Content-Type'] = 'text/plain'
        f = Fetch.new(request.env['HTTP_HOST'])
        f.playlist_m3u(name)
      end

      app.get '/playlist/manage' do
        f = Fetch.new
        @foo = JSON.parse(f.playlist(nil))
        erb :manage
      end

      app.post '/playlist/save' do
        playlist_id = params['pid']
        playlist_name = params['pname']
        playlist_songids = params['songids']
        # try JSON if params are nil
        if playlist_id.nil? && playlist_name.nil? && playlist_songids.nil?
          puts 'params appear to be nil... checking payload'
          payload = JSON.parse(request.body.read)
          # puts payload
          playlist_id = payload['pid']
          playlist_name = payload['pname']
          playlist_songids = payload['songids']
        end
        if playlist_id.nil?
          # generate a new one
          f = Fetch.new
          playlist_id = f.playlist('new').to_i
          puts "new playlist id #{playlist_id}"
        end
        if playlist_songids.nil?
          'Error: no playlist songs provided :-/'
        else
          f = Fetch.new
          f.savelist(playlist_id, playlist_name, playlist_songids)
          redirect "/playlist/#{playlist_id}"
        end
      end

      app.get '/playlist_new' do
        erb :list
      end

      app.get '/playlist/:id' do |id|
        # f = Fetch.new
        # each row has the playlist name (yeah, i know...)
        # @pname = @foo[0]['name']
        # @foo.each { |s| s['secs_display'] = Manip.time_display(s['secs']) }
        @playlist_id = id
        erb :list
      end

      app.get '/playlist/:id/delete' do |id|
        f = Fetch.new
        f.dellist(id)
        redirect '/playlist/manage'
      end
    end
  end
  register PlaylistEditorGUI
end
