select m.display_title,m.artist, m.secs,
s1.last_played as last_played_title, s2.total_plays as total_plays_title,
s3.last_played as last_played_artist, s4.total_plays as total_plays_artist
from 
(select 
      case
        when (
          title is null
          or title = ''
        ) then substring(
          song_filepath
          from '[^/]*$'
        )
        else coalesce(artist, 'unknown') || ' - ' || coalesce(title, 'unknown')
      end as display_title,
artist, secs
from mp3s_metadata where file_hash = $1) m
left join mp3s_stats s1 on s1.item = m.display_title and s1.category = 'TITLE'
left join mp3s_stats_hist s2 on s2.item = m.display_title and s2.category = 'TITLE'
left join mp3s_stats s3 on s3.item = m.artist and s3.category = 'ARTIST'
left join mp3s_stats_hist s4 on s4.item = m.artist and s4.category = 'ARTIST';