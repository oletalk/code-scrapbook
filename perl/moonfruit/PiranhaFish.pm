package PiranhaFish;

use base Fish;
use Carp;
use Constants;
use strict;

# CM 16/8 22:40 TODO: when does the Piranha eat??

sub eat {
	my $self = shift;
	my ( $env ) = @_;
	$self->SUPER::eat( $env );
	
	my ($fish) = $self->get_container->randomCreature;
	
	if ($fish && $fish != $self) {
		if ($fish->isa('Fish')) {
			$env->add_event( "The Piranha ate a Fish..." );
			$fish->getEaten;
		}		
	}
	
}

sub pass_time {
	my $self = shift;
	my ( $env ) = @_;
	
	my $temp = $env->get_temperature();
	$self->SUPER::pass_time( $env );
	if ($self->isAlive && $temp < Constants::PIRANHA_MIN_TEMP) {
		$self->expire;
	}
}

1;