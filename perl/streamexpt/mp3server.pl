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
use MP3S::DB::Setup;
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

# get config first
MP3S::Misc::MSConf::init($config_file);

my $llevel = $debug ? MP3S::Misc::Logger::DEBUG : MP3S::Misc::Logger::INFO;
MP3S::Misc::Logger::init(
    level           => $llevel,
    display_context => MP3S::Misc::Logger::NAME
);

$port ||= config_value('port') || 8000;
$downsample      ||= config_value('downsample');
$clientlist_file ||= config_value('clientlist');

# either playlist or root dir must be specified
die "Either playlist or rootdir must be specified"
  unless ( defined $playlist or defined $rootdir );

$rootdir = "${rootdir}/" unless $rootdir =~ /\/$/;

my $plist =
  MP3S::Music::Playlist->new( playlist => $playlist, rootdir => $rootdir )
  ;    # rootdir overrides playlist
# get the tags in now
$plist->generate_tag_info();


my $gen_time = time;

# if rootdir, how often will it check for new files?
# regenplaylist option in config file TODO
my $regen = config_value('regenplaylist');
if ( $regen > 0 ) {
    if ( defined $rootdir ) {
        log_info("Playlist will regenerate every $regen minutes.");
    }
    else {
        $regen = 0;
        log_error(
            "Ignoring 'regenplaylist' since a fixed playlist was provided.");
    }
}

# initialise database/stats
MP3S::DB::Setup::init();

#ignore child processes to prevent zombies
$SIG{CHLD} = 'IGNORE';

# let's listen
my $d = HTTP::Daemon->new(
    ReuseAddr => 1,
    LocalPort => $port
) || die "OH NOES! Couldn't create a new daemon: $!";

log_info("Downsampling is ON.\n") if $downsample;
log_info( "Server is up at " . $d->url . ". Waiting for connections ... \n" );

my $cl = MP3S::Net::Screener->new( ipfile => $clientlist_file );
if ( config_value('screenerdefault') ) {
    $cl->set_default_action( config_value('screenerdefault') );
}

#wait for the connections at the accept call

while ( my $conn = $d->accept ) {
    my $child;

    # who connected?
    my $peer = $conn->peerhost;
    my $action_ref = $cl->screen($peer);
	my ($action, @screener_options) = @$action_ref;
	log_info("Got options @screener_options") if scalar @screener_options;

    if ( $action eq MP3S::Net::Screener::ALLOW ) {

		my $downsample_client = $downsample;
		
		foreach my $screener_opt (@screener_options) {
			# override global downsampling on a per-client basis
			#obviously if you include them both the last one wins!
			if ($screener_opt eq MP3S::Net::Screener::NO_DOWNSAMPLE) {
				$downsample_client = 0;
			}
			if ($screener_opt eq MP3S::Net::Screener::DOWNSAMPLE) {
				$downsample_client = 1;
			}
		}
        # perform the fork or exit
        die "Can't fork: $!" unless defined( $child = fork() );
        if ( $child == 0 ) {
            eval {
                MP3S::Handlers::CmdSwitch::handle(
                    connection => $conn,
                    playlist   => $plist,
                    random     => $random,
                    downsample => $downsample_client,
                    port       => $port,
                );
            };
            if ($@) {

                #$had_errors = 1;
                log_error("Problems handling request: $@");
            }

            #if the child returns, then just exit;
            exit 0;
        }
        else {
          #close the connection, the parent has already passed it off to a child
            $conn->close();
        }
    }
    elsif ( $action eq MP3S::Net::Screener::DENY ) {
        $conn->send_error(RC_FORBIDDEN);
        $conn->close();
    }
    else {    # BLOCK
        $conn->close();
    }

    # check if we were asked to regenerate the playlist
    if ( defined $rootdir && $regen > 0 ) {
        my $elapsed = time - $gen_time;
        if ( $elapsed > ( $regen * 60 ) ) {
			my $newcount = $plist->is_stale();
			if ($newcount) {
				log_info("Re-generating playlist from rootdir $rootdir");
	            
	            $plist = MP3S::Music::Playlist->new(
	                playlist => $playlist,
	                rootdir  => $rootdir,
					gen_reason => "$newcount new songs found",
	            );    # rootdir overrides playlist
				$plist->generate_tag_info();

			} else {
				log_info("Re-gen time passed but no new files encountered");
			}
			$gen_time = time;				
            
        }
    }

    #go back and listen for the next connection
}
exit(0);
