package Card;
$VERSION = 1.00;
use strict;
use Carp;

use constant {
	CLUBS => 'Clubs',
	SPADES => 'Spades',
	HEARTS => 'Hearts',
	DIAMONDS => 'Diamonds', 
	JOKER    => '*Joker*',
	
	SUITS => ['Clubs', 'Spades', 'Hearts', 'Diamonds'],
	RANKS => ['Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King']
};


sub new
{
	my $class = shift;
	my ($rank, $suit) = @_;
	
	# valid suit/rank?
	if ($rank ne Card->JOKER) {
		croak "Invalid suit '$suit'" unless grep { $_ eq $suit } @{Card->SUITS};
		croak "Invalid rank '$rank'" unless grep { $_ eq $rank } @{Card->RANKS};
	}
	bless { '_suit'	=> $suit,
			'_rank'	=> $rank
			}, $class;
	
}

sub next_higher_rank_spec {
	my $self = shift;
	my $r = $self->find_rank() + 1;
	my $ret;
	my @ranks = @{Card->RANKS};
	if ($r < scalar @ranks) {
		$ret = a_shortrank($ranks[$r]) . ":" . $self->shortsuit();
	}
	
	$ret;
}

sub next_lower_rank_spec {
	my $self = shift;
	my $r = $self->find_rank() - 1;
	my $ret;
	my @ranks = @{Card->RANKS};
	
	if ($r >= 0) {
		$ret = a_shortrank($ranks[$r]) . ":" . $self->shortsuit();
	}
	$ret;
}

sub find_rank {
	my $self = shift;
	my $r = $self->rank();
	
	my $ctr = 0;
	my $found;
	foreach (@{Card->RANKS}) {
		$found = $ctr if ($_ eq $r);
		$ctr++;
	}
	$found;
}

# Compares this card with another - if the same suit, returns 0
sub compare_suit {
	my $self = shift;
	my ($other_card) = @_;

	$other_card->suit_val() - $self->suit_val();
}

# Compares this card's rank with the other card and gives the numerical difference.
#   E.g., 8 of clubs vs Jack of hearts will give 3.
sub compare_rank {
	my $self = shift;
	my ($other_card) = @_;
	
	$other_card->rank_val() - $self->rank_val();
}

sub combined_val {
	my $self = shift;
	
	$self->suit_val() * 50 + $self->rank_val();
}

sub suit_val {
	my $self = shift;
	my $ctr = 0;
	my $ret = -1;
	
	foreach my $suit (@{Card->SUITS}) {
		$ctr++;
		$ret = $ctr if $self->suit() eq $suit;
	}
	
	$ret;
}

sub rank_val {
	my $self = shift;
	my $ctr = 0;
	my $ret = -1;
	
	foreach my $rank (@{Card->RANKS}) {
		$ctr++;
		$ret = $ctr if $self->rank() eq $rank;
	}
	
	$ret;
}

sub suit {
	my ($self) = @_;
	$self->{'_suit'};
}

sub rank {
	my ($self) = @_;
	$self->{'_rank'};	
}

sub shortrank
{
	my $self = shift;
	my $rank = $self->rank();
	a_shortrank($rank);
}

sub a_shortrank
{
	my $rank = shift;
	($rank eq '10') ? $rank : 
	($rank eq 'JOKER') ? ':-)' :
	substr($rank, 0, 1);
}

sub shortsuit
{
	my $self = shift;
	my $suit = $self->suit();
	substr($suit, 0, 1);
}

# Returns a very short description of the card (e.g. 8C for 8 of Clubs)
# ARGUMENTS: none
sub descr
{
	my ($self) = @_;
	$self->shortrank() . ":" . $self->shortsuit();
}

# Returns the regular description of the card (e.g. 10 of Hearts)
# ARGUMENTS: none
sub long_descr
{
	my ($self) = @_;
	$self->rank() . " of " . $self->suit();
}
