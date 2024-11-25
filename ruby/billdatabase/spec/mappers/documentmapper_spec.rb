# frozen_string_literal: true

require_relative '../../data/sender'
require_relative '../../data/document'
require_relative '../../data/mappers/documentmapper'

describe DocumentMapper do
  describe 'create from row' do
    context 'given an empty row' do
      dbrow = {
        'doc_type_id' => '1',
        'doc_type_name' => 'Bill'
      }
      # TODO: add more properties

      it 'creates an empty document' do
        actual = DocumentMapper.new.create_from_row(dbrow)
        expect(actual.doc_type.name).to eq('Bill')
      end
    end
  end
end