package MP3S::Music::Playlist;

use strict;
use Carp;

use MP3S::Misc::Logger qw(log_info log_debug log_error);
use MP3S::Music::PlaylistMaster;

sub new {
    my $class = shift;
    my %args  = @_;

    $args{'song_objects'} = MP3S::Music::PlaylistMaster->new(
        $args{'rootdir'} ? $args{'rootdir'} : $args{'playlist'} );

    $args{'gen_time'} = time();
    croak("No rootdir or playlist name was given") unless $args{'song_objects'};
    bless \%args, $class;
}

# NOTE: self->song_objects is the master list of songs, and
#       self->songs is the list filtered through a URI
#       The latter is also affected with each call of get_song

sub process_playlist {
    my $self = shift;
    my ($uri) = @_;

    my @songs = ();
    my $narrowing = ( defined $uri && $uri ne '/' );

	my $song_objects = $self->{'song_objects'};
    foreach my $song_obj ( @{ $song_objects->songs } ) {
        my $s = $song_obj->get_uni_filename;

        my $acceptsong = 1;
        chomp $s;

        # if URI is provided, the client has asked for a specific song/dir
        # narrow the list down in this case
        if ( $narrowing && index( $s, $uri ) == -1 ) {
            $acceptsong = 0;
        }

        if ($acceptsong) {

            #push @songs, $s;
            push @songs, $song_obj;
            log_debug("   Matching song: $s \n") if ($narrowing);
        }
    }

    my $all_ok = 1;
    if ( scalar @songs == 0 && $narrowing ) {    # stop poking about
        sleep 1;

        #$conn->send_error(RC_NOT_FOUND);
        log_info("Desired search $uri was not found - returning 404\n");
        $all_ok = 0;
    }
    @{ $self->{'songs'} } = @songs;

    $all_ok;
}

sub is_stale {
	my $self = shift;
	$self->{'song_objects'}->is_stale;
}

# just return 'playlist.m3u' for now
sub reckon_m3u_name {
    my $self = shift;
    "playlist.m3u";
}

# returns a list of song filenames from the master list - presently only used by internal taglist
sub all_songnames {
	my $self = shift;
	my @names = ();
	
	my $song_objects = $self->{'song_objects'};
	foreach my $song_obj (@{ $song_objects->songs }) {
		push @names, $song_obj->get_filename;
	}
	
	@names;
}


# NOTE! returns a list of the Song objects, not the song names!
sub list_of_songs {
    my $self = shift;
    croak
      "List of songs is empty (perhaps 'process_playlist' wasn't called yet?)"
      unless $self->{'songs'};
    @{ $self->{'songs'} };
}

sub list_of_songs_URIs {
    my $self = shift;
    my ($hyperlinked) = (@_);

    #my @ret = ();
    my $rootdir = $self->{'rootdir'};

    # CM and what if it's an ordinary playlist and no 'rootdir' was given?
    $rootdir = "/";

    sort map ( $_->get_URI( 'hyperlinked' => $hyperlinked ),
        @{ $self->{'songs'} } );

}

sub get_song {
    my $self     = shift;
    my ($random) = @_;
    my $ret      = undef;

    my $size = scalar @{ $self->{'songs'} };
    if ( $size > 0 ) {
        srand( time / $$ );
        my $indx = $random ? rand $size : 0;
        $ret = splice @{ $self->{'songs'} }, $indx, 1;
    }
    $ret;
}

sub generate_tag_info {
    my $self = shift;
    log_info("Generating tag info\n");

# This should ideally be generated only once, and after gen_playlist has been called
    use MP3S::Music::TagInfo;
    my $ti = new MP3S::Music::TagInfo( playlist => $self );
    $ti->generate_tags( progress_batchsize => 10 );    # TEST
    $ti->read_tags_from_db;
    $self->{'tag_info'} = $ti;
    log_info("Tag info generation done");
}

sub get_tag_info {
    my $self = shift;
    if ( !$self->{'tag_info'} ) {
        log_debug( $self . " -= No tag info yet, generating now" );
        $self->generate_tag_info;
    }
    $self->{'tag_info'};
}

sub get_trackinfo {
    my $self       = shift;
    my ($song_obj) = @_;
    my $tname      = undef;
    my $tsecs      = undef;
    my $tartist    = undef;

    my $ti = $self->get_tag_info;
    if ($ti) {
        $tname   = $ti->get_trackname($song_obj);
        $tsecs   = $ti->get_tracksecs($song_obj);
        $tartist = $ti->get_artist($song_obj);

        #if unable to find the artist/title, make song title up from filename
        if ( $tname =~ /Unknown Title/i ) {
            ($tname) = $song_obj->get_filename =~ m/\/([^\/]*)$/;
        }

    }
    ( $tname, $tsecs, $tartist );
}

1;
