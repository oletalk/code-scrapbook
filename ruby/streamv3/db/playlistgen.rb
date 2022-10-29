# frozen_string_literal: true

require_relative 'db'
require_relative '../data/playlist'
require_relative '../data/playlist_entry'
require 'json'

# generate playlist contents for /playlist/
class PlaylistGen
  include Db

  def initialize(hostheader:)
    @hh = hostheader
  end

  def fetch_all_playlists
    ret = [] # don't freeze the initial string plz
    connect_for('list of playlists') do |conn|
      sql = File.read('./sql/all_playlists.sql')
      conn.exec(sql) do |result|
        result.each do |result_row|
          # hash = result_row['file_hash']
          # url = "http://#{@hh}/play/#{hash}"
          ret.push(
            NamedPlaylist.new(
              result_row['name'], result_row['owner'],
              result_row['date_created'], result_row['modified']
            )
          )
        end
      end
    end
    ret
  end

  def fetch_tunes(name:)
    ret = []
    playlist_sql = File.read('./sql/named_pls.sql')
    connect_for('named playlist') do |conn|
      conn.prepare('pls_sql', playlist_sql)
      conn.exec_prepared('pls_sql', [name]) do |result|
        result.each do |result_row|
          hash = result_row['file_hash']
          url = "http://#{@hh}/play/#{hash}"
          ret.push(
            PLEntry.new(result_row['display_title'], url,
                        result_row['secs'])
          )
        end
      end
    end
    ret
  end
end
