#!/usr/bin/perl

use Tank;
use DiverFish;
use Snail;
use SunFish;
use PiranhaFish;

use strict;

# Create a tank
my $t = Tank->new();
$t->add_food(50);

# Add some fish and a snail
for (0..5) {
	$t->add( DiverFish->new(), 'BOTTOM');
}
$t->add( Snail->new(), 'BOTTOM');
$t->add( SunFish->new(), 'TOP');
$t->add( PiranhaFish->new(), 'MIDDLE');

# Pass enough time to see the fish die (not enough for the snail to die)
for (0..25) {
	$t->pass_time();
}
print "Turning the temp down to 12 C\n";
$t->change_temp(12);
for (0..10) {
	$t->pass_time();
}
