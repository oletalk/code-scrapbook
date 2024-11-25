# frozen_string_literal: true

require_relative '../data/sender'
require_relative '../data/sendertag'

describe Sender do
  describe '.initialize' do
    context 'given an id' do
      it 'creates an empty sender object' do
        actual = Sender.new(3, nil)
        expect(actual.id).to eq(3)
        expect(actual.sender_accounts.length).to eq(0)
      end
    end

    it 'initializes from a database row' do
      row = {
        'name' => 'Barclays', 
        # fat arrow means string keys, colon means symbol keys
        'username' => 'McDuck',
        'password_hint' => 'mon3y',
        'comments' => 'all mine'
      }
      actual = Sender.new(3, nil)
      actual.fill_out_from(row)
      expect(actual.username).to eq('McDuck')
    end

    it 'adds a tag' do
      actual = Sender.new(3, nil)
      actual.add_tags([
                        SenderTag.new(22, 'Banking', '#000000'),
                        SenderTag.new(24, 'Insurance', '#330000')
                      ])
      expect(actual.sender_tags.length).to eq(2)
      expect(actual.sender_tags[1].color).to eq('#330000')
    end
  end
end
