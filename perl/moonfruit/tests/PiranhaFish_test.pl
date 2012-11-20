#!/usr/bin/perl

use Test::More tests => 5;
use Tank;
use SunFish;
use PiranhaFish;
use strict;

my $t = Tank->new();
$t->add( SunFish->new(), 'TOP' );
$t->add( PiranhaFish->new(), 'TOP' );

is( scalar $t->levelAt('TOP')->population, 2, 'population should now be 2');

for (0..10) { $t->pass_time(1) }
is( scalar $t->levelAt('TOP')->population, 1, 'piranha should have eaten sunfish by now' );
is( scalar $t->levelAt('SURFACE')->population, 0, "surface still empty - eaten fish don't float to the top" );
$t->change_temp(11);
$t->pass_time(1);
is( scalar $t->levelAt('TOP')->population, 0, 'should be too cold for piranha to live now');
my @pop = $t->levelAt('SURFACE')->population;
my $cr = pop @pop;
ok( !$cr->isAlive , 'dead piranha at the surface level');
