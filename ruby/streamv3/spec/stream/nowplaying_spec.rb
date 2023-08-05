# frozen_string_literal: true

require_relative '../../lib/stream/nowplaying'
require_relative '../../lib/db/hashsong'
require_relative '../support/db_helpers'

describe 'NowPlaying' do
  it 'initializes correctly' do
    actual = NowPlaying.new
    expect(actual.playing('1.1.1.1')).to be(nil)
  end

  it 'records starting a song correctly' do
    actual = NowPlaying.new
    hsong = fake_hashsong('My Cool Song', 3, false)
    myip = '34.45.21.10'
    actual.start(hsong, myip, 'colin')
    result = actual.playing(myip)
    expect(result[:title]).to eq('My Cool Song')
  end

  it 'records a song as played after it has finished and another song starts' do
    actual = NowPlaying.new
    hsong = fake_hashsong('Really Short Song', 1, true)
    hsong2 = fake_hashsong('Cool Theme Song', 2, false)

    myip = '1.2.3.4'
    actual.start(hsong, myip, 'colin')
    result = actual.playing(myip)
    expect(result[:title]).to eq('Really Short Song')
    # let the song finish
    puts '<<< Sleeping 2 seconds to let song "finish" >>>'
    sleep 2
    # start another song - the first one should be recorded
    expect(hsong).to receive(:record_stat).once

    # fake user checking 'now playing' and us realising the song has finished
    expect(actual.playing(myip)).to be(nil) # it should call record_stat here

    actual.start(hsong2, myip, 'colin')

    result = actual.playing(myip)
    expect(result[:title]).to eq('Cool Theme Song')
  end

  it 'records songs playing on separate ips separately' do
    actual = NowPlaying.new
    # last param here is whether to setup record_stat
    # but we'll set it up separately
    hsong = fake_hashsong('Another short Song', 23, false)
    allow(hsong).to receive(:record_stat).once

    hsong2 = fake_hashsong('Cool Theme Song', 21, false)

    myip = '1.2.3.4'
    actual.start(hsong, myip, 'colin')
    result = actual.playing(myip)
    expect(result[:title]).to eq('Another short Song')
    sleep 1

    actual.start(hsong2, '3.4.5.6', 'karen')

    result2 = actual.playing(myip)
    expect(result2[:title]).to eq('Another short Song') # still...
  end
end
