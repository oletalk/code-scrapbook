package Stock;
$VERSION = 1.00;

use strict;
use Tile;

sub new {
	my $class = shift;
	my @tiles;
	
	# create a new unscrambled(?) stock of 28
	foreach my $x (0..6) {
		foreach my $y (0..6) {
			push @tiles, Tile->new($x, $y) if $x <= $y;
		}
	}
	
	bless { '_tiles' => \@tiles }, $class;
}

sub shuffle {
	my $self = shift;
	my @st = @{$self->{'_tiles'}};
	my $s = scalar @st;
	for (0..$s) {
		my ($lo, $hi) = (int(rand($s)), int(rand($s)));
		($st[$lo], $st[$hi]) = ($st[$hi], $st[$lo]);
	}
	$self->{'_tiles'} = \@st;
}

sub size {
	my $self = shift;
	my $ret = scalar @{$self->{'_tiles'}};
	
	$ret;
}

sub given_top_tile {
	my $self = shift;
	my $ret = undef;
	if ($self->size() > 0) {
		$ret = shift @{$self->{'_tiles'}};
	}
	
	$ret;
}

sub display {
	my $self = shift;
	my $ret = "";
	foreach my $tile (@{$self->{'_tiles'}}) {
		$ret .= $tile->display . " ";
	}
	$ret .= "\n";
	$ret;
}