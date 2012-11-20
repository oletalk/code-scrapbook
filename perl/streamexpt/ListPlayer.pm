package ListPlayer;

use strict;
use Carp;
use SongPlayer;

use HTTP::Status;

sub new {
	my $class = shift;
	bless { @_ }, $class;
}

sub play_songs {
	my $self = shift;
	my ($uri, $downsample) = @_;
		
	my $conn = $self->{'conn'};
	my $plist = $self->{'playlist'}; # is an actual Playlist object as of 20/11/2012
	my $random = $self->{'random'};
	my $debug = $self->{'debug'};
	croak ("Connection not set") unless $conn;
	
	# CM 20/11/2012 VVVVV copied from here
	
	my $all_ok = $plist->process_playlist($uri);

	# CM 20/11/2012 ^^^^^ copied up to here
	
	if ($all_ok) {
		my $done = 0;
		#loop forever (or until the client closes the socket - see SongPlayer) 
		my $song;
		
		while (!$done && ($song = $plist->get_song($random))) {
			#print the HTTP header
			print $conn $self->_httpheaders();

			warn( "playing song: $song\n") if $debug;
			my $player = SongPlayer->new(conn => $conn, 
										 downsample => $downsample, 
										 debug => $debug);
			$player->play($song);
		
			$done = 1 unless $conn;
			warn "Finishing after this song" if $done && $debug;
		}
	} else {
		$conn->send_error(RC_NOT_FOUND);
	}
	
	warn "Done playing songs";
}

sub _httpheaders {
	my $self = shift;
    my $ret = "HTTP/1.0 200 OK\n";
    $ret .= "Content-Type: audio/x-mp3stream\n";
    $ret .= "Cache-Control: no-cache \n";
    $ret .= "Pragma: no-cache \n";
    $ret .= "Connection: close \n";
    $ret .= "x-audiocast-name: My MP3 Server\n\n";
	$ret;
	}

1;