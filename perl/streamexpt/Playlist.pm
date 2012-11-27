package Playlist;

use strict;
use Carp;
use Song;
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
			#push @songs, $s;
			my $sn = Song->new(filename => $s);
			$sn->set_URI_from_rootdir( $self->{'rootdir'} );
			push @songs, $sn;
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

# NOTE! returns a list of the Song objects, not the song names!
sub list_of_songs {
	my $self = shift;
	@{$self->{'songs'}};
}

sub list_of_songs_URIs {
	my $self = shift;
	my ($hyperlinked) = (@_);
	#my @ret = ();
	my $rootdir = $self->{'rootdir'};
	
	# CM and what if it's an ordinary playlist and no 'rootdir' was given?
	$rootdir = "/";

	map ($_->get_URI('hyperlinked' => $hyperlinked),  @{$self->{'songs'}});

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

sub generate_tag_info {
	my $self = shift;
	warn "Generating tag info";
	# This should ideally be generated only once, and after gen_playlist has been called
	use TagInfo;
	my $ti = new TagInfo(playlist => $self);
	$ti->generate_tags(progress_batchsize => 10, to_file => './blah.txt'); # TEST
	$self->{'tag_info'} = $ti;
	warn "Tag info generation done";
}
	
sub get_tag_info {
	my $self = shift;
	if (!$self->{'tag_info'}) {
		$self->generate_tag_info;
	}
	$self->{'tag_info'};
}

sub get_trackinfo {
	my $self = shift;
	my ($song_obj) = @_;
	my $tname = undef;
	my $tsecs = undef;
	
	my $ti = $self->get_tag_info;
	if ($ti) {
		$tname = $ti->get_trackname($song_obj);
		$tsecs = $ti->get_tracksecs($song_obj);
		
		#if unable to find the artist/title, make song title up from filename
		if ($tname =~ /Unknown Title/i) {
			($tname) = $song_obj->get_filename =~ m/\/([^\/]*)$/;			
		}
		
	}
	($tname, $tsecs);
}

# non class sub
sub gen_playlist {
	my ($rootdir, $debug) = @_;
	
	my ($fh, $plsname) = tempfile( SUFFIX => '.plx', UNLINK => 0 );
	warn "Generating playlist for given root dir $rootdir\n";
	
	open ($fh, ">$plsname") or die "Unable to open temp playlist $plsname for writing: $!";
	#add_delete_list($plsname);
	
	my @mp3s = File::Find::Rule->file()->name( qr/\.(mp3|ogg)$/i )->in( $rootdir );
	foreach my $song (@mp3s) {
		chomp $song;
		# strange ._Something.mp3 files in there
		next if $song =~ /\/\.[^\/]*$/;
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