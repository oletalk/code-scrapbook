create or replace function record_mp3_stat(hash varchar(255))
  returns void
as
$$
declare
	s_title varchar(255);
  s_artist varchar(255);
  s_song varchar(2000);
begin
-- 1. collect filepath, title and artist for the given hash
select into s_song, s_title, s_artist
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
      end as display_title,
artist 
from mp3s_metadata where file_hash = hash;
-- 2. write stat for artist (if not null).
--    if a stat has already been recorded the 'number of plays' will be incremented.
if s_song is null then
-- it's unlikely the song path is null if the song has been found
  raise exception 'Song for hash "%" was not found %', hash, now();
end if;
if s_artist is not null then
	insert into mp3s_stats (category, item) values ('ARTIST', s_artist)
	on conflict (category, item)
	do update set plays = mp3s_stats.plays+1, last_played = current_timestamp; 
end if;
-- 3. similarly for the song file path (shouldn't really be null so no null check)
insert into mp3s_stats (category, item) values ('SONG', s_song)
on conflict (category, item)
do update set plays = mp3s_stats.plays+1, last_played = current_timestamp; 
-- 4. and for the song title
insert into mp3s_stats (category, item) values ('TITLE', s_title)
on conflict (category, item)
do update set plays = mp3s_stats.plays+1, last_played = current_timestamp; 
end;
$$ language plpgsql;