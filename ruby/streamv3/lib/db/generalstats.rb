# frozen_string_literal: true

require_relative 'db'
require_relative '../sql/sql_read'

# fetch top-level stats (not related to any song)
class GeneralStats
  include Db
  include SqlRead

  attr_reader :file_hash,
              :secs,
              :song_filepath,
              :display_title,
              :found

  def playing_stats
    ret = []

    connect_for('fetching top artist stats') do |conn|
      sql = sqlfrom('top_artists')
      conn.exec(sql) do |result|
        result.each do |result_row|
          ret.push({
                     item: result_row['item'],
                     total_plays: result_row['total_plays']
                   })
        end
      end
    end
    ret
  end
end
