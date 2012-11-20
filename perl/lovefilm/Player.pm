package Player;
$VERSION = 1.00;

use strict;
use Tile;

sub new {
	my $class = shift;
	my @hand = ();
	
	bless { '_hand' => \@hand }, $class;
}

sub draw_tile {
	my $self = shift;
	my ($stock) = @_;
	push @{$self->{'_hand'}}, $stock->given_top_tile();
}

sub display {
	my $self = shift;
	my $ret = "Hand: ";
	foreach my $tile (@{$self->{'_hand'}}) {
		$ret .= $tile->display . " ";
	}
	$ret;
}