#!/usr/bin/perl

use Test::More tests => 3;
use Tank;
use SunFish;
use strict;

my $t = Tank->new();
$t->add( SunFish->new(), 'TOP' );

is( scalar $t->levelAt('TOP')->population, 1, 'adding sunfish should increase population by 1');
$t->add( SunFish->new(), 'BOTTOM' );

is( scalar $t->levelAt('BOTTOM')->population, 0, 'adding sunfish to bottom should fail');

for (0..40) { $t->pass_time(1) }
is( scalar $t->levelAt('TOP')->population, 0, 'fish should have died after passing 40 units of time');
