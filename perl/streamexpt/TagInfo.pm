package TagInfo;

use strict;
use Carp;
use MP3::Tag;

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
			my $mp3 = MP3::Tag->new($song);
			$mp3->get_tags;
			my $id3 = $mp3->{ID3v2};
			if ($id3) {
				$self->{'tags'}->{$song} = $id3;
			} else {
				$id3 = $mp3->{ID3v1};
				if ($id3) {
					$self->{'tags'}->{$song} = $id3;
				} else {
					warn "Tag not found for file $song";
				}
			}
		}
	}
	warn "Done generating tags";
}

sub get_trackname {
	my $self = shift;
	my ($song_obj) = @_;
	
	my $song = $song_obj->get_filename;
	my $ret = undef;
	if ($self->{'tags'}) {
		my $tracktag = $self->{'tags'}->{$song};
		if ($tracktag) {
			my $trackno = $tracktag->track;
			$trackno = "${trackno}. " if $trackno;
			my $artist = $tracktag->artist || "Unknown Artist";
			my $title  = $tracktag->title  || "Unknown Title";
			$ret = "${trackno}${artist} - ${title}";			
		}
	} else {
		warn "Tags not generated or available";
	}
	$ret;
}

1;