#!/usr/bin/perl

use Test::More tests => 7;
use strict;
use Tank;
use Snail;
use PiranhaFish;

my $t = Tank->new();
my $x = Tank->new();
ok ( $x == $t, "there is only one tank" );
is ( $t->env->get_temperature, 20, 'default temperature is 20 C' );

$t->change_temp(12);
is( $t->env->get_temperature, 12, 'temperature change successful' );

ok ( $t->add( Snail->new(), 'BOTTOM') , 'no problems adding a snail');
ok ( $t->add_food(10) , 'no problems adding food');
ok ( $t->add( PiranhaFish->new(), 'MIDDLE' , 'no problems adding a piranha'));
ok ( $t->pass_time(1), 'no problems passing time quietly');
