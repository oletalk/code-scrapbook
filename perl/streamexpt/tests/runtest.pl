#!/usr/bin/perl -w

use strict;
use MP3S::Misc::MSConf qw(config_value);

MP3S::Misc::MSConf::init('tests/testdata/testing.conf');

my $opt_i = grep(/^-i/, @ARGV);
my ($testcount, $successes) = (0,0);

my $starttime = time;

if ($opt_i) {
	use MP3S::DB::Setup;
	print "Initialising test database.";
	MP3S::DB::Setup::init();
	exit 0;
} else {
	foreach my $ARG (@ARGV) {
		if (-r "tests/$ARG") {
			print "Running test $ARG.\n";
			system ("/usr/bin/perl -w tests/$ARG") == 0 and $successes++;
			$testcount++;
		} else {
			warn "Skipping nonexistent test $ARG\n";
		}
	}
}

my $elapsed = time - $starttime;
print "=================\nTEST RUN COMPLETE - $successes / $testcount passed, in $elapsed second(s).\n";