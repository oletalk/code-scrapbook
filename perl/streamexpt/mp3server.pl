#!/usr/bin/perl -w
# NOTE: original IO::Socket-based code is from 2000 - http://www.perlmonks.org/?node_id=8650

use strict;
use HTTP::Daemon;
use HTTP::Status;
use Data::Dumper;

use MP3S::Handlers::ListPlayer;
use MP3S::Handlers::CmdSwitch;
use MP3S::Music::Playlist;
use MP3S::Net::Screener;
use MP3S::Net::TextResponse;
use MP3S::Misc::MSConf qw(config_value);
use MP3S::Misc::Logger qw(log_info log_debug log_error);

use Getopt::Long;
use sigtrap qw(die INT QUIT);

#get the port to bind to or default to 8000
my $port;

our $debug;
our $playlist;
our $rootdir;
our $downsample;
our $random;

our $config_file = "default.conf";

my $clientlist_file;

# then override with command line args
my $res = GetOptions("playlist=s" => \$playlist,
					 "rootdir=s"  => \$rootdir,
					 "downsample"  => \$downsample,
					 "port=i"     => \$port,
					 "clientlist=s" => \$clientlist_file,
					 "random"     => \$random,
					 "config_file=s" => \$config_file,
					 "debug"      => \$debug);

# get config first
MP3S::Misc::MSConf::init($config_file);
MP3S::Misc::Logger::init(debug => $debug);

$port            ||= config_value('port') || 8000;
$downsample      ||= config_value('downsample');
$clientlist_file ||= config_value('clientlist');

# either playlist or root dir must be specified
die "Either playlist or rootdir must be specified" 
	unless (defined $playlist or defined $rootdir);
my $plist = MP3S::Music::Playlist->new(playlist => $playlist, rootdir => $rootdir); # rootdir overrides playlist

#ignore child processes to prevent zombies
$SIG{CHLD} = 'IGNORE';

# let's listen
my $d = HTTP::Daemon->new(  LocalPort => $port ) || die "OH NOES! Couldn't create a new daemon: $!";
							
log_info( "Downsampling is ON.\n" ) if $downsample;			
log_info( "Server is up at " . $d->url . ". Waiting for connections ... \n");

my $cl = MP3S::Net::Screener->new(ipfile => $clientlist_file);
if (config_value('screenerdefault')) {
	$cl->set_default_action(config_value('screenerdefault'));	
}

#wait for the connections at the accept call

while (my $conn = $d->accept) {
	my $child;
	
	# who connected?
	my $peer = $conn->peerhost;
	log_info( "Connection received ... ", $peer, "\n" );
	my $action = $cl->screen($peer);
	log_info( "Action for this peer is $action \n");
	
	if ($action eq MP3S::Net::Screener::ALLOW) {
		# perform the fork or exit
		die "Can't fork: $!" unless defined ($child = fork());
		if ($child == 0) {
			eval {
				MP3S::Handlers::CmdSwitch::handle(
					connection => $conn,
					playlist => $plist,
					random => $random,
					downsample => $downsample,
					port => $port,
				)
			};
			if ($@) {
				#$had_errors = 1;
				log_error("Problems handling request: $@");				
			}
			#if the child returns, then just exit;
			exit 0;
		} else {
			#close the connection, the parent has already passed it off to a child
			$conn->close();
		}
	} elsif ($action eq MP3S::Net::Screener::DENY) {
		$conn->send_error(RC_FORBIDDEN);
		$conn->close();
	} else { # BLOCK
		$conn->close();
	}
	#go back and listen for the next connection
}
exit(0);



#END {
#	if ($parent_quit) {
#		log_info( "Wrapping up...\n" );
#	} else {
#		log_info( "Child process ended.\n" );
#	}
#}