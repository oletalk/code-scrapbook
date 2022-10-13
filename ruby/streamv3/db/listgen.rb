# frozen_string_literal: true

require_relative 'db'

# generate playlist contents for /m3u/
class ListGen
  include Db

  # fetch the playlist i use 90+% of the time...
  def fetch_all
    connect_for('full playlist') do |conn|
      sql = %(
        select file_hash, artist, title, secs
        from mp3s_metadata
      )
      conn.exec(sql) do |result|
        result.each do |result_row|
          puts result_row.keys
        end
      end
    end
  end

  # fetch a named playlist
  def fetch_playlist(name)
    playlist_sql = %(
    select p.name, ps.file_hash, secs,
    case
      when (title is null or title = '') then substring(song_filepath from '[^/]*$')
      else coalesce(artist, 'unknown') || ' - ' || coalesce(title, 'unknown')
    end as display_title
    from mp3s_playlist p, mp3s_playlist_song ps, mp3s_metadata t
    where ps.file_hash = t.file_hash
    and p.id = ps.playlist_id
    and p.name = $1
    order by entry_order
    )
    connect_for('named playlist') do |conn|
      conn.prepare('pls_sql', playlist_sql)
      conn.exec_prepared('pls_sql', [name]) do |result|
        result.each do |result_row|
          puts result_row.keys
        end
      end
    end
  end
end
