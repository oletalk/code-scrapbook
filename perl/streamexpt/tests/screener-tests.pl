use lib '..';
use tests::TestingInit;

use strict;
use Test::More tests => 7;

BEGIN { use_ok( 'MP3S::Net::Screener' ) }

TestingInit::init;

my $cl = MP3S::Net::Screener->new( ipfile => "tests/testdata/clients1.txt");


my ( $action, @screener_options ) = @{$cl->screen("10.80.40.100")};
is( $action, 'DENY', 'Denied peer as per config file');
( $action, @screener_options ) = @{$cl->screen("10.90.40.100")};
is( $action, 'ALLOW', 'Allowed peer as per default action');

$cl->set_default_action( 'BLOCK' );


( $action, @screener_options ) = @{$cl->screen("212.159.62.233")};
is( $action, 'ALLOW', 'Allowed peer as per config file');
( $action, @screener_options ) = @{$cl->screen("10.80.40.100")};
is( $action, 'DENY', 'Denied peer as per config file');
( $action, @screener_options ) = @{$cl->screen("80.77.120.241")};
is( $action, 'BLOCK', 'Blocked peer as per default');
( $action, @screener_options ) = @{$cl->screen("0.0.0.0")};
is( $action, 'BLOCK', 'Blocked bogus ip address as per hardcoded default');
