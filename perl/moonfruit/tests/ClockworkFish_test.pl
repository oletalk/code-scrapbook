#!/usr/bin/perl

use Test::More tests => 5;
use Tank;
use ClockworkFish;
use DiverFish;

my $t = Tank->new();
$t->add( ClockworkFish->new(), 'TOP' );
$t->add_food(30);
for (0..10) {
	$t->add( ClockworkFish->new(), 'BOTTOM' );
}
$t->pass_time(1);
$t->pass_time(1);
ok( $t->levelAt('BOTTOM')->is_crowded, 'level is crowded with clockwork fish' );
is( $t->levelAt('BOTTOM')->population, 11, "but no clockwork fish have suffocated since they don't breathe" );
is( $t->env->get_foodamount, 30, 'none of the clockwork fish ate anything' );

$t->add( DiverFish->new(), 'BOTTOM' );
for (0..4) {
	$t->pass_time(1);
}
ok( $t->levelAt('BOTTOM')->is_crowded, 'level is crowded with clockwork fish' );
my @pop = $t->levelAt('SURFACE')->population;
my $c = pop @pop;
ok( !$c->isAlive, 'the diver fish suffocated and floated to the surface' );
