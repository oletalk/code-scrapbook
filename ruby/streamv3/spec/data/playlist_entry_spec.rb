# frozen_string_literal: true

require_relative '../../lib/data/playlist_entry'

describe 'PLEntry' do
  it 'renders correctly in json' do
    expected = '{"title":"my song","url":"/path/to/song","secs":34}'
    actual = PLEntry.new('my song', '/path/to/song', 34)
    expect(actual.to_json).to eq(expected)
  end
end
