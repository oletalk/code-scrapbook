package TagInfo;

use strict;
use Carp;
use MP3::Info;
use Digest::SHA qw(sha1_hex); # TODO: this isn't really being used right now
use MSConf qw(config_value);

sub new {
	my $class = shift;
	my %content = ( @_ );
	
	bless \%content, $class;
}

sub generate_tags {
	my $self = shift;
	my (%args) = @_;
	
	my $DELIM = "|||";
	my $progress = 0;
	if ($args{'progress_batchsize'}) {
		$progress = int($args{'progress_batchsize'});
	}
	
	my $fh_hashes;
	if (config_value('tagsfile')) {
		my $filename = config_value('tagsfile');
		#read in anything already existing in the tagsfile
		$self->read_tags($filename);
		#then write out anything else we've encountered
		open ($fh_hashes, ">>", $filename) or warn "Unable to open hashes file for writing: $!";
	}
	
	if ($self->{'tags'}) {
		warn"Tags already generated";
	} 
	
	my $pl = $self->{'playlist'};
	
	my $ctr = 0;
	my $total = scalar $pl->list_of_songs;
	
	my %hashes = ();
	foreach my $song_obj ($pl->list_of_songs) {
		my $song = $song_obj->get_filename;		
		my $file_hash = sha1_hex($song);
		
		unless (defined $self->{'tags'}->{$song}) {
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

				unless ($hashes{$file_hash}) {
					if (defined $fh_hashes) { # FIXME hacky - do we or don't we need a tagsfile??
						print $fh_hashes join($DELIM, ($song, $file_hash, $artist, $title, $secs)); 
						print $fh_hashes "\n";						
					}
				}

			} else {
				warn "Tag not found for file $song";
				if (defined $fh_hashes) { #FIXME! see above :-/
					print $fh_hashes join($DELIM, ($song, $file_hash));
					print $fh_hashes "\n";
				}
			}
			$ctr++;
			if ($progress > 0 && $ctr % $progress == 0) {
				print "Song tags processed: $ctr of $total \n";				
			}
			
		}	
	}

	close $fh_hashes if $fh_hashes;
	
	$self->{'loaded'} = 1;
	warn "Done generating tags";
}

sub read_tags {
	my $self = shift;
	my ($tags_filename) = @_;
	
	my $fh = undef;
	open $fh, $tags_filename or warn "Unable to open tagfile $tags_filename: $!";
	
	if (defined $fh) {
		while (<$fh>) {
			my ($song, $file_hash, $artist, $title, $secs) = split(/\|\|\|/, $_);
			chomp $secs if $secs;
			$self->{'tags'}->{$song}->{'artist'} = $artist;
			$self->{'tags'}->{$song}->{'title'} = $title;
			$self->{'tags'}->{$song}->{'secs'} = $secs;
		}
		close $fh;
	}
}

sub _get_tracktag_info {
	my $self = shift;
	my ($song_obj, @props) = @_;
	
	my $song = $song_obj->get_filename;
	
	my @ret = ();
	if ($self->{'tags'}) {
		my $tracktag = $self->{'tags'}->{$song};
		if ($tracktag) {
			foreach my $prop (@props) {
				my $propval = $tracktag->{$prop};
				push @ret, $propval;
			}
		}
	} else {
		warn "Tags not available";
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

sub get_trackname {
	my $self = shift;
	my ($song_obj) = @_;
	
	my ($artist, $title) = $self->_get_tracktag_info($song_obj, 'artist', 'title');
	$artist ||= "Unknown Artist";
	$title  ||= "Unknown Title";
	
	"${artist} - ${title}";
}

1;