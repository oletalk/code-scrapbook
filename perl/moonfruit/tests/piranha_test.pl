#!/usr/bin/perl

use Tank;
use DiverFish;
use Snail;
use SunFish;
use PiranhaFish;

use strict;

# Create a tank
my $t = Tank->new();
$t->add_food(30);

# Add some fish and a snail
for (0..5) {
	$t->add( DiverFish->new(), 'BOTTOM');
}
$t->add( Snail->new(), 'BOTTOM');
$t->add( SunFish->new(), 'TOP');
$t->add( PiranhaFish->new(), 'BOTTOM');

for (0..25) {
	$t->pass_time();
}
