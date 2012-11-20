package Environment;

use Constants;
use Creature;

use Carp;
use strict;

sub new {
	my $class = shift;
	my @dead_creatures = ();
	my @events = ();
	bless {
		'temperature' => Constants::START_TEMPERATURE,
		'foodamount' => 0,
		'dead_creatures' => \@dead_creatures,
		'events' => \@events
	}, $class;	

}

sub add_event {
	my $self = shift;
	my @evts = @_;
	push @{$self->{'events'}}, @evts;		
}

sub consume_events {
	my $self = shift;
	my @ret = @{$self->{'events'}};
	@{$self->{'events'}} = (); 
	@ret;
}

sub get_foodamount {
	my $self = shift;
	$self->{'foodamount'};
}

sub give_food {
	my $self = shift;
	my ($food_req) = @_;
	if ($self->{'foodamount'}  >= $food_req) {
		$self->{'foodamount'} -= $food_req;
	} else {
		$food_req = $self->{'foodamount'};
		$self->{'foodamount'} = 0;
	}
	$food_req;
}

sub add_food {
	my $self = shift;
	my ($foodamt) = @_;
	if ($foodamt > 0) {
		$self->{'foodamount'} += $foodamt;
		print "Added food, amount $foodamt \n";
	}
}

sub change_temperature {
	my $self = shift;
	my ($newtemp) = @_;
	$self->{'temperature'} = $newtemp;
}

sub get_temperature {
	my $self = shift;
	$self->{'temperature'};
}

sub has_dead_creatures {
	my $self = shift;
	scalar @{$self->{'dead_creatures'}} > 0;
}

sub add_dead_creature {
	my $self = shift;
	my (@creatures) = @_;
	foreach my $dc (@creatures) {
		if ($dc->isAlive) {
			carp "Can't add a live creature into dead_creatures list";
		} else {
			push @{$self->{'dead_creatures'}}, $dc;
		}
	}
}

sub give_dead_creature {
	my $self = shift;
	my $ret = undef;
	
	$ret = pop @{$self->{'dead_creatures'}};
}

sub print {
	my $self = shift;
	
	print "Current Tank temperature: " . $self->get_temperature . " C\n";	
	print "Amount of food in tank  : " . $self->get_foodamount . " units\n";	
	print "\n";
	
}

1;