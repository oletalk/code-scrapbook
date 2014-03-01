use Test::More tests => 6;

use strict;
use lib '..';
use Cwd;
use Harness;
use Data::Dumper;

use vars qw( $activities_file $TS_FORMAT );

my $h = new Harness( activities_file => '/tmp/activities0.txt', timestamp_format => '%T' );

my $config_file = 'testdata/config1.cfg';


$h->do_overrides( $config_file );

# NB hash keys for log items are cmd/task/timestamp
$h->do_log ( 'start', 'footask', [ '10:00' ] );
my $log = $h->log_contents;
is(scalar @{$log}, 1, "Log item for starting of task added");
is($log->[0]->{timestamp}, '10:00', 'Task stamped with correct start time');
$h->do_log ( 'stop', 'footask', [ '10:30' ] );
$log = $h->log_contents;
is(scalar @{$log}, 2, "Log item for stopping of task added");
is($log->[1]->{timestamp}, '10:30', 'Task stamped with correct stop time');

$h->do_log ( 'start', 'bartask', [ '11:00' ] );
# inspect current state of list too
my $struc = $h->internal_structure();
is($struc->{closed_tasks}->{footask}, 1800, 'Task duration calculated correctly');
is(scalar keys $struc->{open_tasks}, 1, 'Open task in internal hash');
sub checktime {
	#$localtime[2] = $hh;
	#$localtime[1] = $mm;
	
}