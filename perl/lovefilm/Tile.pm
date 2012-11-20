package Tile;
$VERSION = 1.00;

use strict;
use Carp;

sub new {
	my $class = shift;
	my ($lhs, $rhs) = @_;
	
	croak "Invalid # of pips on left hand side of domino: $lhs" unless ($lhs >= 0 and $lhs <= 6);
	croak "Invalid # of pips on right hand side of domino: $rhs" unless ($rhs >= 0 and $rhs <= 6);
	
	bless { '_lhs' => $lhs,
			'_rhs' => $rhs
			}, $class;
}

# Left hand side #of pips
sub lhs {
	my $self = shift;
	$self->{'_lhs'};
}

# Right hand side #of pips
sub rhs {
	my $self = shift;
	$self->{'_rhs'};
}

# Does this match an incoming tile? i.e. its RHS matches the other tile's LHS
sub matches {
	my $self = shift;
	my ($other) = @_;
	my $ret = 0;
	$ret = 1 if $self->rhs == $other->lhs;
}

sub points {
	my $self = shift;
	$self->lhs + $self->rhs;
}

sub display {
	my $self = shift;
	"Tile: " . $self->lhs . "|" . $self->rhs;
}