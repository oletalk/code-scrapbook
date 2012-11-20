#!/opt/local/bin/perl

# game modules/classes/etc

# This program has Task 2:
#   Accepts arguments for the number of rummy players n (2>= n >= 4)
#   They will be dealt 7 cards each to start.

use strict;
use Getopt::Long;
use Card;
use Deck;
use Hand;

# Program defaults
my $debug;     # NO debugging
my $num_players = 0; # number of players MUST be specified
my $jokers;    # NO jokers (if yes, 2 jokers added to pack)

# Get arguments
my $result = GetOptions("players=i" => \$num_players,
						"withjokers" => \$jokers,
						"debug"     => \$debug);
						
die "Number of players ( -players ) must be between 2 and 4"
	unless ( $num_players >= 2 && $num_players <= 4);

# Create list of players
my @players = ();
my @wait_turns = ();
for (1..$num_players) {
	push @players, Hand->new();
}

# Create new deck
my $d = Deck->new($jokers);
$d->shuffle();

print "Dealing out cards to the players.\n" if $debug;

# DEAL CARDS
$d->deal(7, \@players);
if ($debug) {
	print "\n Each player now has a hand:\n";
	my $ctr = 0;
	foreach my $hand (@players) {
		$ctr++;
		print "Hand $ctr contains: " . $hand->contents() . "\n";
	}
}

# BEGIN PLAY
my $turn = 0;
my $playing = 1;
# continue play

while ($playing) {
	my $current_player = $players[$turn];
	
	if ($wait_turns[$turn] == 0) {
		# check discard pile - if we want what's there, take it
		my $top = $d->top_discard();
		$current_player->check_hand();
		if ($top && $current_player->wants($top)) {
			print "Player $turn takes the discard " . $top->long_descr() . "\n";
			$current_player->take_discard($d);
		} else {
			# draw
			my $c = $current_player->draw($d);
			print "Player $turn drew a " . $c->long_descr() . " from the deck.\n";
			if ($c->rank() eq Card->JOKER) {
				print "  ... Player $turn has just lost 2 turns!\n";
				$wait_turns[$turn] = 2;
			}
		}
	
		if ($wait_turns[$turn] == 0){
			# decide
			my $hc = $current_player->check_hand(1);
	
			# discard
			my $cardnum = $current_player->decide_discard();
			$current_player->discard($cardnum, $d);
			print "Player $turn has discarded card #" . ($cardnum+1) .".\n";
	
			print "Player $turn has completed their turn. Their hand ($hc): " . $current_player->contents() . "\n\n";
	
		}
	
		print "The Deck looks like: " . $d->contents(1) . "\n";
		if ($d->is_empty()) {
			print " *** The deck is now empty! \n\n";
			$playing = 0;
		}
	} else {
		print "Player $turn misses this turn.\n\n";
		$wait_turns[$turn]--;
	}
	if ($current_player->has_won()) {
		print " *** Player $turn has won the game! \n\n";
		$playing = 0;
	} else {
		sleep(5);
		$turn = ($turn + 1) % $num_players;
	}
	

}

=head1 NAME

playrummy.pl - Play a simple rummy game (all-computer players)

=head1 SYNOPSIS

	perl playrummy.pl [ -withjokers ] -players 2|3|4

=head1 DESCRIPTION

This module plays a simple rummy game between 2-4 computer players,
displaying current progress, including 
  (a) whether the player draws a card from the deck or picks the
      top card from the discard pile,
  (b) the contents of the PLAYER'S HAND, including the number of 
      cards forming valid melds (e.g. 4 Aces plus 2-3-4 of Clubs
      gives 7, and a winning hand)
  (c) the contents of the DISCARD PILE.

There is a pause of 5 seconds between turns.

If -withjokers is specified, then after players' cards are dealt, 
two Jokers are randomly inserted into the deck.  A player drawing 
a Joker will immediately discard the Joker and lose 2 turns.

Play halts when either the player has a winning hand, or the deck 
runs out of cards.

=head1 AUTHOR

Colin Maughan (c_maughan@yahoo.com)

=cut