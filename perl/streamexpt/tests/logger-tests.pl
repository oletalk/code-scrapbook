use lib '..';
use tests::TestUtils;
use strict;

use Test::More tests => 8;

BEGIN { use_ok( 'MP3S::Misc::Logger', qw(log_info log_debug log_error)) }

use MP3S::Misc::MSConf;
use MP3S::Misc::Logger;

my $logfile = 'tests/logtests.log'; # same as in tests/testdata/log4perl*.conf

MP3S::Misc::MSConf::init('tests/testdata/testing.conf');
system ("rm -f $logfile");
MP3S::Misc::Logger::init(logconf => 'tests/testdata/log4perl.conf');

log_info('logged one line');
ok( TestUtils::logfile_result($logfile) =~ 'logged one line', 'logged one line');
log_debug('logged a debug line');
ok( TestUtils::logfile_result($logfile) !~ 'logged a debug line', 'did not log debug line');
log_error('logged an error!');
ok( TestUtils::logfile_result($logfile) =~ 'logged an error', 'logged an error');

MP3S::Misc::Logger::init(logfile => $logfile, level => 'WARN');
log_info('info line 2');
ok( TestUtils::logfile_result($logfile) !~ 'info line 2', 'did not log info line at new WARNING threshold');
log_error('error 2');
ok( TestUtils::logfile_result($logfile) =~ 'error 2', 'logged another error still');

MP3S::Misc::Logger::init(logconf => 'tests/testdata/log4perl-DEBUG.conf');
my $loglines_before = scalar split /\n/, TestUtils::logfile_result($logfile);
log_debug("log line is spread\nout over several\nlines");
my $log_final = TestUtils::logfile_result($logfile);
my $loglines_after = scalar split /\n/, $log_final;
is( $loglines_before + 3, $loglines_after, 'log over several lines ok');
$log_final =~ s|\d\d/\d\d/\d\d\d\d \d\d:\d\d:\d\d|__/__/____ __:__:__|g;
ok( TestUtils::compare_result($log_final, 'tests/results/logger-tests.dat'), 'log file written out ok');