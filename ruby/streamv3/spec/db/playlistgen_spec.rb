# frozen_string_literal: true

require_relative '../../lib/db/playlistgen'
require_relative '../../lib/db/db'
require_relative '../../lib/sql/sql_read'
require_relative '../support/db_helpers'
require 'date'

RSpec.configure do |c|
  c.include DbHelpers
end

describe 'PlaylistGen' do
  it 'renders correctly in json' do
    # TODO: how do you fake output from module sqlread????
    allow_any_instance_of(SqlRead).to receive(:sqlfrom).and_return('blah')
    result = double('PG::Result')

    allow(result).to receive(:each).and_yield(
      {
        'display_title' => 'my cool song',
        'secs' => 10,
        'file_hash' => 'abc125'
      }
    ).and_yield(
      {
        'display_title' => 'another song',
        'secs' => 42,
        'file_hash' => 'a8d76fe2'
      }
    )
    fake_conn(result)
    actual = PlaylistGen.new(hostheader: 'http://localhost:3434')
    expect(actual.fetch_tunes(name: 'foo')).to eq('[{"title":"my cool song","url":"http://http://localhost:3434/play/abc125","secs":10},{"title":"another song","url":"http://http://localhost:3434/play/a8d76fe2","secs":42}]')
  end
end
