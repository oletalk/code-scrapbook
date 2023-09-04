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
    allow(conn).to receive(:exec).and_yield(fake_result)
  end

  def fake_hashsong(title, duration, can_record)
    hsong = double('hashsong')
    allow(hsong).to receive(:is_a?).and_return(HashSong)
    allow(hsong).to receive(:display_title).and_return(title)
    allow(hsong).to receive(:secs).and_return(duration)
    allow(hsong).to receive(:playing_stats).and_return([])
    allow(hsong).to receive(:record_stat) if can_record
    hsong
  end
end
