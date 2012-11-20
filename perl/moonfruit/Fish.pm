package Fish;

use base Creature;
use Constants;
use strict;

sub new {
	my $class = shift;
 	$class->SUPER::new(Constants::DEFAULT_VITALITY_FISH);
}

sub getEaten {
	my $self = shift;
	$self->{'vitality'} = Constants::VITALITY_REMOVED;
}

1;