ENV['RACK_ENV'] = 'test'

require_relative '../DBServer'
require 'test/unit'
require 'rack/test'
require 'json'
require_relative '../dbserver/data/played'
require_relative '../dbserver/util/db'
require_relative '../dbserver/util/player'
require_relative '../common/util/config'

# deprecation warnings
#RSpec.configure do |config|
#	config.mock_with :rspec do |c|
#		c.syntax = [:should, :expect]
#	end
#end

describe 'The DBServer backend app' do
	include Rack::Test::Methods

	def app
		DBServer
	end

	def mock_db
		@recordstats = []

		@mock_db = double(Db)
		allow(@mock_db).to receive(:fetch_search).with("tune") {
			[{ hash: 'sdljkflkj', secs: '200', title: 'A Tune' }, \
			 { hash: '4908gt08g', secs: '190', title: 'Tuneful' }]
		}
		allow(@mock_db).to receive(:find_song).with("x20hashx20") {
			[{song_filepath: '/path/to/song', artist: 'Fun Time', title: 'Fun Song'}]
		}
		allow(@mock_db).to receive(:list_songs).with("#{MP3S::Config::Net::MP3_ROOT}/tunes2019") {
			[{hash: "9388fevh", secs: "334", title: "Something"},
			 {hash: "599h05t9", secs: "210", title: "A Remix"}]
    }
    allow(@mock_db).to receive(:get_new_playlist_id) { 10 }
		allow(@mock_db).to receive(:fetch_playlist).with("2") {
			[{name: "random", hash: "9388fevh", secs: "334", title: "Something"}]
		}
		allow(@mock_db).to receive(:record_stat) do | stat_type, stat_value |
			@recordstats.push("#{stat_type}: #{stat_value}")
		end
		Db.stub(:new).and_return(@mock_db)

		@mock_player = double(Player)

		allow(@mock_player).to receive(:get_command).with(false,"/path/to/song") { "cat" }
		allow(@mock_player).to receive(:get_command).with(true,"/path/to/song") { "strings" }
		allow(@mock_player).to receive(:songresponse).with("x20hashx20", "/path/to/song", false) {
			"songcontentsbinarydatafoobar"
		}
		allow(@mock_player).to receive(:songresponse).with("x20hashx20", "/path/to/song", true) {
			"cmprsedsng"
		}
		allow(@mock_player).to receive(:play_song).with("cat", "/path/to/song") {
			Played.new("songcontentsbinarydatafoobar", "cat /path/to/song")
		}
		allow(@mock_player).to receive(:play_song).with("strings", "/path/to/song") {
			Played.new("cmprsedsng", "strings /path/to/song")
		}


		Player.stub(:new).and_return(@mock_player)
	end

	it "receives a connection request with an invalid JWT" do

		expect {
      get '/pass/sdfdsfsd', {}, {'HTTP_HOST' => '192.168.0.6:8080', 'REMOTE_ADDR' => '192.168.0.6'}
    }.to raise_error(JWT::DecodeError)
	end

  it "receives a connection request with the wrong JWT" do
		app.set_hmac_secret('thisIsNotASecureSecret')

    get '/pass/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjoiYm9va3MifQ.7R8dME4FIeDqAEvdTWvFZooPC0-pYy_vPH15A9pb9YA', \
    {}, {'HTTP_HOST' => '192.168.0.6:8080', 'REMOTE_ADDR' => '192.168.0.6'}

    expect(last_response).to be_ok
    expect(last_response.body).to eq("FAIL")
  end

  it "receives a connection request with the right JWT" do
		app.set_hmac_secret('thisIsNotASecureSecret')
    get '/pass/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjoic3R1ZmYifQ.IxgLrG2qQbB_TdzHFFNARFiXC8J5nxbuL67cZVv2iOY', \
    {}, {'HTTP_HOST' => '192.168.0.6:8080','REMOTE_ADDR' => '192.168.0.6'}
    expect(last_response).to be_ok
    expect(last_response.body).to eq("OK")
  end

	it "does a m3u search" do
		mock_db

		expected_m3u = "#EXTM3U\n" \
									+ "#EXTINF:200,A Tune\n" \
									+ "http://192.168.0.6:8080/play/sdljkflkj\n" \
									+ "#EXTINF:190,Tuneful\n" \
									+ "http://192.168.0.6:8080/play/4908gt08g"
		get '/search/m3u/tune', {}, {'HTTP_HOST' => '192.168.0.6:8080'}
		expect(last_response).to be_ok
		expect(last_response.body).to eq(expected_m3u)
	end

	it "returns a search in json format" do
		mock_db

		expected_json = "[{\"hash\":\"sdljkflkj\",\"secs\":\"200\",\"title\":\"A Tune\"}," \
		              +  "{\"hash\":\"4908gt08g\",\"secs\":\"190\",\"title\":\"Tuneful\"}]"
		get '/search/tune', {}, {'HTTP_HOST' => '192.168.0.6:8080'}
		expect(last_response).to be_ok
		expect(last_response.body).to eq(expected_json)
	end

  it "responds to play command with raw song data" do
  	mock_db
		expected_data = "songcontentsbinarydatafoobar"
		get '/play/x20hashx20', {}, {'HTTP_HOST' => '192.168.0.6:8080'}
		expect(last_response).to be_ok
		expect(last_response.body).to eq(expected_data)
		expect(@recordstats).to eq(["SONG: /path/to/song", "ARTIST: Fun Time", "TITLE: Fun Song"])
  end

	it "responds to play downsampled command with raw song data" do
		mock_db
		expected_data = "cmprsedsng"
		get '/play/x20hashx20/downsampled', {}, {'HTTP_HOST' => '192.168.0.6:8080'}
		expect(last_response).to be_ok
		expect(last_response.body).to eq(expected_data)
		expect(@recordstats).to eq(["SONG: /path/to/song", "ARTIST: Fun Time", "TITLE: Fun Song"])

	end

  it "fetches a blank id for new playlist" do
    mock_db

    get '/playlist/new', {}, {'HTTP_HOST' => '192.168.0.6:8080'}
    expect(last_response).to be_ok
    expect(last_response.body).to eq('10')

  end

  it "fetches an existing playlist" do
  	mock_db

		expected_playlist = "[{\"name\":\"random\",\"hash\":\"9388fevh\",\"secs\":\"334\",\"title\":\"Something\"}]"
		get '/playlist/2', {}, {'HTTP_HOST' => '192.168.0.6:8080'}
		expect(last_response).to be_ok
		expect(last_response.body).to eq(expected_playlist)

  end

	it "generates a folder playlist" do
		mock_db
		expected_m3u = "#EXTM3U\n" \
									+ "#EXTINF:334,Something\n" \
									+ "http://192.168.0.6:8080/play/9388fevh\n" \
									+ "#EXTINF:210,A Remix\n" \
									+ "http://192.168.0.6:8080/play/599h05t9"
		get '/list/tunes2019', {}, {'HTTP_HOST' => '192.168.0.6:8080'}
		expect(last_response).to be_ok
		expect(last_response.body).to eq(expected_m3u)

	end


	it "rejects a response not from the connected streamserver" do
		mock_db

		get '/play/x20hashx20/downsampled', {}, {'HTTP_HOST' => '192.168.0.20:8000'}
		expect(last_response).to be_ok
		expect(last_response.body).to eq("")

	end



	# TODO write /play/:hash test


end
