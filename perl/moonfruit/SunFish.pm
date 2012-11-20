package SunFish;
use base Fish;

use strict;

sub swimsAtDepth {
	my $self = shift;
	my ($depth) = @_;
	($depth == Constants::DEPTH_TOP);
}

1;