# frozen_string_literal: true

require_relative '../../lib/db/hashsong'
require_relative '../../lib/sql/sql_read'
require_relative '../support/db_helpers'

RSpec.configure do |c|
  c.include DbHelpers
end

describe 'HashSong' do
  it 'populates correctly from db' do
    result = double('PG::Result')
    allow_any_instance_of(SqlRead).to receive(:sqlfrom).and_return('blah')
    allow(result).to receive(:each).and_yield(
      {
        'file_hash' => 'a1b4d3f2',
        'secs' => 10,
        'song_filepath' => '/path/to/an_mp3.mp3',
        'display_title' => 'An MP3!'
      }
    )
    fake_conn(result)
    actual = HashSong.new(hash: 'a1b4d3f2')
    expect(actual.secs).to be(10)
    expect(actual.song_filepath).to be('/path/to/an_mp3.mp3')
  end
end
