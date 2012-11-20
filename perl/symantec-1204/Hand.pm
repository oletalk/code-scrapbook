package Hand;
$VERSION = 1.00;
use Card;
use HashList;
use strict;

sub new
{
	my $class = shift;
	
	my @hand = ();
	my $want = HashList->new();
	my $keep = HashList->new();
	
	bless {
		'_cards' => \@hand,
		'_wanted' => $want,
		'_keep' => $keep
	}, $class;
}


########### INTERACTIONS WITH THE DECK #################
sub draw {
	my ($self) = shift;
	my ($deck) = @_;
	
	my $drawn_card = $deck->draw_card();
	if ($drawn_card->rank() ne Card->JOKER) {
		$self->add_card( $drawn_card );
	}
	$drawn_card;
}

sub take_discard {
	my $self = shift;
	my ($deck) = @_;
	my $ret = 1; # success if able to take a discard
	
	if ($deck->discard_pile_empty()) {
		$ret = 0;
	} else {
		$self->add_card( $deck->give_discard());
	}
	
	$ret;
}

sub decide_discard {
	my $self = shift;
	#my ($deck) = @_;
	my $ret;
	
	my @hand = @{$self->{'_cards'}};
	my $dropped = 0;
	
	my $ctr = 0;
	foreach my $card (@hand) {
		if (! $dropped) {
			if ($self->can_drop($card)) {
				#$self->discard($ctr, $deck);
				$ret = $ctr;
				$dropped = 1;
			}
		}
		$ctr++;
	}
	
	$ret;
}

sub discard {
	my $self = shift;
	my ($card_number, $deck) = @_;
	
	my @hand = @{$self->{'_cards'}};
	$deck->take_discard($hand[$card_number]);
	
	my $n = scalar @hand;
	@{$self->{'_cards'}} = ();
	for (0..$n-1) {
		push @{$self->{'_cards'}}, $hand[$_]
			unless $_ == $card_number;
	}
}

###### PATTERN CHECKERS #################
sub check_hand {
	my $self = shift;
	my ($DEBUG) = @_;
	my @cards = @{$self->{'_cards'}};
	my $ret = 0;
	my $prevcard;
	
	my $w = $self->{'_wanted'};
	my $k = $self->{'_keep'};
	
	$w->clear_list();
	$k->clear_list();
	my $handcount = 0;
	
	my %rankcounts = ();
	my %cards_counted = ();

	# (a) check for cards of same face value
	foreach my $rank (@{Card->RANKS}) {
		my @cwr = $self->all_cards_with_rank($rank);
		
		# if we have 2 or more cards of a rank, mark them as 'to keep'
		if (scalar @cwr > 1) {
			$w->add_to_list("$rank:");
			foreach (@cwr) {
				$k->add_to_list($_->descr());
			}
		}
		
		# if we have MORE than 2 cards of a rank, add them to the 'win' total
		# and mark them as used (for assessing whether we have a winning hand)
		if (scalar @cwr > 2) {
			$handcount += scalar @cwr;
			# mark the cards as used
			foreach (@cwr) {
				$cards_counted{$_->descr()} = 1;
			}
			print "  (DEBUG) Found " . scalar @cwr . " cards of rank $rank.\n" if $DEBUG;
		}
	}
	
	# (b) check for card sequences
	foreach my $suit (@{Card->SUITS}) {
		my @cws = sort { $a->combined_val() <=> $b->combined_val() } 
					$self->all_cards_in_suit($suit);
		
		my $prev_card;
		my $s_len = 1;
		my @seq = ();
		foreach my $r_card (@cws) {
			$w->add_to_list($r_card->next_lower_rank_spec());
			$w->add_to_list($r_card->next_higher_rank_spec());
			
			if (defined $prev_card &&
				$prev_card->next_higher_rank_spec() eq $r_card->descr()) {
					
			} else {
				# check the sequence length and count the cards off if > 2
				if (scalar @seq > 2) {
					foreach (@seq) {
						$cards_counted{$_} = 1;
					}
					$handcount += scalar @seq;
				}
				@seq = ();
			}
			
			unless ($cards_counted{$r_card->descr()}) {
				push @seq, $r_card->descr();
			}
			
			if ($DEBUG && scalar @seq > 2) {
				print "  (LOOP) " . $r_card->descr() . ". SEQ: ";
				print "$_ " foreach @seq;
				print "\n";
			}
		
			$prev_card = $r_card unless ($cards_counted{$r_card->descr()});
		}
		if (scalar @seq > 2) {
			foreach (@seq) {
				$cards_counted{$_} = 1;
			}
			$handcount += scalar @seq;
		}
		
		
	}

	#	my $c_rank = $card->rank();
	#	my @checkrank = $self->all_cards_with_rank($c_rank);
		

	foreach my $card (@cards) {
		$w->remove_from_list($card->descr());
	}
	# if there are 3 or 4 of a particular rank, we have a potential win
	#TODO
	if ($handcount == 7) {
		$self->{'_haswon'} = 1;
	}
	$ret = $handcount;
	$ret;
}

###### HELPER FUNCTIONS FOR ABOVE ########
sub all_cards_with_rank {
	my $self = shift;
	my ($rank) = @_;
	
	my @ret = ();
	
	foreach my $card (@{$self->{'_cards'}}) {
		push @ret, $card if ($card->rank() eq $rank);
	}
	@ret;
}

sub all_cards_in_suit {
	my $self = shift;
	my ($suit) = @_;
	
	my @ret = ();
	
	foreach my $card (@{$self->{'_cards'}}) {
		push @ret, $card if ($card->suit() eq $suit);
	}
	@ret;
}
sub card_index {
	my $self = shift;
	my ($cardspec) = @_;
	
	my $ctr = 0;
	my $found;
	foreach my $card (@{$self->{'_cards'}}) {
		$found = $ctr if $card->descr eq $cardspec;
		$ctr++;
	}
	
	$found;
}

###### BASIC OPERATIONS ##################
sub has_won {
	my $self = shift;
	$self->{'_haswon'};
}

sub can_drop {
	my $self = shift;
	my ($card) = @_;
	
	my $ret = 1;
	# check the 'keep' list to see if it's in there
	$ret = $ret - $self->{'_keep'}->matches_exact($card->descr());
	
	$ret;
}

sub display_want_list {
	my $self = shift;
	
	#foreach my $want (keys %{$self->{'_wanted'}}) {
	#	print "  -> $want \n" if $self->{'_wanted'}{$want} == 1;
	#}
	$self->{'_wanted'}->display_list();
}

sub wants {
	my $self = shift;
	my ($card) = @_;
	
	$self->{'_wanted'}->matches_start($card->descr());
}

# Add the given Card to the Hand.
# ARGUMENTS: the card to add (type Card)
sub add_card {
	my $self = shift;
	my ($card) = @_;
	
	push @{$self->{'_cards'}}, $card;
}

# Returns a printout of the contents of the hand.
# ARGUMENTS: none
sub contents {
	my $self = shift;
	
	my $ret = "";
	
	my @hand = @{$self->{'_cards'}};
	my @hand_sorted = sort { $a->combined_val() <=> $b->combined_val() } @hand;
	
	foreach my $card (@hand_sorted) {
		$ret .= $card->descr() . " ";
	}
	$ret;
}