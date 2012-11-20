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
	my $playlist = $self->{'playlist'};
	my $random = $self->{'random'};
	my $debug = $self->{'debug'};
	croak ("Connection not set") unless $conn;
	croak ("Playlist not given") unless $playlist;
	croak ("Playlist not readable") unless -r $playlist;
	
	# CM 20/11/2012 VVVVV copied from here
	
	#get all the possible songs
	open my $f_pls, $playlist or die "Unable to open playlist $playlist: $!";
	my @songs = ();
	
	my $narrowing = (defined $uri && $uri ne '/');
	
	while (<$f_pls>) {
		my $s = $_;
		my $acceptsong = 1;
		chomp $s;
		
		# if URI is provided, the client has asked for a specific song/dir
		# narrow the list down in this case
		if ($narrowing && index($s, $uri) == -1) {
			$acceptsong = 0;
		}
			#warn "INDEX IS " . index($s, $uri) . "\n";
		
		
		if ($acceptsong) {
			push @songs, $s;
			print "   Matching song: $s \n" if $narrowing;			
		}
	}
	close $f_pls;
	
	my $threw_error = 0;
	if (scalar @songs == 0 && $narrowing) { # stop poking about
		sleep 1;
		$conn->send_error(RC_NOT_FOUND);
		warn "Desired search $uri was not found - returning 404\n";
		$threw_error = 1;
	}
	# CM 20/11/2012 ^^^^^ copied up to here
	
	unless ($threw_error) {
		my $done = 0;
		#loop forever (or until the client closes the socket) 
		#seed the random number generator
		srand(time / $$);
	
		my $ctr = 0;
		while (!$done) {
			#print the HTTP header
			print $conn $self->_httpheaders();
			# get a random song
			my $song = $random ? $songs[ rand @songs ] : $songs[$ctr];
			warn( "playing song: $song\n") if $debug;
			my $player = SongPlayer->new(conn => $conn, 
										 downsample => $downsample, 
										 debug => $debug);
			$player->play($song);
		
			$done = 1 unless $conn;
			$ctr++;
			if ($ctr >= scalar @songs) {
				$done = 1;
			}
			warn "Finishing after this song" if $done && $debug;
		}
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