package Tank;
$VERSION = 1.00;

use strict;
use Carp;
use Constants;
use Environment;
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
		'environment' => Environment->new()
	}, $class;
}

sub env {
	my $self = shift;
	$self->{'environment'}
}

sub add_food {
	my $self = shift;
	my ($amt) = @_;
	$self->env->add_food($amt);
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
	
	$self->env->change_temperature($newtemp);
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
			#print "Successfully added creature\n";
			$ret = 1;
		} else {
			carp "Unable to add creature - it does not swim at this level\n";
		}
	} else {
		croak "Unknown level '$l'";
	}
}

sub __float_up {
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
	my ($quietly) = @_;
	
	my %levels = %{$self->{'Levels'}};
	foreach my $level 
		(sort 
			{$levels{$a}->depth <=> $levels{$b}->depth} 
		keys %levels) {
		
		my $dead_fish_total = 0;
		$levels{$level}->pass_time( $self->env );
		while ($self->env->has_dead_creatures) {
			my $c = $self->env->give_dead_creature;
			$self->__float_up($c) unless $c->canBeRemoved;
			$dead_fish_total++;
		}
		unless ($quietly) {
			foreach my $event ($self->env->consume_events) {
				print "$event \n";
			}
			
			print "[ $level ] $dead_fish_total dead creature(s) now.\n";
			$levels{$level}->print;
		}
	}
	$self->env->print unless $quietly;
}

1;