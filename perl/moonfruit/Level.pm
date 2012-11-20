package Level;
$VERSION = 1.00;

use strict;
use Carp;
use Constants;

sub new {
	my $class = shift;
	my ($depth) = @_;
	my @creatures = ();
	bless {
		'depth' => $depth,
		'capacity' => Constants::DEFAULT_CAPACITY,
		'creatures' => \@creatures
	}, $class;
}

sub add {
	my $self = shift;
	
	my $ret = 0;
	my ($creature) = @_;
	my $capacity = $self->{'capacity'};
	
	if ($creature->isAlive) {
		if ($creature->swimsAtDepth($self->depth)) {
			push @{$self->{'creatures'}}, $creature;
			$creature->set_container( $self );
			$ret = 1;
		}
	} else { # dead creature at the surface!
		if ($self->depth == Constants::DEPTH_SURFACE) {
			push @{$self->{'creatures'}}, $creature;
			$ret = 1;
		}
	}
	
	$ret;
}

sub is_crowded {
	my $self = shift;
	my $num_creatures = scalar @{$self->{'creatures'}};
	my $capacity = $self->{'capacity'};
	
	$num_creatures > $capacity;
}

sub depth {
	my $self = shift;
	$self->{'depth'};
}

sub population {
	my $self = shift;
	@{$self->{'creatures'}};
}

sub print {
	my $self = shift;
	print "| Depth: " . $self->depth. "\n";
	
	my @creatures = $self->population;
	print "| Crowding: " . scalar @creatures . "/". $self->{'capacity'} . "\n";
	print "| Population: ";
	my %clist = ();
	foreach my $creature (@creatures) {
		my $type = ref $creature;
		$type = "dead $type" unless $creature->isAlive;
		$clist{$type}++;
	}
	
	my @poplist = ();
	foreach (sort keys %clist) {
		push @poplist, $clist{$_} . " $_" 
	}
	print join(",", @poplist) . "\n";

}

sub randomCreature {
	my $self = shift;
	my @creatures = @{$self->{'creatures'}};
	my $ret = undef;
	
	my $num = scalar @creatures;
	if ($num > 0) {
		my $f = int(rand($num));
		$ret = $creatures[$f];
	}
}

# Passes 1 unit of time for this level. return value is a list of any dead creatures.
sub pass_time {
	my $self = shift;
	my ( $env ) = @_;
	
	my @ret = ();

	my @creatures = ();

	#use Data::Dumper;
	#print "*** env passed from Level-pass_time: " . Dumper(\$env);
	
	foreach my $creature (@{$self->{'creatures'}}) {
		$creature->pass_time( $env );
		
		# did it die?
		if ($creature->isAlive) {
			push @creatures, $creature;
		} else {
			$env->add_dead_creature( $creature );
			#push @ret, $creature;
		}
	}
	
	@{$self->{'creatures'}} = @creatures;
	
	@ret;
}

1;