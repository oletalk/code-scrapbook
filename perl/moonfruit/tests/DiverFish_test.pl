#!/usr/bin/perl

use Test::More tests => 3;
use Tank;
use DiverFish;
use SunFish;
use strict;

my $t = Tank->new();
$t->add( DiverFish->new(), 'TOP' );
$t->add( SunFish->new(), 'TOP' );

my @pop = $t->levelAt('TOP')->population;
my $c = $pop[0];
ok( $c->isa('SunFish'), '1st creature on top level should be a sunfish - wrong level for diverfish');
$t->add( DiverFish->new(), 'BOTTOM' );

is( scalar $t->levelAt('BOTTOM')->population, 1, 'correct level so diverfish should be added');

for (0..40) { $t->pass_time(1) }
is( scalar $t->levelAt('TOP')->population, 0, 'fish should have died after passing 40 units of time');
