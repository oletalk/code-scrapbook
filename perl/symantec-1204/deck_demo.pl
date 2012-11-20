#!/opt/local/bin/perl

# game modules/classes/etc

# This program has Task 1:
#   It creates a new Deck and shuffles it.
#   Then it deals 7 cards each to two players (their Hands).
#   Finally, it prints out the contents of the hands and the deck.
#   Note: the deck's discard pile is printed out each time (but is not used as Task 2 was not completed).

use strict;
use Card;
use Deck;
use Hand;

my $d = Deck->new();
$d->shuffle();

print "This new deck contains: ";
print $d->contents();
print "\n";


my $h1 = Hand->new();
my $h2 = Hand->new();
print "Dealing 7 cards out to two hands.\n";
$d->deal(7, [ $h1, $h2 ]);
print "\n Each hand now contains:";
print "Hand 1: " . $h1->contents() . "\n";
print "Hand 2: " . $h2->contents() . "\n";


print "The deck is now       : ";
print $d->contents();
print "\n";