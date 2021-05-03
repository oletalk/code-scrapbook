# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require_relative '../StreamServer'
require 'test/unit'
require 'rack/test'
require 'json'
require_relative '../common/comms/fetch'

# deprecation warnings
RSpec.configure do |config|
  config.mock_with :rspec do |c|
    c.syntax = %i[should expect]
  end
end

describe 'The StreamServer app' do
  include Rack::Test::Methods

  def app
    StreamServer
  end

  def mock_remoteip(newip)
    allow(request).to receive(env).with('REMOTE_ADDR').and_return(newip)
  end

  def mock_fetch
    @mock_fetch = double(Fetch)
    allow(@mock_fetch).to receive(:start).with(any_args) { 'OK' }
    allow(@mock_fetch).to receive(:fetch).with('abcdefg', downsample: false) { 'foo' }
    allow(@mock_fetch).to receive(:search).with('hijkl', nil) { 'searchresult' }
    Fetch.stub(:new).and_return(@mock_fetch)

    # set test ranges - allow/allow with downsample/reject
    @mock_whitelist = IPWhitelist.new({
                                        '192.168.0.0/24' => { allow: true },
                                        '192.168.1.0/24' => { allow: true, downsample: true }
                                      },
                                      { allow: false })
    IPWhitelist.stub(:new).with(any_args).and_return(@mock_whitelist)
  end

  it 'fetches and plays a song given its hash' do
    mock_fetch

    get '/play/abcdefg', {}, { 'REMOTE_ADDR' => '192.168.0.6' }
    expect(last_response).to be_ok
    expect(last_response.body).to eq('foo')
  end

  it 'blocks a request from a bad ip' do
    mock_fetch

    get '/play/abcdefg', {}, { 'REMOTE_ADDR' => '192.168.4.6' }
    expect(last_response).to_not be_ok
  end

  it 'searches for a partial spec' do
    mock_fetch

    get '/search/hijkl', {}, { 'REMOTE_ADDR' => '192.168.0.6' }
    expect(last_response).to be_ok
    expect(last_response.body).to eq('searchresult')
  end
end
