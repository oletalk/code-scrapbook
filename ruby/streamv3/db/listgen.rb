# frozen_string_literal: true

require_relative 'db'

# generate playlist contents for /m3u/
class ListGen
  include Db

  def initialize(hostheader:)
    @hh = hostheader
  end

  # fetch the playlist i use 90+% of the time...
  def fetch_all_tunes
    ret = "#EXTM3U\n".dup # don't freeze the initial string plz
    connect_for('full playlist') do |conn|
      sql = File.read('./sql/all_tunes.sql')
      conn.exec(sql) do |result|
        result.each do |result_row|
          hash = result_row['file_hash']
          url = "http://#{@hh}/play/#{hash}"
          ret << m3uitem(result_row['secs'], result_row['display_title'], url)
        end
      end
    end
    ret
  end

  # fetch a named playlist
  def fetch_playlist(name:)
    ret = "#EXTM3U\n".dup # don't freeze the initial string plz
    playlist_sql = File.read('./sql/named_pls.sql')
    connect_for('named playlist') do |conn|
      conn.prepare('pls_sql', playlist_sql)
      conn.exec_prepared('pls_sql', [name]) do |result|
        result.each do |result_row|
          hash = result_row['file_hash']
          url = "http://#{@hh}/play/#{hash}"
          ret << m3uitem(result_row['secs'], result_row['display_title'], url)
        end
      end
    end
    ret
  end

  def m3uitem(secs, title, url)
    line1 = "#EXTINF:#{secs},#{title}"
    "#{line1}\n#{url}\n"
  end
end
