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