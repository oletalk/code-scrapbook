ENV['RACK_ENV'] = 'test'

require './StreamApp'
require 'test/unit'
require 'rack/test'
require './util/db'
require './excep/playlist'
require 'json'

describe 'The StreamApp app' do
	include Rack::Test::Methods

	def app
		StreamApp
	end

    def mock_db
		@mock_db = double(Db)
		allow(@mock_db).to receive(:authenticate_user).and_return(User.new('fred', 'abcde', false));
        allow(@mock_db).to receive(:list_songs)
            .and_return([
                    { 'hash': 'abcdefg', 'title': 'My Song', 'secs': -1},
                    { 'hash': 'adf3a32', 'title': 'Great Tune', 'secs': 300},
                    { 'hash': 'fce3fca', 'title': 'A Ditty', 'secs': 220}
                   ] );
        allow(@mock_db).to receive(:list_songlists_for).and_return([ { name: 'foo' } ])
        allow(@mock_db).to receive(:check_owner_is).with('foo', 'bar').and_return(false)
        allow(@mock_db).to receive(:check_owner_is).with('foo', 'fred').and_return(true)
        allow(@mock_db).to receive(:check_owner_is).with('bar', 'baz').and_return(true)
        allow(@mock_db).to receive(:save_songlist).with('foo', anything(), 'fred', false).and_raise(PlaylistCreationError.new('creation failed'))
        allow(@mock_db).to receive(:save_songlist).with('bar', anything(), 'baz', false).and_return(true)
		Db.stub(:new).with(any_args()).and_return(@mock_db)
	end

	it "returns a json list" do
        mock_db
        get '/json/ripped'
		expect(last_response).to be_ok
        expect(last_response.body).to eq("[{\"title\":\"My Song\",\"hash\":\"abcdefg\"},{\"title\":\"Great Tune\",\"hash\":\"adf3a32\"},{\"title\":\"A Ditty\",\"hash\":\"fce3fca\"}]")
    end

    # TODO - test for posting a new playlist
    it "checks user playlist before saving" do
        mock_db
        [{arg1:'foo', arg2:'bar', res:"{\"error\":\"Playlist exists and you are not the owner\"}"}, 
         {arg1:'bar', arg2:'baz', res: ""},
         {arg1:'foo', arg2:'fred', res: "{\"error\":\"creation failed\"}"}].each do |item|
            body = { listname: item[:arg1], 'listowner': item[:arg2], 'listcontent': [{hash: 'abcdef1'}, {hash: '123456a'}]}.to_json
            post '/songlist', body, {'Content-Type' => 'application/json'}
            expect(last_response.body).to eq(item[:res])
        end
    end

	it "fetches json lists" do
        mock_db
		get '/json_lists_for/colin'
		expect(last_response).to be_ok
        expect(last_response.body).to eq("[{\"name\":\"foo\"}]")
	end
end


