package Playlist; # DON'T USE AS YET

use strict;
use Carp;
use File::Find::Rule;
use File::Temp qw/ tempfile /;

sub new {
	my $class = shift;
	my %args = @_;
	
	if ($args{'rootdir'}) {
		$args{'temp_playlist'} = gen_playlist($args{'rootdir'}, $args{'debug'});
		$args{'playlist'} = $args{'temp_playlist'};
	}
	croak ("No rootdir or playlist name was given") unless $args{'playlist'};
	bless \%args, $class;
}

sub get_rootdir {
	my $self = shift;
	$self->{'rootdir'};
}

sub process_playlist {
	my $self = shift;
	my ($uri) = @_;
	
	my $playlist = $self->{'playlist'};
	croak "no playlist provided" unless $playlist;
		
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
	
	my $all_ok = 1;
	if (scalar @songs == 0 && $narrowing) { # stop poking about
		sleep 1;
		#$conn->send_error(RC_NOT_FOUND);
		warn "Desired search $uri was not found - returning 404\n";
		$all_ok = 0;
	}
	@{$self->{'songs'}} = @songs;
	
	$all_ok;
}

sub reckon_m3u_name {
	my $self = shift;
	
	my $plsname = $self->{'rootdir'};
	$plsname = $self->{'playlist'} unless $self->{'temp_playlist'};
	($plsname) = $plsname =~ m/([^\/]*)$/;
	$plsname ||= "playlist";
	$plsname = "${plsname}.m3u" unless ($plsname =~ /\.m3u$/i);
	
	$plsname;
}

sub list_of_songs {
	my $self = shift;
	@{$self->{'songs'}};
}

sub list_of_songs_URIs {
	my $self = shift;
	my ($hyperlinked) = (@_);
	my @ret = ();
	my $rootdir = $self->{'rootdir'};
	foreach my $songpath (@{$self->{'songs'}}) {
		my $songuri = $songpath;
		$songuri =~ s/$rootdir//;
		my $line = $hyperlinked ? qq |<a href="/play/${songuri}">${songuri}</a><br/> \n|
		                        : qq |/play/${songuri}|;
		push @ret, $line;
	}
	
	@ret;
}

sub get_song {
	my $self = shift;
	my ($random) = @_;
	my $ret = undef;
	
	my $size = scalar @{$self->{'songs'}};
	if ($size > 0) {
		srand(time / $$);
		my $indx = $random ? rand $size : 0;
		$ret = splice @{$self->{'songs'}}, $indx, 1;		
	}
	
	$ret;
}

sub rm_temp_playlist {
	my $self = shift;
	if (defined $self->{'temp_playlist'}) {
		my $plsname = $self->{'temp_playlist'};
		warn "Removing temp playlist!";
		system("rm -f $plsname");
	}
}

# non class subs
sub gen_playlist {
	my ($rootdir, $debug) = @_;
	
	my ($fh, $plsname) = tempfile( SUFFIX => '.plx', UNLINK => 0 );
	warn "Generating playlist for given root dir $rootdir\n";
	
	open ($fh, ">$plsname") or die "Unable to open temp playlist $plsname for writing: $!";
	#add_delete_list($plsname);
	
	my @mp3s = File::Find::Rule->file()->name( qr/\.(mp3|ogg)$/i )->in( $rootdir );
	foreach my $song (@mp3s) {
		chomp $song;
		print "  Adding '$song' to temp playlist $plsname\n" if $debug;
		$fh->print( "$song\n");
	}
	close $fh;
	
	return $plsname;
}

sub setchild {
	my $self = shift;
	my ($is_child) = @_;
	
	$self->{'is_child'} = $is_child;
}

sub DESTROY {
	my $self = shift;
	$self->rm_temp_playlist unless $self->{'is_child'};
}

1;