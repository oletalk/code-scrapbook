#!/usr/bin/perl -w

use strict;
use Player;
use Stock;

my $p = Player->new();
my $st = Stock->new();
$st->shuffle;
print "Stock is now" . $st->display . "\n";

$p->draw_tile($st);

print "Player has drawn a tile:";
print $p->display() . "\n";

print "\nRemainder of stock is now: ";
print $st->display();
