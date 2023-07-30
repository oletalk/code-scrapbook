# frozen_string_literal: true

require_relative '../../lib/db/db'

module DbHelpers
  def fake_conn(fake_result)
    conn = double(PG::Connection)
    allow_any_instance_of(Db).to receive(:new_connection).and_return(conn)
    allow(conn).to receive(:close)
    allow(conn).to receive(:transaction).and_yield(conn)
    allow(conn).to receive(:prepare)
    allow(conn).to receive(:exec_prepared).and_yield(fake_result)
  end
end
