# frozen_string_literal: true

require_relative '../../common/text/manip'

describe Manip do
  context 'given a postgresql timestamp result' do
    it 'returns a display friendly timestamp' do
      # check the format of the expected result against your config
      expected = 'Fri 3 Jul 2020, 11:27 am'
      input_d = '2020-07-03 11:27:15.296414'
      expect(Manip.timestamp_from_db(input_d)).to eq(expected)
    end
  end

  context 'given a postgresql date result' do
    it 'returns a display friendly date' do
      # check the format of the expected result against your config
      expected = 'Sat 4 Jul 2020'
      input_d = '2020-07-04'
      expect(Manip.date_from_db(input_d)).to eq(expected)
    end
  end

  context 'given a bad date result' do
    it 'returns nil' do
      # check the format of the expected result against your config
      expected = 'Fri 3 Jul, 11:27 am'
      input_d = 'dsfsdf'
      expect(Manip.date_from_db(input_d)).to eq(nil)
    end
  end

  context 'given an empty list' do
    songlist = []
    it 'returns nothing' do
      expect(Manip.shorten_titles(songlist, 10)).to eq([])
    end
  end

  context 'given a multiline string' do
    bigstring = %(
      this is
      a string
      across multiple
      lines.
    )
    it 'returns the shortened version' do
      expect(Manip.collapse(bigstring)).to eq('this is a string across multiple lines.')
    end
  end

  context 'given a short list with long titles' do
    songlist = [{ 'title' => 'abcdefghijkl' }, \
                { 'title' => '1234567890' }, \
                { 'title' => '123456789012' }]
    expected_s = [{ 'title' => 'abcdefg...' }, \
                  { 'title' => '1234567890' }, \
                  { 'title' => '1234567...' }]
    it 'returns shortened titles' do
      expect(Manip.shorten_titles(songlist, 10)).to eq(expected_s)
    end
  end
end
