package Snail;

use base Creature;
use Constants;
use strict;

use strict;

sub new {
	my $class = shift;
 	$class->SUPER::new(Constants::DEFAULT_VITALITY_SNAIL);
}

sub swimsAtDepth {
	my $self = shift;
	my ($depth) = @_;
	($depth == Constants::DEPTH_BOTTOM);  # it's a snail...
}

1;