INSERT into mp3s_metadata
(song_filepath, file_hash, artist, title, secs)
VALUES($1, $2, $3, $4, $5)
ON CONFLICT (song_filepath) DO
UPDATE 
SET artist = excluded.artist, 
title = excluded.title, 
secs = excluded.secs