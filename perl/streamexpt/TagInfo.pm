package TagInfo;

use strict;
use Carp;
use MP3::Info;

sub new {
	my $class = shift;
	my %args = @_;
	
	bless \%args, $class;
}

sub generate_tags {
	my $self = shift;
	if ($self->{'tags'}) {
		warn"Tags already generated";
	} else {
		my $pl = $self->{'playlist'};
		foreach my $song_obj ($pl->list_of_songs) {
			my $song = $song_obj->get_filename;
			my $mp3tag = get_mp3tag($song);
			my $mp3info = get_mp3info($song);
			
			if ($mp3tag) {
				$self->{'tags'}->{$song}->{'artist'} = $mp3tag->{'ARTIST'};
				$self->{'tags'}->{$song}->{'title'} = $mp3tag->{'TITLE'};
				if ($mp3info) {
					my $secs = $mp3info->{'SECS'};
					$self->{'tags'}->{$song}->{'secs'} = int($secs);					
				}
			} else {
				warn "Tag not found for file $song";
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
	$secs = int($secs);
	$secs ||= -1;
	
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