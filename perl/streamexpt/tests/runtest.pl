#!/usr/local/bin/perl -w

use strict;
use MP3S::Misc::MSConf qw(config_value);
our $PERL = '/usr/bin/env perl';

MP3S::Misc::MSConf::init('tests/testdata/testing-withdb.conf');
my $opt_i = grep(/^-i/, @ARGV);
my ($testcount, $successes) = (0,0);
my $TESTDIR = 'tests';

my $starttime = time;
my %failed_tests = ();

if ($opt_i) {
	use MP3S::DB::Setup;
	print "Initialising test database.";
	MP3S::DB::Setup::init();
	exit 0;
} else {
	my @tests = @ARGV;
	if (scalar @tests == 0) {
		# run all the tests!
		print " ** Running all tests within the 'tests' directory.\n";
		@tests = glob( "$TESTDIR/*-tests.pl" );
	}
	foreach my $test (@tests) {
		if (!-r $test && -r "$TESTDIR/$test") { #given without testdir prefix, that's ok
			$test = "$TESTDIR/$test";
		}
		if (-r $test) {
			print "<< Running test $test. >>\n";
			(system ("$PERL -w $test") == 0) ? ($successes++) : ($failed_tests{$test} = 1);
			$testcount++;
		} else {
			warn "Skipping nonexistent test $test\n";
		}
	}
}

my $elapsed = time - $starttime;
print "=================\nTEST RUN COMPLETE - $successes / $testcount passed, in $elapsed second(s).\n";
if ($successes == $testcount) {
	print "Well done!\n";
} else {
	print "Failed tests: ";
	print "$_ \n" foreach sort keys %failed_tests;
}
