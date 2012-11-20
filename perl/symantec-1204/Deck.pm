package Deck;
$VERSION = 1.00;
use Card;
use strict;

sub new
{
	my $class = shift;
	my ($jokers) = @_;
	# create a new unshuffled deck
	my @deck = ();
	my @pile = ();
	foreach my $suit (@{Card->SUITS}) {
		foreach my $rank (@{Card->RANKS}) {
			push @deck, Card->new($rank, $suit);
		}
	}
	
	bless {
		'_cards' => \@deck,
		'_discardpile' => \@pile,
		'_jokers' => \$jokers
	}, $class;
}

sub is_empty {
	my ($self) = shift;
	
	my $ret = 0;
	$ret = 1 if scalar @{$self->{'_cards'}} == 0;
}

sub discard_pile_empty {
	my ($self) = shift;
	my $ret = 0;
	
	$ret = 1 if scalar @{$self->{'_discardpile'}} == 0;
}

sub top_discard {
	my ($self) = shift;
	my $ret;
	if ($self->discard_pile_empty) {
		# do nothing
	} else {
		my $discard = $self->{'_discardpile'};
		$ret = $discard->[0];
	}
	
	$ret;
}

sub give_discard
{
	my ($self) = shift;
	my $ret = pop @{$self->{'_discardpile'}};
	
	$ret;
}
sub take_discard
{
	my ($self) = shift;
	my ($discarded) = @_;
	
	#print "Taking a discard of $discarded.";
	push @{$self->{'_discardpile'}}, $discarded;
}

# Draw a card from the top of the deck.
# ARGUMENTS: none
# RETURNS: the card (type Card) from the top of the deck.
sub draw_card
{
	my ($self) = shift;
	my $ret = shift @{$self->{'_cards'}};
	$ret;
}

# Shuffle the deck.
# ARGUMENTS: none
sub shuffle
{
	my ($self) = shift;
	my @deck = @{$self->{'_cards'}};
	
	my $s = scalar @deck;
	for (0..$s) {
		my ($lo, $hi) = (int(rand($s)), int(rand($s)));
		($deck[$lo], $deck[$hi]) = ($deck[$hi], $deck[$lo]);
	}
	$self->{'_cards'} = \@deck;
}

# Deal cards to players.
# ARGUMENTS:
#    num_cards_start - number of cards to deal to each player to start off
#    players         - a ref to a list of Hands (e.g. [$p1, $p2])
sub deal
{
	my ($self) = shift;
	my ($num_cards_start, $players) = @_;
	
	my @player_list = @$players;
	my $num_players = scalar @player_list;
	my $cards_to_deal = (scalar @player_list) * $num_cards_start;
	my $deck = $self->{'_cards'};
	
	if ($cards_to_deal > (scalar @$deck)) {
		$cards_to_deal = scalar @$deck;
	}
	
	my $ctr = 0;
	
	# Deal cards out, round-robin, to all the given players
	for (1..$cards_to_deal) {
		my $curr_player = $player_list[$ctr];
		$curr_player->add_card($self->draw_card());
		$ctr = ($ctr + 1) % $num_players;
	}
	
	# Then insert the jokers (if we're playing that sort of game)
	if ($self->{'_jokers'}) {
		my $s = scalar @$deck;
		my ($a, $b) = (int(rand($s)), int(rand($s)));

		splice @$deck, $a, 0, Card->new(Card->JOKER);
		splice @$deck, $b, 0, Card->new(Card->JOKER);
	}
}

# Returns a printout of the contents of the deck and the discard pile.
# ARGUMENTS: none
sub contents
{
	my ($self) = shift;
	my ($show_discard_only) = @_;
	
	my $ret = "";
	
	unless ($show_discard_only) {
		$ret .= "Deck: ";
		$ret .= cardlist ($self->{'_cards'});
		#print cardlist ($self->{'_cards'});
	}

	$ret .= "\nDiscard pile: ";
	$ret .= cardlist ($self->{'_discardpile'});
	#print cardlist ($self->{'_discardpile'});
	$ret;
}
#utility
sub cardlist {
	my ($cards) = @_;
	my $ret = "";
	if (scalar @{$cards}) {
		foreach my $card (@{$cards}) {
			$ret .= $card->descr() . " ";
		}
	} else {
		$ret = "(EMPTY)";
	}
	$ret;
}