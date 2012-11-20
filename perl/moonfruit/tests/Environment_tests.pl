#!/usr/bin/perl

use Test::More tests => 2;
use Environment;
use strict;

my $e = Environment->new();

$e->add_event('woke up');
$e->add_event('brushed my teeth');
$e->add_event('washed my face');

my @x = $e->consume_events;
is ( scalar @x, 3 , 'added events returned');
my @y = $e->consume_events;
is ( scalar @y, 0 , 'no more events left after first call');

