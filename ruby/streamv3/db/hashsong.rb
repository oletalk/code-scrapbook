# frozen_string_literal: true

require_relative 'db'

# fetch song data from given hash
class HashSong
  include Db

  attr_reader :file_hash,
              :secs,
              :song_filepath,
              :display_title,
              :found

  def initialize(hash:)
    connect_for('fetching song data from hash') do |conn|
      sql = File.read('./sql/one_tune.sql')
      conn.prepare('song_data', sql)
      found_song = false
      conn.exec_prepared('song_data', [hash]) do |result|
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
end
