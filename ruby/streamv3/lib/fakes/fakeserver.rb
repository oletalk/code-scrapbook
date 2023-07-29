require 'sinatra/base'

# need to fake /playlists
# /playlist/:name - e.g. /playlist/amy
# /search/:searchstring - e.g. /search/amy

class FakeStreamServer < Sinatra::Base
  before do
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Accept, Authorization, Origin'
    content_type 'text/plain'
  end

  get '/playlists' do
    ret = File.read('data/playlists.txt').chomp
    ret
  end

  get '/playlist/:name' do |name|
    # validate it - just want alphanumeric chars, no funny stuff
    if name =~ /^\w+$/
      filename = "data/playlist.#{name}.txt"
      if File.exist?(filename)
        File.read(filename).chomp
      else
        "[{'error': 'playlist does not exist'}]"
      end
    else
      "[{'error': 'invalid playlist name'}]"
    end
  end

  get '/search/:spec' do |spec|
    ret = File.read('data/search.result.1.txt')
    ret
  end

  run! if app_file == $PROGRAM_NAME
end

