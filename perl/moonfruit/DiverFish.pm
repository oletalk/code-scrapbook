package DiverFish;
use base Fish;
use Constants;
use strict;

sub swimsAtDepth {
	my $self = shift;
	my ($depth) = @_;
	($depth == Constants::DEPTH_BOTTOM);
}

1;