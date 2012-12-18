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

sub read_tags_from_db {
	my $self = shift;
	my $db = MP3S::DB::Access->new;
		
	my $res = $db->execute(qq{
		SELECT song_filepath, file_hash, artist, title, secs
		FROM MP3S_tags;
	});
	
	foreach my $row(@$res) {
		my ($song, $fhash, $artist, $title, $secs) = @$row;
		$self->{'tags'}->{$song}->{'artist'} = $artist;
		$self->{'tags'}->{$song}->{'title'} = $title;
		$self->{'tags'}->{$song}->{'secs'} = $secs;							
	}
	log_info("Done reading tags from the database.");
	
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
	my $total = scalar $pl->_master_list_of_songs;
	
	my %db_songs = ();
	
	my $db = MP3S::DB::Access->new;
	
	my $res1 = $db->execute("SELECT song_filepath FROM MP3S_tags");
	foreach my $row (@$res1) {
		$db_songs{$row->[0]} = 1;
	}
	
	foreach my $song_obj ($pl->_master_list_of_songs) {
		my $song = $song_obj->get_filename;		
		my $file_hash = sha1_hex($song);
				
		unless (defined $db_songs{$song}) {
			my $mp3tag = get_mp3tag($song);
			my $mp3info = get_mp3info($song);

			if ($mp3tag) {
				my $artist = $mp3tag->{'ARTIST'};
				my $title  = $mp3tag->{'TITLE'};
				my $secs   = -1;
				if ($mp3info) {
					$secs = $mp3info->{'SECS'};
					$secs = int($secs);
				}
				
				$artist = substr($artist, 0, 99); # fix for some really really long artists in my collection! :-S
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
	
	die "Tag info not available" unless $self->{'tags'};
	my $song = $song_obj->get_filename;
	
	my @ret = ();
	
	my $proplist = join(', ', @props); # CM FIXME: input validation pls!
	
	my $track_info = $self->{'tags'}->{$song};
	
	foreach (@props) {
		push @ret, $track_info->{$_};
	}
	
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

sub get_artist {
	my $self = shift;
	my ($song_obj) = @_;
	
	my ($artist) = $self->_get_tracktag_info($song_obj, 'artist');
	$artist;
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