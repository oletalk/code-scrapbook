#!/usr/bin/perl -w

use strict;
use Tile;
use Test::More tests => 4;

my $d1 = Tile->new(2, 3);
#my $d2 = Tile->new(100, 3);
is ( $d1->display , 'Tile: 2|3', 'expected # of pips 2,3' );

my $d2 = Tile->new(3, 6);
is ( $d2->display, 'Tile: 3|6', 'expected # of pips 3,6');

is ( $d2->points, 9, 'expected # of points for 3,6 domino is 9');

ok ($d1->matches($d2), "Above tiles match");