# frozen_string_literal: true

require_relative '../../streamserver/data/songcache'

describe SongCache do
  it 'stores and fetches data' do
    actual = SongCache.new(capacity: 3)
    actual.store('1', 'hello')
    sleep(0.1)
    first_fetched = actual.fetch('2')
    actual.store('2', 'there')
    sleep(0.1)
    second_fetched = actual.fetch('2')
    actual.store('3', 'fred')

    expect(first_fetched).to eq(nil)
    expect(second_fetched.songdata).to eq('there')
  end

  it 'ages out the correct item' do
    actual = SongCache.new(capacity: 3)
    actual.store('1', 'hello')
    sleep(0.1)
    actual.store('2', 'there')
    sleep(0.1)
    actual.store('3', 'fred')
    sleep(0.1)
    actual.store('4', 'and')

    expect(actual.fill).to eq(3)
    expect(actual.fetch('2').songdata).to eq('there')
    expect(actual.fetch('4').songdata).to eq('and')
    expect(actual.fetch('1')).to eq(nil)
  end

  it 'ages out the correct item after a fetch' do
    actual = SongCache.new(capacity: 3)
    actual.store('1', 'hello')
    sleep(0.1)
    actual.store('2', 'there')
    sleep(0.1)
    actual.store('3', 'fred')
    sleep(0.1)
    item = actual.fetch('1')
    actual.store('4', 'and')

    expect(item.songdata).to eq('hello')
    expect(actual.fill).to eq(3)
    expect(actual.fetch('1').songdata).to eq('hello')
    expect(actual.fetch('4').songdata).to eq('and')
    expect(actual.fetch('2')).to eq(nil)
  end
end
