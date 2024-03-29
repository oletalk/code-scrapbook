# frozen_string_literal: true

require 'httparty'
require_relative '../../common/comms/fetch'

describe Fetch do
  it 'fetches song data' do
    mock_responses('abcdefg', 'playedcontent')

    # ftch = spy('fetch')

    f = Fetch.new
    actual = f.fetch('abcdefg', downsample: false)
    expect(f.cachefill).to eq(0) # no downsampling, no caching

    expect(actual).to eq('playedcontent')
  end

  it 'fetches downsampled song data and caches it the first time' do
    mock_responses('abcdefg', 'downplayedcontent')

    f = Fetch.new
    f.fetch('abcdefg', downsample: true) # will cache this request
    expect(f.cachefill).to eq(1)
    actual = f.fetch('abcdefg', downsample: true) # but not again
    expect(f.cachefill).to eq(1)

    expect(actual).to eq('downplayedcontent')
  end

  it 'fetches two separate downsampled songs' do
    mock_responses('abcdefg', 'downplayedcontent')

    f = Fetch.new
    f.fetch('abcdefg', downsample: true) # will cache this one
    expect(f.cachefill).to eq(1)

    mock_responses('qwertyui', 'morecontent22')

    actual = f.fetch('qwertyui', downsample: true)    # and this one too
    expect(f.cachefill).to eq(2)

    expect(actual).to eq('morecontent22')
  end

  it 'fetches a playlist' do
    an_m3u = "#EXTM3U\n" \
             "#EXTINF:333,A song\n" \
             'http://192.168.2.2:81/play/3333aa0b'
    expected_playlist = "#EXTM3U\n" \
                        "#EXTINF:333,A song\n" \
                        'http://192.168.0.20:8080/play/3333aa0b'

    mock_m3u_responses('amy', an_m3u)

    f = Fetch.new('192.168.0.20:8080')
    actual = f.playlist_m3u('amy')
    expect(actual).to eq(expected_playlist)
  end
end

def mock_http_response(fake_response_body)
  @mock_response = double(HTTParty::Response)
  allow(@mock_response).to receive(:code) { 200 }
  allow(@mock_response).to receive(:body) { fake_response_body }
end

def mock_m3u_responses(m3u_name, fake_response_body)
  mock_http_response(fake_response_body)
  base_url = "http://#{MP3S::Config::DB::SERVER_HOST}:#{MP3S::Config::DB::SERVER_PORT}"

  @mock_http = class_double(HTTParty)
               .as_stubbed_const(transfer_nested_constants: true)
  allow(@mock_http).to receive(:get)
    .with("#{base_url}/playlist/m3u/#{m3u_name}", { format: :plain }) { @mock_response }
end

def mock_responses(fake_hash, fake_response_body)
  mock_http_response(fake_response_body)
  base_url = "http://#{MP3S::Config::DB::SERVER_HOST}:#{MP3S::Config::DB::SERVER_PORT}"

  @mock_http = class_double(HTTParty)
               .as_stubbed_const(transfer_nested_constants: true)
  allow(@mock_http).to receive(:get)
    .with("#{base_url}/play/#{fake_hash}", { format: :plain }) { @mock_response }
  allow(@mock_http).to receive(:get)
    .with("#{base_url}/play/#{fake_hash}/downsampled", { format: :plain }) { @mock_response }
end
