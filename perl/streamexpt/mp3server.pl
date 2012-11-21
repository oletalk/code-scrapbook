#!/usr/bin/perl -w
# NOTE: original IO::Socket-based code is from 2000 - http://www.perlmonks.org/?node_id=8650

use strict;
use HTTP::Daemon;
use HTTP::Status;
use Data::Dumper;
use URI::Escape;

use ListPlayer;
use Playlist;
use Screener;
use TextResponse;

use Getopt::Long;
use sigtrap qw(die INT QUIT);

#get the port to bind to or default to 8000
my $port = 8000;

our $debug;
our $playlist;
our $rootdir;
our $downsample;
our $random;

our %delete_list;
our $parent_quit = 1;

my $clientlist_file;

my $res = GetOptions("playlist=s" => \$playlist,
					 "rootdir=s"  => \$rootdir,
					 "downsample"  => \$downsample,
					 "port=i"     => \$port,
					 "clientlist=s" => \$clientlist_file,
					 "random"     => \$random,
					 "debug"      => \$debug);



# either playlist or root dir must be specified
die "Either playlist or rootdir must be specified" 
	unless (defined $playlist or defined $rootdir);
my $plist = Playlist->new(playlist => $playlist, rootdir => $rootdir); # rootdir overrides playlist

#ignore child processes to prevent zombies
$SIG{CHLD} = 'IGNORE';

# let's listen
my $d = HTTP::Daemon->new(  LocalPort => $port ) || die "OH NOES! Couldn't create a new daemon: $!";
										
warn "Server ready. Waiting for connections ... \n";

my $cl = Screener->new(ipfile => $clientlist_file);

#wait for the connections at the accept call

while (my $conn = $d->accept) {
	my $child;
	
	# who connected?
	my $peer = $conn->peerhost;
	warn "Connection received ... ", $peer, "\n";
	my $action = $cl->screen($peer);
	print "Action for this peer is $action \n";
	
	if ($action eq Screener::ALLOW) {
		# perform the fork or exit
		die "Can't fork: $!" unless defined ($child = fork());
		if ($child == 0) {
		
			my $uri = $conn->get_request->uri; 
			$uri = uri_unescape($uri);
			print "Request: $uri\n" if $debug;
			
			# First bit is the command, /list/ or /play/
			my ($command, $str_uri) = $uri =~ m/^\/(\w+)(.*)$/;
			#call the main child routine
			if ($command eq 'play') {
				my $lp = ListPlayer->new(conn => $conn, 
										 playlist => $plist,
										 random => $random,
										 debug => $debug);
				$lp->play_songs($str_uri, $downsample);				
			} elsif ($command eq 'list') {
				if ($plist->process_playlist($str_uri)) {
					my @lst = $plist->list_of_songs;
					$conn->send_basic_header;
					$conn->send_response( TextResponse::print_list(@lst) );
					$conn->close();
				} else {
					$conn->send_error(RC_NOT_FOUND);
					$conn->close();
				}
			} else {
				$conn->send_error(RC_BAD_REQUEST);
				$conn->close();
			}
		
			$plist->setchild(1); # explain...
			#if the child returns, then just exit;
			$parent_quit = 0;
			exit 0;
		} else {
			#close the connection, the parent has already passed it off to a child
			$conn->close();
		}
	} elsif ($action eq Screener::DENY) {
		$conn->send_error(RC_FORBIDDEN);
		$conn->close();
	} else { # BLOCK
		$conn->close();
	}
	#go back and listen for the next connection
}
exit(0);


#sub add_delete_list {
#	my ($dsfilename) = @_;
#	$delete_list{$dsfilename} = $dsfilename;
#}

END {
	if ($parent_quit) {
		warn "Wrapping up...\n";
		print Dumper(\%delete_list) if $debug;
	
		foreach my $del (keys %delete_list) {
			my $delfile = $delete_list{$del};
			print "Deleting temp file $delfile \n";
			system("rm '$delfile'") or warn "Problems removing tempfile: $!";
		}
		print "Deleting all our temp files!\n";
		system("rm -f /tmp/*.mxx");
	} else {
		warn "Child process ended.";
	}
	
}