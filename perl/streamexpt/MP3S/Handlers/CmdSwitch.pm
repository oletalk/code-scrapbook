package MP3S::Handlers::CmdSwitch;

use strict;
use Carp;

use MP3S::Handlers::ListPlayer;
use MP3S::Net::TextResponse;
use MP3S::Misc::Logger qw(log_debug log_info);

use HTTP::Status;
use HTTP::Request::Params;
use Email::MIME;
use URI::Escape;

# the body of the child process that handles a request goes here.
sub handle {
	my (%args) = @_;
	
	my $conn = $args{connection};
	my $plist = $args{playlist};
	my $random = $args{random};
	my $downsample = $args{downsample};
	
	croak "No playlist provided" unless $plist;
	croak "No connection given" unless $conn;
	
	my $req = $conn->get_request;
	my $uri = $req->uri;
	my $headerhost = $req->header('host'); # HTTP::Headers (host) 
	$uri = uri_unescape($uri);
	log_debug( "Request: $uri\n" );
	log_debug( "Host   : $headerhost\n" );
	
	# First bit is the command, /list/ or /play/
	my ($command, $str_uri) = $uri =~ m/^\/([\w.]+)(.*)$/;
	#call the main child routine
	if (!defined $command) {
		$conn->send_error(RC_BAD_REQUEST);
		$conn->close();
	}
	elsif ($command eq 'play') {
		my $lp = MP3S::Handlers::ListPlayer->new(conn => $conn, 
								 playlist => $plist,
								 random => $random);
		$lp->play_songs($str_uri, $downsample);				
	} elsif ($command eq 'list') {
		$conn->send_response( MP3S::Net::TextResponse::print_list($plist, $str_uri));
	} elsif ($command eq 'list.m3u') {
		$conn->send_response( MP3S::Net::TextResponse::print_list($plist, $str_uri, 'templates/song-list-m3u.tmpl'));
	} elsif ($command eq 'stored') {
        # 26/7 TODO: now test this with (a) existing playlist, (b) nonexistent playlist
        my $response = MP3S::Net::TextResponse::get_stored_playlist($plist, $str_uri, $headerhost);
		$conn->send_response( $response );
	} elsif ($command eq 'drop' || $command eq 'drop.m3u') {
		$conn->send_response( MP3S::Net::TextResponse::print_playlist($plist, $str_uri, $headerhost));
	} elsif ($command eq 'stats') {
		$conn->send_response( MP3S::Net::TextResponse::print_stats($str_uri));
	} elsif ($command eq 'latest') {
		$conn->send_response( MP3S::Net::TextResponse::print_latest($plist, $str_uri) );
	} else {
		$conn->send_error(RC_BAD_REQUEST);
		$conn->close();
	}

	log_info( "Processing request complete.\n" );
}

1;
