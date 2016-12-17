package tests::mocks::MockTagInfo;
use parent MP3S::Music::TagInfo;

use MP3S::Misc::Logger qw(log_info);
use strict;

sub read_tags_from_db {
	my $self = shift;
	
	$self->{'tags'}->{'tests/testdata/first.mp3'} = {artist => 'Mr Foo',
													 title  => 'Track 1',
													 secs   => 100};
	$self->{'tags'}->{'tests/testdata/sec ond.mp3'} = {artist => 'Mr Foo',
													 title  => 'Track 2',
													 secs   => 90};
	$self->{'tags'}->{'tests/testdata/third.mp3'} = {artist => 'Mr Foo',
													 title  => 'Track 3',
													 secs   => 122};

}

sub generate_tags {
	log_info( "Mock object: No tags written to the database.");
}

1;
