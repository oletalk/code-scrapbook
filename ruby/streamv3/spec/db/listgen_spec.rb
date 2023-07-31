# frozen_string_literal: true

require_relative '../../lib/db/listgen'
require_relative '../../lib/db/db'
require_relative '../../lib/sql/sql_read'
require_relative '../support/db_helpers'
require 'date'

RSpec.configure do |c|
  c.include DbHelpers
end

describe 'ListGen' do
  it 'generates playlist json from db result' do
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
    ).and_yield(
      {
        'display_title' => 'Étude 23 - Señales',
        'secs' => 34,
        'file_hash' => 's66f5w6d5'
      }
    )
    fake_conn(result)
    actual = ListGen.new(hostheader: 'localhost:3434')
    expect(actual.fetch_all_tunes).to eq(
      "#EXTM3U\n#EXTINF:10,my cool song\nhttps://localhost:3434/" \
      "member/play/abc125\n#EXTINF:42,another song\nhttps://localhost:3434/member/play/a8d76fe2\n#EXTINF:34,Étud" \
      "e 23 - Señales\nhttps://localhost:3434/member/play/s66f5w6d5\n"
    )
  end
end
