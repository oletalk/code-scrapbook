package Tank;
$VERSION = 1.00;

use strict;
use Carp;
use Constants;
use Level;

my $tank;

sub new {
	my $class = shift;
	$tank ||= bless {
		'Levels' => { 'SURFACE' => Level->new(Constants::DEPTH_SURFACE),
					  'TOP'     => Level->new(Constants::DEPTH_TOP),
					  'MIDDLE'  => Level->new(Constants::DEPTH_MIDDLE),
					  'BOTTOM'  => Level->new(Constants::DEPTH_BOTTOM)
					  },
		'temperature' => Constants::START_TEMPERATURE,
		'foodamount' => 0
	}, $class;
}

sub add_food {
	my $self = shift;
	my ($amt) = @_;
	if ($amt > 0) {
		$self->{'foodamount'} += $amt;
		print "Added food, amount $amt \n";
	}
}

sub levelAt {
	my $self = shift;
	my ($l) = @_;
	
	my %levels = %{$self->{'Levels'}};
	$levels{$l};
}

sub change_temp {
	my $self = shift;
	my ($newtemp) = @_;
	
	$self->{'temperature'} = $newtemp;
}

sub add {
	my $self = shift;
	my ($creature, $l) = @_;
	my $ret = 0;
	
	#my %levels = %{$self->{'Levels'}};
	#my $level = $levels{$l};
	
	my $level = $self->levelAt($l);
	if ($level) {
		if ($level->add($creature)) {
			print "Successfully added creature\n";
			$ret = 1;
		} else {
			print "Unable to add creature - it does not swim at this level\n";
		}
	} else {
		carp "Unknown level $l";
	}
}

sub float_up {
	my $self = shift;
	my ($creature) = @_;
	if ($creature->isAlive) {
		carp "Creature is not dead yet - can't make it float up to surface";
	} else {
		if ($creature->canBeRemoved) {
			carp "Creature has been destroyed - nothing to float up to surface";
		} else {
			my $surface = $self->levelAt('SURFACE');
			$surface->add($creature);
		}
	}
}

sub pass_time {
	my $self = shift;
	
	my %levels = %{$self->{'Levels'}};
	foreach my $level 
		(sort 
			{$levels{$a}->depth <=> $levels{$b}->depth} 
		keys %levels) {
		my @dead_fish = $levels{$level}->pass_time( $self->{'temperature'} );
		print "[ $level ] " . scalar @dead_fish . " creature(s) died this round.\n";
		foreach (@dead_fish) {
			$self->float_up($_) unless $_->canBeRemoved;
		}
		$levels{$level}->print;
	}
	print "Current Tank temperature: " . $self->{'temperature'} . " C\n";	
	print "Amount of food in tank  : " . $self->{'foodamount'} . " units\n";	
	print "\n";
}

1;