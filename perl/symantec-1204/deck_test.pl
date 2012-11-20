#!/opt/local/bin/perl

use Hand;
use Deck;

use strict;

my $d = Deck->new();

my $h1 = Hand->new();
my $h2 = Hand->new();

$d->shuffle();
$d->deal(7, [ $h1, $h2]);

show_all($d, [ $h1, $h2 ]);

if ($d->discard_pile_empty()) {
	print "The discard pile is empty.\n";
}

print "Player 1 draws a card from the deck.\n";
$h1->draw($d);

print "Player 1 discards the 3rd card.\n";	
$h1->discard(2, $d);

print "Showing:\n";
show_all($d, [ $h1, $h2 ]);

print "Top discard is " . $d->top_discard()->descr();

print "\n\nPlayer 2 takes up the discard.\n";
$h2->take_discard($d);

print "Player 2 discards the 4th card.\n";
$h2->discard(3, $d);

show_all($d, [$ h1, $h2 ]);

print "\n\n\n";
foreach (@{Card->RANKS}) { print "$_ \n"};
exit(0);

##############################################
# SUBROUTINES
sub show_all {
	my ($deck, $hand_list) = @_;
	
	print $d->contents();
	print "\n\nHands:";
	
	my $ctr = 0;
	foreach my $hand (@$hand_list) {
		$ctr++;
		print "HAND $ctr : " . $hand->contents() . "\n";
	}

}