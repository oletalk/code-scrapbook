package MP3S::Music::TagInfo;

use strict;
use Carp;
use MP3::Info;
use Digest::SHA qw(sha1_hex); # TODO: this isn't really being used right now

use MP3S::Misc::MSConf qw(config_value);
use MP3S::DB::Access;
use MP3S::Misc::Logger qw(log_debug log_info log_error);

sub new {
	my $class = shift;
	my %content = ( @_ );
	
	bless \%content, $class;
}

sub generate_tags {
	my $self = shift;
	my (%args) = @_;
	
	my $progress = 0;
	if ($args{'progress_batchsize'}) {
		$progress = int($args{'progress_batchsize'});
	}
		
	my $pl = $self->{'playlist'};
	
	my $ctr = 0;
	my $total = scalar $pl->list_of_songs;
	
	my %hashes = ();
	
	my $db = MP3S::DB::Access->new;
	
	foreach my $song_obj ($pl->list_of_songs) {
		my $song = $song_obj->get_filename;		
		my $file_hash = sha1_hex($song);
		
		my $res = $db->exec_single_cell("SELECT 1 FROM MP3S_tags WHERE song_filepath = ?", $song);
		
		unless ($res == 1) {
			my $mp3tag = get_mp3tag($song);
			my $mp3info = get_mp3info($song);

			if ($mp3tag) {
				my $artist = $mp3tag->{'ARTIST'};
				my $title  = $mp3tag->{'TITLE'};
				my $secs   = -1;
				$self->{'tags'}->{$song}->{'artist'} = $artist;
				$self->{'tags'}->{$song}->{'title'} = $title;
				if ($mp3info) {
					$secs = $mp3info->{'SECS'};
					$secs = int($secs);
					$self->{'tags'}->{$song}->{'secs'} = $secs;					
				}
				$db->execute(qq{
					INSERT INTO MP3S_tags (song_filepath, file_hash, artist, title, secs)
					VALUES (?, ?, ?, ?, ?);
				}, $song, $file_hash, $artist, $title, $secs);
				log_info("Problem inserting tag for $song") if $db->errstr;

#						print $fh_hashes join($DELIM, ($song, $file_hash, $artist, $title, $secs)); 

			} else {
				log_info("Tag not found for file $song");
#					print $fh_hashes join($DELIM, ($song, $file_hash));
				$db->execute(qq{
					INSERT INTO MP3S_tags (song_filepath, file_hash)
					VALUES (?, ?);
				}, $song, $file_hash);
				log_error("Problem inserting tag for $song") if $db->errstr;
			}
			$ctr++;
			if ($progress > 0 && $ctr % $progress == 0) {
				print "Song tags processed: $ctr of $total \n";				
			}
			
		}	
	}
	
	warn "Done generating tags";
}

sub _get_tracktag_info {
	my $self = shift;
	my ($song_obj, @props) = @_;
	
	my $song = $song_obj->get_filename;
	
	my @ret = ();
	
	my $proplist = join(', ', @props); # CM FIXME: input validation pls!
	
	my $db = MP3S::DB::Access->new;
	my $track_info = $db->exec_single_row(qq{
		SELECT $proplist 
		FROM MP3S_tags
		WHERE song_filepath = ?
	}, $song);
	foreach (@$track_info) {
		push @ret, $_;
	}
	log_error("Problem getting tag for $song") if $db->errstr;
	
	@ret;
}

sub get_tracksecs {
	my $self = shift;
	my ($song_obj) = @_;
	
	my ($secs) = $self->_get_tracktag_info($song_obj, 'secs');
	$secs ||= -1;
	$secs = int($secs);
	
	return $secs;
}

sub get_trackname {
	my $self = shift;
	my ($song_obj) = @_;
	
	my ($artist, $title) = $self->_get_tracktag_info($song_obj, 'artist', 'title');
	$artist ||= "Unknown Artist";
	$title  ||= "Unknown Title";
	
	"${artist} - ${title}";
}

1;