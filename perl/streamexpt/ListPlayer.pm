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
		
	my $all_ok = $plist->process_playlist($uri);
	
	if ($all_ok) {
		my $done = 0;
		#loop forever (or until the client closes the socket - see SongPlayer) 
		my $song;
		
		while (!$done && ($song = $plist->get_song($random))) {
			#print the HTTP header
			$conn->send_status_line(RC_OK);
			$conn->send_header(_stream_headers());
			$conn->send_crlf;
			
			my $songname = $song->get_filename;
			warn( "playing song: $songname\n") if $debug;
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

sub _stream_headers {
	('Content-Type' => 'audio/x-mp3stream',
	 'Cache-Control' => 'no-cache ',
	 'Pragma' => 'no-cache ',
	 'Connection' => 'close ',
	 'x-audiocast-name' => 'My MP3 Server')
	}

1;