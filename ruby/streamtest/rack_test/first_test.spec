ENV['RACK_ENV'] = 'test'

require './StreamApp'
require 'test/unit'
require 'rack/test'
require './util/db'
require './excep/playlist'
require 'json'

# deprecation warnings
RSpec.configure do |config|
	config.mock_with :rspec do |c|
		c.syntax = [:should, :expect]
	end
end

describe 'The StreamApp app' do
	include Rack::Test::Methods

	def app
		StreamApp
	end

	def mock_remoteip(newip)
		allow(request).to receive(env).with("REMOTE_ADDR").and_return(newip)
	end

	def mock_player
		@mock_player = double(Player)

		# set test ranges - allow/allow with downsample/reject
		@mock_whitelist = IPWhitelist.new({ 
					'192.168.0.0/24' => { allow: true },  
					'192.168.1.0/24' => { allow: true, downsample: true } },
					{ allow: false } )
		IPWhitelist.stub(:new).with(any_args()).and_return(@mock_whitelist)

		playcmd = '/bin/cat XXXX'
		playdscmd = '/bin/lame XXXX'
		allow(@mock_player).to receive(:get_command).with(false, anything()).and_return(playcmd)
		allow(@mock_player).to receive(:get_command).with(true, anything()).and_return(playdscmd)
        allow(@mock_player).to receive(:play_song).with(playcmd, anything()).and_return({ songdata: 'foo' })
		allow(@mock_player).to receive(:play_song).with(playdscmd, anything()).and_return({ songdata: 'foodownsampled' })
		Player.stub(:new).with(any_args()).and_return(@mock_player)
	end

    def mock_db
		@mock_db = double(Db)
	# play
		allow(@mock_db).to receive(:record_stat).with(any_args())
		allow(@mock_db).to receive(:find_song).with(any_args()).and_return({ })
		allow(@mock_db).to receive(:find_song).with('abcdefg').and_return({ :song_filepath => '/tunes/song1.mp3'})
		allow(@mock_db).to receive(:find_song).with('adf3a32').and_return({ :song_filepath => '/tunes/greattune.ogg' })
		allow(@mock_db).to receive(:authenticate_user).and_return(User.new('fred', 'abcde', false))
	# list_songs
        allow(@mock_db).to receive(:list_songs)
            .and_return([
                    { 'hash': 'abcdefg', 'title': 'My Song', 'secs': -1},
                    { 'hash': 'adf3a32', 'title': 'Great Tune', 'secs': 300},
                    { 'hash': 'fce3fca', 'title': 'A Ditty', 'secs': 220}
                   ] );
	# other methods wrapped by endpoints
		allow(@mock_db).to receive(:fetch_search).and_return([  { 'hash': 'fce3fca', 'title': 'A Ditty', 'secs': 220} ] )
        allow(@mock_db).to receive(:list_songlists_for).and_return([ { name: 'foo' } ])
        allow(@mock_db).to receive(:check_owner_is).with('foo', 'bar').and_return(false)
        allow(@mock_db).to receive(:check_owner_is).with('foo', 'fred').and_return(true)
        allow(@mock_db).to receive(:check_owner_is).with('bar', 'baz').and_return(true)
        allow(@mock_db).to receive(:save_songlist).with('foo', anything(), 'fred', false).and_raise(PlaylistCreationError.new('creation failed'))
        allow(@mock_db).to receive(:save_songlist).with('bar', anything(), 'baz', false).and_return(true)
		Db.stub(:new).with(any_args()).and_return(@mock_db)
	end

	it "fetches and plays a song given its hash" do
		mock_player
		mock_db
		get '/play/abcdefg', {}, {'REMOTE_ADDR' => '192.168.0.6'}
		expect(last_response).to be_ok
		expect(last_response.body).to eq("foo")
	end

	it "downsamples for given ip range" do
		mock_player
		mock_db
		get '/play/abcdefg/downsampled', {}, {'REMOTE_ADDR' => '192.168.1.10'}
		expect(last_response.body).to eq("foodownsampled")
	end

	it "returns a 403 if a downsampled client asks for non-downsampled content" do
		mock_player
		mock_db
		get '/play/abcdefg', {}, {'REMOTE_ADDR' => '192.168.1.10'}
		expect(last_response.body).to start_with("403 ")
	end

	it "returns a 403 given remote ip is not allowed" do
		mock_player
		mock_db
		get '/play/abcdefg', {}, {'REMOTE_ADDR' => '211.211.211.211'}
		expect(last_response.body).to start_with("403 ")
	end

	it "errors out given a bad hash" do
		mock_player
		mock_db
		get '/play/foobar', {}, {'REMOTE_ADDR' => '192.168.0.6'}
		expect(last_response.body).to start_with("404 ")
	end

	it "returns a json list of songs" do
        mock_db
        get '/json/ripped', {}, {'REMOTE_ADDR' => '192.168.0.1'}
		expect(last_response).to be_ok
        expect(last_response.body).to eq("[{\"title\":\"My Song\",\"hash\":\"abcdefg\"},{\"title\":\"Great Tune\",\"hash\":\"adf3a32\"},{\"title\":\"A Ditty\",\"hash\":\"fce3fca\"}]")
    end

	it "fetches a list of songs matching a search" do
        mock_db
        get '/search_json/song', {}, {'REMOTE_ADDR' => '192.168.0.1'}
		expect(last_response).to be_ok
		expect(last_response.body).to eq("[{\"title\":\"A Ditty\",\"hash\":\"fce3fca\"}]")
	end

	it "returns list of playlists for a given user" do
        mock_db
		get '/json_lists_for/colin', {}, {'REMOTE_ADDR' => '192.168.0.1'}
		expect(last_response).to be_ok
        expect(last_response.body).to eq("[{\"name\":\"foo\"}]")
	end

    # wrapper around db validation of playlist save function
    it "checks user playlist before saving" do
        mock_db
        [{arg1:'foo', arg2:'bar', res:"{\"error\":\"Playlist exists and you are not the owner\"}"}, 
         {arg1:'bar', arg2:'baz', res: ""},
         {arg1:'foo', arg2:'fred', res: "{\"error\":\"creation failed\"}"}].each do |item|
            body = { listname: item[:arg1], 'listowner': item[:arg2], 'listcontent': [{hash: 'abcdef1'}, {hash: '123456a'}]}.to_json
            post '/songlist', body, {'Content-Type' => 'application/json', 'REMOTE_ADDR' => '192.168.0.1'}
            expect(last_response.body).to eq(item[:res])
        end
    end

end


