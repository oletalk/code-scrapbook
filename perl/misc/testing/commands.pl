use Test::More tests => 2;

use strict;
use lib '..';
use Cwd;
use Harness;

use vars qw( $activities_file $TS_FORMAT );

my $h = new Harness( activities_file => '/tmp/activities0.txt', timestampformat => '%T' );

my $config_file = 'testdata/config1.cfg';


$h->do_overrides( $config_file );


$h->do_log ( 'start', 'footask', [ '10:00' ] );
$h->do_log ( 'stop', 'footask', [ '10:30' ] );




sub checktime {
	#$localtime[2] = $hh;
	#$localtime[1] = $mm;
	
}