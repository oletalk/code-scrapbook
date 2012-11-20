#!/usr/bin/perl

use Test::More tests => 5;
use strict;
use Level;
use Tank;
use DiverFish;
use Constants;
use ClockworkFish;
use Snail;

my $t = Tank->new();

for(1..4) {
	$t->add( DiverFish->new, 'BOTTOM' );
}
is ( $t->levelAt('BOTTOM')->population, 4, 'added 4 diverfish, population should reflect this');
is ( $t->levelAt('MIDDLE')->depth, Constants::DEPTH_MIDDLE, 'middle depth is correct according to Constants');
for(1..7) {
	$t->add( ClockworkFish->new, 'BOTTOM' );
}
ok( $t->levelAt('BOTTOM')->is_crowded, '+7 clockwork fish, level should now be crowded');
ok( $t->levelAt('BOTTOM')->randomCreature->isa('Fish'), 'randomCreature call works and returns a fish' );
$t->pass_time();
isnt( $t->levelAt('BOTTOM')->population, 11, 'tank->pass_time propagated through to levels, suffocated some fish' );
