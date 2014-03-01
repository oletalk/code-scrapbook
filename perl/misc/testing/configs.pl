use Test::More tests => 2;

use strict;
use lib '..';
use Cwd;
use Harness;

my $h = new Harness( activities_file => '/tmp/activities0.txt', timestamp_format => '%T' );

my $config_file = 'testdata/config1.cfg';
$h->do_overrides( $config_file );

is ($h->activities_file, '/tmp/activities0.txt', 'Activities file correctly overridden from config');
is ($h->timestamp_format, '%T', 'Timestamp format correctly overridden from config');