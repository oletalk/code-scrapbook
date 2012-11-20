#!/usr/bin/perl

use strict;
use Tank;
use Constants;
use ClockworkFish;
use DiverFish;
use PiranhaFish;
use Snail;
use SunFish;

use Switch;

my $t = Tank->new();
my $done = 0;

while (!$done) {
	print "Fish Tank Simulator v1.0 \n";
	print "   Please select an option: \n";
	print "   1. Add food\n";
	print "   2. Change the temperature\n";
	print "   3. Add a creature \n";
	print "   4. Nothing/pass\n";
	print "   5. QUIT\n";
	my $choice = get_choice(1, 5);
	switch ($choice) {
		case 1		{ $t->add_food( add_food() ); }
		case 2      { 
						my $temp = change_temp();
						$t->change_temp($temp) if $temp;
					}
		case 3      {
						my ($ctre, $lvl) = add_creature();
						$t->add($ctre, $lvl) if ($ctre && $lvl);
					}
		case 5		{ $done = 1; }
		else 		{  # do nothing
					}
	}
	
	$t->pass_time();
}

print "SIMULATION ENDED\n";

exit(0);

# ---------- Code for each choice below

sub add_food {
	print "  Please enter the amount to add, in units (1-10), 0 to cancel: ";
	my $units = get_choice(0,10);

	$units;
}

sub change_temp {
	print "  Please enter the new temperature, in Celsius, for the tank (10-30), 0 to cancel: ";
	my $temp = get_choice(0,30);
	undef $temp if $temp < 10;
	$temp;
}

sub add_creature {
	my ($ret, $level);
	print "-(1/2)- Add a creature: \n";
	print "  1. Snail\n";
	print "  2. Clockwork Fish\n";
	print "  3. Diver Fish\n";
	print "  4. Piranha Fish\n";
	print "  5. Sun Fish\n";
	print "  6. Cancel/back to main menu\n";
	my $crt = get_choice(1, 6);
	switch ($crt) {
		case 1		{ $ret = Snail->new() }
		case 2		{ $ret = ClockworkFish->new() }
		case 3		{ $ret = DiverFish->new() }
		case 4		{ $ret = PiranhaFish->new() }
		case 5		{ $ret = SunFish->new() }
	}
	
	print "-(2/2)- Select a level: \n";
	print "  1. Top \n";
	print "  2. Middle \n";
	print "  3. Bottom \n";
	print "  4. Cancel/back to main menu\n";
	my $lvl = get_choice(1,4);

	my @levels = (undef, 'TOP', 'MIDDLE', 'BOTTOM', undef);
	$level = $levels[$lvl];
	($ret, $level);
}

sub get_choice {
	my ($low, $high) = @_;
	my $done = 0;
	my $choice;
	while (!$done) {
		$choice = <STDIN>;
		chomp $choice;
		if ($choice < $low || $choice > $high) {
			print "Not a valid choice (should be between $low and $high).  Please try again.\n";
		} else {
			$done = 1;
		}
	}
	$choice;
}