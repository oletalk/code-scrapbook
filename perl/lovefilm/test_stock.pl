#!/usr/bin/perl -w

use strict;
use Stock;
use Test::More tests => 3;

my $st = Stock->new();
$st->shuffle;

is ( $st->size(), 28, '28 tiles in all');
#print "Size of stock is " . $st->size() . "\n";
print "Drawing a tile.\n";
my $t = $st->given_top_tile();

ok ( defined($t), 'Successfully drew tile from nonempty stock');

print "\nDrawn tile is: " . $t->display();
print "\nRemaining tiles:";
#print $st->display();
is ( $st->size(), 27, 'Drawn tile leaves size at 27');

