select file_hash,
  secs,
  song_filepath,
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
from mp3s_metadata
where file_hash = $1