# frozen_string_literal: true

require_relative '../../dbserver/data/song'

describe Song do
  it 'initialises correctly' do
    data = { song_filepath: '/home/fred/mp3s/aa.mp3', artist: 'Foo', title: 'Wow' }
    actual = Song.new(data)

    expect(actual.location).to eq('/home/fred/mp3s/aa.mp3')
    expect(actual.artist).to eq('Foo')
    expect(actual.title).to eq('Wow')
  end
end
