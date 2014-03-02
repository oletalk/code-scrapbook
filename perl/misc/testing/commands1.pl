use Test::More tests => 14;

use strict;
use lib '..';
use Cwd;
use Harness;
use Data::Dumper;

$TaskDisplay::quiet = 1;
$TaskDispatchList::quiet = 1;

my $h = new Harness( activities_file => '/tmp/activities0.txt', timestamp_format => '%T' );

my $config_file = 'testdata/config1.cfg';


$h->do_overrides( $config_file );

# NB hash keys for log items are cmd/task/timestamp
is ($h->do_log ( 'start', 'footask' ), 1, 'Start new task ok' );
is ($h->do_log ( 'start', 'footask' ), 0, 'Start another task with same name NOT ok' );
is ($h->get_error_message, "An open task by the name 'footask' already exists!\n", 'Correct error message from the previous operation');
sleep 1;
is ($h->do_log ( 'stop', 'footask' ), 1, 'Close existing task ok' );
is ($h->do_log ( 'start', 'footask' ), 1, 'Start new task with same name as closed task ok' );
is ($h->do_log ( 'stop', 'bartask' ), 0, 'Close non-existent task NOT ok');
is ($h->do_log ( 'reopen', '1' ), 0, 'No tasks currently available to reopen');
is ($h->do_log ( 'stop', 'footask' ), 1, 'Close existing task ok');
sleep 1;
is ($h->do_log ( 'reopen', '1', [ '09:00' ]), 1, 'First task ok to reopen');

is ($h->do_log ( 'start', '1'), 0, 'Numeric task names not allowed');
is ($h->do_log ( 'stop', 'junk'), 0, 'Nonexistent task cannot be closed');
is ($h->get_error_message, "No open task identified by 'junk' exists!\n", 'Correct error message from the previous operation');
is ($h->do_log ( 'stop', 'footask', [ '08:00' ]), 0, 'Close time cannot be before open time');
is ($h->get_error_message, "Given close time is before task 'footask' begin time of 09:00:00!\n", 'Correct error message from the previous operation');
#is ($h->do_log ( 'start', 'baztask', [ 'XX:XX' ]), 0, 'Invalid start time given');