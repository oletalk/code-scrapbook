#!/usr/bin/perl -w
# NOTE: original IO::Socket-based code is from 2000 - http://www.perlmonks.org/?node_id=8650

use strict;
use HTTP::Daemon;

use MP3S::Server;
use MP3S::Misc::MSConf qw(config_value);
use MP3S::Misc::Logger qw(log_info log_debug log_error);

use Getopt::Long;
use sigtrap qw(die INT QUIT);

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

# then override with command line args
my $res = GetOptions(
    "playlist=s"    => \$playlist,
    "rootdir=s"     => \$rootdir,
    "downsample"    => \$downsample,
    "port=i"        => \$port,
    "clientlist=s"  => \$clientlist_file,
    "random"        => \$random,
    "config_file=s" => \$config_file,
    "debug"         => \$debug
);

die "Another copy of mp3server is already running - check pidfile"
  if $pidfile->running();
$pidfile->write();

die "Either playlist or rootdir must be specified"
  unless ( defined $playlist or defined $rootdir );

# get config first
MP3S::Misc::MSConf::init($config_file);

my $llevel = $debug ? MP3S::Misc::Logger::DEBUG : MP3S::Misc::Logger::INFO;
MP3S::Misc::Logger::init(
    level           => $llevel,
    logfile         => config_value('logfile'),
    display_context => MP3S::Misc::Logger::NAME
);

$port ||= config_value('port') || 8000;
$clientlist_file ||= config_value('clientlist');

#ignore child processes to prevent zombies
$SIG{CHLD} = 'IGNORE';
$SIG{INT}  = \&cleanup;
$SIG{QUIT} = \&cleanup;

# let's listen
my $d = HTTP::Daemon->new(
    ReuseAddr => 1,
    LocalPort => $port
) || die "OH NOES! Couldn't create a new daemon: $!";

my $server = MP3S::Server->new(
    ipfile     => $clientlist_file,
    playlist   => $playlist,
    rootdir    => $rootdir,
    downsample => $downsample,
    random     => $random
);
$server->setup_playlist;

log_info( "Server is up at " . $d->url . ". Waiting for connections ... \n" );

#wait for the connections at the accept call
while (1) {
    while ( my $conn = $d->accept ) {
        $server->process( $conn, $port );
    }

    log_error(
"For some reason HTTP::Daemon accept returned a false value!  Looping back after 20 s"
    );
    sleep(20);
}

exit(0);

sub cleanup {
    warn "SIGINT caught... shutting down";
    $pidfile->remove();
    exit(0);
}
