select name, file_hash, secs, display_title from
(
select p.name, m.file_hash, secs,
case
  when (title is null or title = '') then substring(song_filepath from '[^/]*$')
  else coalesce(artist, 'unknown') || ' - ' || coalesce(title, 'unknown')
end as display_title
from mp3s_playlist p, mp3s_playlist_song ps, mp3s_metadata m
where ps.playlist_id = p.id
and m.file_hash = ps.file_hash
) full_pls 
where display_title like $1;