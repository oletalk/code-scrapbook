use lib '..';
use strict;
use Test::More tests => 5;

use HTTP::Daemon;

use MP3S::Misc::MSConf qw(config_value);
use MP3S::Server;
use tests::TestingInit;
use tests::TestUtils;

BEGIN { use_ok( 'MP3S::Server') }

TestingInit::init;
#$SIG{CHLD} = 'IGNORE';

my $port = config_value('port');
my $d = HTTP::Daemon->new(
	ReuseAddr => 1,
	LocalPort => $port,
	Timeout => 5 ) || die "Unable to bring up a server on port $port for the test - $!";
	
my $server = MP3S::Server->new(	rootdir => 'tests/testdata');
$server->setup_playlist;
sleep 1;

my $pid;
die "Can't fork: $!" unless defined ($pid = fork() );
if ($pid == 0) {
	my $conns = 3;
	while ($conns > 0) {
		my $conn = $d->accept;
		$server->process( $conn, $port );
		$conns--;
	}
	
	exit 0;
}

my $local = TestUtils::getlocal($port, '/list');
my @links = TestUtils::getlinks($local);
is($links[1], '/drop', 'link for playlist download present');
is($links[4], '/play/third.mp3', 'links for mp3s present');

$local = TestUtils::getlocal($port, '/drop');
ok( TestUtils::compare_result($local, 'tests/results/server-tests-playlist.txt'), 'generated playlist as expected');

$local = TestUtils::getlocal($port, '/stats');
ok( TestUtils::compare_result($local, 'tests/results/server-tests-stats.txt'), 'stats URL does something');

print $local;