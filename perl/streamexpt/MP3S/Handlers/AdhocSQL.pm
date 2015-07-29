package MP3S::Handlers::AdhocSQL;

use strict;
use Carp;

use MP3S::DB::Access;
use MP3S::Misc::Logger qw(log_info);

sub fetch_playlist {
  my ($plsname) = @_;
  my $db = MP3S::DB::Access->new;

  my $res = $db->execute(qq{
    select 
        t.song_filepath, t.artist, t.title, t.secs, s.song_order
    from mp3s_tags t 
    join playlist_song s on t.song_filepath = s.song_filepath 
    where playlist_id in 
        (select id from playlist where name = ?)
    order by s.song_order
  }, $plsname);
  my $num_rows = scalar @$res;
  log_info("Playlist $plsname has $num_rows row(s) in the database.");
# debugging stuff
  foreach my $row (@$res) {
    my ($song_filepath, $artist, $title, $secs, $song_order) = @$row;
    log_info("Got song # $song_order : $artist - $title ( $song_filepath )");
  }
  return $res;
}

1;
