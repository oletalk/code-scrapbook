# frozen_string_literal: true

require_relative '../../dbserver/util/db'
require 'pg'

def mock_pg
  @connclosed = false
  @triggered_txn = false
  @mock_pg_result = double(PG::Result)

  allow(@mock_pg_result).to receive(:each) \
    .and_yield({ 'id' => 1, 'name' => 'lll' }) \
    .and_yield({ 'id' => 2, 'name' => 'abcde' }) {}

  @mock_pg_conn = double(PG::Connection)
  allow(@mock_pg_conn).to receive(:exec_params).with('sql1', nil).and_yield(@mock_pg_result)
  allow(@mock_pg_conn).to receive(:exec_params).with('badsql', nil).and_raise(PG::Error)
  allow(@mock_pg_conn).to receive(:prepare).with(any_args) {}
  allow(@mock_pg_conn).to receive(:exec_prepared).with('something', nil) {}
  allow(@mock_pg_conn).to receive(:transaction).and_yield { @triggered_txn = true }
  allow(@mock_pg_conn).to receive(:close) { @connclosed = true }

  allow(PG).to receive(:connect).with(any_args).and_return(@mock_pg_conn)
end

# NOTE: the methods tested are from BaseDb but we should be instantiating Db instead
describe Db do
  context 'given connect_for block' do
    it 'performs a transaction' do
      mock_pg

      actual = nil
      db = Db.new
      db.connect_for('stuff') do |conn|
        conn.prepare('something', 'sql2')
        res = conn.exec_prepared('something', nil)
      end
      expect(@connclosed).to eq(true)
      expect(@triggered_txn).to eq(true)
    end
  end

  context 'given basic collection_from_sql query' do
    it 'returns an expected result' do
      mock_pg

      db = Db.new
      expect(db.collection_from_sql(
               sql: 'sql1',
               params: nil,
               result_map: {
                 id: true,
                 name: true
               },
               description: 'whatever'
             )).to eq([{ 'id': 1, 'name': 'lll' }, { 'id': 2, 'name': 'abcde' }])
      # and make sure we attempted to close the connection
      expect(@connclosed).to eq(true)
    end
  end

  context 'given an invalid sql query' do
    it 'raises an error' do
      mock_pg

      db = Db.new
      expect do
        db.collection_from_sql(
          sql: 'badsql',
          params: nil,
          result_map: {
            id: true,
            name: true
          },
          description: 'whatever'
        )
      end.to raise_error(PG::Error)
      # and make sure we attempted to close the connection
      expect(@connclosed).to eq(true)
    end
  end
end
