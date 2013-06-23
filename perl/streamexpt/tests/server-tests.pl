use lib '..';
use strict;
use Test::More tests => 11;

use warnings;
use HTTP::Daemon;

use MP3S::Misc::MSConf qw(config_value);
use MP3S::Server;
use tests::TestingInit;
use tests::TestUtils;

# end-to-end testing: this tests Server.pm, TextResponse.pm, SongPlayer.pm
# through common scenarios

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
	my $conns = 8;
	while ($conns > 0) {
		my $conn = $d->accept;
		$server->process( $conn, $port );
		$conns--;
	}
	
	exit 0;
}

my $local = TestUtils::getlocal($port, '/list');
my @links = TestUtils::getlinks($local);
@links = sort @links;  # CM FIXME - find order is very brittle here
#print " ---> $_ \n" foreach @links;

is($links[0], '/drop', 'link for playlist download present');
is($links[5], '/play/third.mp3', 'links for mp3s present');
is($links[3], '/play/nonasc/weird\\303\\212\\305\\267stuff.mp3', 'files with strange characters in names ok');

$local = TestUtils::getlocal($port, '/drop');
ok( TestUtils::compare_result($local, 'tests/results/server-tests-playlist.dat'), 'generated playlist as expected');

$local = TestUtils::getlocal($port, '/bogus');
is($local, undef, "bogus request returns no usable data");  # well, a 400 but LWP::Simple can't get at that

$local = TestUtils::getlocal($port, '/play/abcdefg.mp3');
is($local, undef, "bogus play request returns no usable data"); # a 404

$local = TestUtils::getlocal($port, "/sdlfkjsflksjdfldsjfljkfdlsjfklsjflsjfalkjsflksjfklsjfdslkjslkjsklfjslfkjslfsjlksdjskdlfjsdklfjsdlkfjlfkjweofjewiofjeiofjewoifjfeiof/fe/fejfjfsfs/fjesfsfse/f/sefse/fsefsje/fsefosjf3f32rf02j302jr20r203j3r20jr32jr302jwej\x02sdflkdsfkssdlfkjsflksjdfldsjfljkfdlsjfklsjflsjfalkjsflksjfklsjfdslkjslkjsklfjslfkjslfsjlksdjskdlfjsdklfjsdlkfjlfkjweofjewiofjeiofjewoifjfeiof/fe/fejfjfsfs/fjesfsfse/f/sefse/fsefsje/fsefosjf3f32rf02j302jr20r203j3r20jr32jr302jwej\x02sdflkdsfkssdlfkjsflksjdfldsjfljkfdlsjfklsjflsjfalkjsflksjfklsjfdslkjslkjsklfjslfkjslfsjlksdjskdlfjsdklfjsdlkfjlfkjweofjewiofjeiofjewoifjfeiof/fe/fejfjfsfs/fjesfsfse/f/sefse/fsefsje/fsefosjf3f32rf02j302jr20r203j3r20jr32jr302jwej\x02sdflkdsfkssdlfkjsflksjdfldsjfljkfdlsjfklsjflsjfalkjsflksjfklsjfdslkjslkjsklfjslfkjslfsjlksdjskdlfjsdklfjsdlkfjlfkjweofjewiofjeiofjewoifjfeiof/fe/fejfjfsfs/fjesfsfse/f/sefse/fsefsje/fsefosjf3f32rf02j302jr20r203j3r20jr32jr302jwej\x02sdflkdsfkssdlfkjsflksjdfldsjfljkfdlsjfklsjflsjfalkjsflksjfklsjfdslkjslkjsklfjslfkjslfsjlksdjskdlfjsdklfjsdlkfjlfkjweofjewiofjeiofjewoifjfeiof/fe/fejfjfsfs/fjesfsfse/f/sefse/fsefsje/fsefosjf3f32rf02j302jr20r203j3r20jr32jr302jwej\x02sdflkdsfks");
is($local, undef, "looooong bogus URI in request returns no usable data"); # a 404

$local = TestUtils::getlocal($port, '/stats');
ok( TestUtils::compare_result($local, 'tests/results/server-tests-stats.dat'), 'stats URL does something');

$local = TestUtils::getlocal($port, '/latest/1');
ok( $local =~ /New songs over the past 1 day/ || $local eq 'No new songs.', '/latest url does something');
$local = TestUtils::getlocal($port, '/play/first.mp3');
is($local, "not an mp3\n", "'playing' an mp3 non-downsampled works ok"); #as it turns out :-D
