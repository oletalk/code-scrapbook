package Creature;
$VERSION = 1.00;

use strict;
use Constants;

sub new {
	my $class = shift;
	my ($vitality) = @_;
	bless {
		'vitality' => $vitality,
		'container' => undef
	}, $class;
}

sub set_container {
	my $self = shift;
	my ($c) = @_;
	die "Creature's Container must be a Level" unless $c->isa('Level');
	$self->{'container'} = $c;
}

sub get_container {
	my $self = shift;
	$self->{'container'};
}

sub swimsAtDepth {
	1;
}

sub pass_time {
	my $self = shift;
	my ( $env ) = @_;
		
	if ($self->get_container && $self->get_container->is_crowded) {
		$self->suffocate( $env );
	}
		
	$self->eat( $env );
	my $v = $self->{'vitality'};
	$v-- if $v > 0;
	$self->{'vitality'} = $v;
}

sub suffocate {
	my $self = shift;
	my ( $env ) = @_;
	if ($self->isAlive && $self->breathes) {
		$env->add_event( "  [" . (ref $self) . "] Creature does not have enough air! It dies...");
		$self->expire;
	}
}

sub expire {
	my $self = shift;
	$self->{'vitality'} = Constants::VITALITY_DEAD;
}

sub breathes {
	1; # most creatures breathe
}

sub eats {
	1; # most creatures eat
}

sub eat {
	my $self = shift;
	my ( $env ) = @_;
	
	if ($self->isAlive && $self->eats) {
		my $food = $env->give_food(1);
		if ($food > 0) {
			$env->add_event( "  [" . (ref $self) . "] eating..." );
			$self->{'vitality'} += $food;			
		} else {
			$env->add_event( "  [" . (ref $self) . "] no food..." );
		}
	}
}

sub isAlive {
	my $self = shift;
	$self->{'vitality'} > Constants::VITALITY_DEAD;
}

sub canBeRemoved {
	my $self = shift;
	$self->{'vitality'} <= Constants::VITALITY_REMOVED;
}

1;