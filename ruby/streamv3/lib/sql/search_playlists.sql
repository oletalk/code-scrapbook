select name,
  owner,
  date_created,
  date_modified,
  display_title
from (
    select p.id,
      p.name,
      p.owner,
      p.date_created,
      p.date_modified,
      m.file_hash,
      secs,
      case
        when (
          title is null
          or title = ''
        ) then substring(
          song_filepath
          from '[^/]*$'
        )
        else coalesce(artist, 'unknown') || ' - ' || coalesce(title, 'unknown')
      end as display_title
    from mp3s_playlist p,
      mp3s_playlist_song ps,
      mp3s_metadata m
    where ps.playlist_id = p.id
      and m.file_hash = ps.file_hash
  ) full_pls
where lower(display_title) like $1;