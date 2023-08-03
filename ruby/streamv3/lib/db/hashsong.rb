# frozen_string_literal: true

require_relative 'db'
require_relative '../sql/sql_read'

# fetch song data from given hash
class HashSong
  include Db
  include SqlRead

  attr_reader :file_hash,
              :secs,
              :song_filepath,
              :display_title,
              :found

  def initialize(hash:)
    connect_for('fetching song data from hash') do |conn|
      sql = sqlfrom('one_tune')
      conn.prepare('song_data', sql)
      found_song = false
      conn.exec_prepared('song_data', [hash.strip]) do |result|
        result.each do |result_row|
          @file_hash = result_row['file_hash']
          @secs = result_row['secs']
          @song_filepath = result_row['song_filepath']
          @display_title = result_row['display_title']
          found_song = true
        end
      end
      @found = found_song
    end
  end

  def record_stat
    connect_for('recording that song was played') do |conn|
      conn.prepare('record_stat', 'select record_mp3_stat($1)')
      conn.exec_prepared('record_stat', [@file_hash])
    end
  end
end
