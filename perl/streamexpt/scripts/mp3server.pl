#!/usr/bin/perl -w
# NOTE: original IO::Socket-based code is from 2000 - http://www.perlmonks.org/?node_id=8650

use strict;
use HTTP::Daemon;

use MP3S::Server;
use MP3S::Misc::MSConf qw(config_value);
use MP3S::Misc::Logger qw(log_info log_debug log_error);

use Getopt::Long;
#use sigtrap qw(die INT QUIT USR1); # 10/03/2013 FIXME - don't think you need to use $SIG{INT} etc. etc.
use sigtrap 'handler' => \&dispatch, 'normal-signals';

# note: patched File::Pid - see https://rt.cpan.org/Public/Bug/Display.html?id=18960
use File::Pid;

#get the port to bind to or default to 8000
my $port;

our $pidfile = File::Pid->new( { file => '/tmp/mp3server.pid' } );
our $debug;
our $playlist;
our $rootdir;
our $downsample;
our $random;

our $config_file = "default.conf";

my $clientlist_file;
my $reuse_stats;

# then override with command line args
my $res = GetOptions(
    "playlist=s"    => \$playlist,
    "rootdir=s"     => \$rootdir,
    "downsample"    => \$downsample,
    "port=i"        => \$port,
    "clientlist=s"  => \$clientlist_file,
    "random"        => \$random,
    "config_file=s" => \$config_file,
	"reusestats"    => \$reuse_stats,
    "debug"         => \$debug
);

die "Another copy of mp3server is already running - check pidfile"
  if $pidfile->running();
$pidfile->write();

die "Either playlist or rootdir must be specified"
  unless ( defined $playlist or defined $rootdir );

# get config first
MP3S::Misc::MSConf::init($config_file);

MP3S::Misc::Logger::init(
    level => $debug ? MP3S::Misc::Logger::DEBUG : MP3S::Misc::Logger::INFO,
    logfile         => config_value('logfile'),
    display_context => MP3S::Misc::Logger::NAME
);

$reuse_stats ||= config_value('reusestats');
$port ||= config_value('port') || 8000;
$clientlist_file ||= config_value('clientlist');

#ignore child processes to prevent zombies
$SIG{CHLD} = 'IGNORE';


# let's listen
my $d = HTTP::Daemon->new(
    ReuseAddr => 1,
    LocalPort => $port
) || die "OH NOES! Couldn't create a new daemon: $!";

our $server = MP3S::Server->new(
    ipfile     => $clientlist_file,
    playlist   => $playlist,
    rootdir    => $rootdir,
    downsample => $downsample,
    random     => $random,
	reuse_stats => $reuse_stats
);
$server->setup_playlist;

log_info( "Server is up at " . $d->url . ". Waiting for connections ... \n" );

#wait for the connections at the accept call
while (1) {
	#local $SIG{HUP} = \&dispatch;
    while ( my $conn = $d->accept ) {
        $server->process( $conn, $port );
    }

	# CM for some reason it seems to fall through to here when I give it a SIGHUP
    log_error(
"For some reason HTTP::Daemon accept returned a false value!  Looping back after 20 s"
    );
	
	#$server->reload(ipfile => 1);

    sleep(20);
}

exit(0);

sub dispatch {
	my $sig = shift;
	return unless $sig;
	if ($sig =~ /^INT|TERM$/) { #quit gracefully
		warn "SIG$sig caught... shutting down";
		$pidfile->remove();
		exit(0);
	} elsif ($sig =~ /^HUP$/) {
		$server->reload(ipfile => 1);
	} else {
		# IGNORE the signal
	}
}
