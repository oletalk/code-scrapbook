package MP3S::Music::Playlist;

use strict;
use Carp;

use MP3S::Misc::MSConf qw(config_value);
use MP3S::Misc::Logger qw(log_info log_debug log_error);
use MP3S::Music::PlaylistMaster;
use MP3S::Misc::Util;

sub new {
    my $class = shift;
    my %args  = @_;

    $args{'song_objects'} = MP3S::Music::PlaylistMaster->new(
        $args{'rootdir'} ? $args{'rootdir'} : $args{'playlist'} );

    $args{'gen_time'} = time();
    croak("No rootdir or playlist name was given") unless $args{'song_objects'};
    bless \%args, $class;
}

sub gen_date {
	my $self = shift;
	my $format = config_value("datetimeformat") || "%d-%m-%Y,%H:%M:%S";
	log_info( "Date format is $format ");
	MP3S::Misc::Util::format_datetime($format, $self->{'gen_time'});
}

sub gen_reason {
	my $self = shift;
	$self->{'gen_reason'} || 'No particular reason';
}

# NOTE: self->song_objects is the master list of songs, and
#       self->songs is the list filtered through a URI
#       The latter is also affected with each call of get_song

sub process_playlist {
    my $self = shift;
    my ($uri) = @_;

    my @songs = ();
    my $narrowing = ( defined $uri && $uri ne '/' );

    my $is_hash = 0;

    # we could be given a file hash so should locate a song by that if given
    if ($defined $uri && $uri ne '') {
        if ($uri =~ /^[A-Za-z0-9]+$/) {
            $is_hash = 1;
        }
    }
	my $song_objects = $self->{'song_objects'};
    foreach my $song_obj ( @{ $song_objects->songs } ) {
        my $s = $song_obj->get_uni_filename;
        $s = $song_obj->get_hash if $is_hash;

        my $acceptsong = 1;
        chomp $s;

        # if URI is provided, the client has asked for a specific song/dir
        # narrow the list down in this case
        if ( $narrowing && index( $s, $uri ) == -1 ) {
            $acceptsong = 0;
        }

        if ($acceptsong) {
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

sub reckon_URI_from_path {
    my ($self, $path) = @_;
    chomp $path;
# used in TextResponse::get_adhoc_m3u and get_stored_playlist
    my $songs = $self->find_from_path($path);
# should just be the first result
#return (defined $songs->[0]) ? $songs->[0]->get_URI : undef;
    if (defined $songs) {
        if (scalar @{$songs} < 1) {
            log_error("No songs matching given path ${path} were found!");
        }   
        return $songs->[0]->get_URI;
    } else {
      log_error("No songs matching given path ${path} were found!");
    }
    return undef;
}

sub is_stale {
	my $self = shift;
	$self->{'song_objects'}->is_stale($self->{'rootdir'}, $self->{'gen_time'});
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

    #sort map ( $_->get_URI( 'hyperlinked' => $hyperlinked ),
    #    @{ $self->{'songs'} } );

	sort map ( { 'TITLE' => $_->get_URI( 'hyperlinked' => $hyperlinked ),
			     'URI'   => $_->get_URI() } , @{ $self->{'songs'}} ); 
}

sub find_from_path {
  my $self       = shift;
  my (@paths)       = @_;
  my $ret = undef;

  my %search = map { $_ => 1 } @paths;
  my @songs = $self->list_of_songs;
  foreach my $song (@songs) {
    if (defined $search{$song->get_uni_filename}) { # get_filename???
      push @{$ret}, $song;
    }
  }
  return $ret;
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
	my $ti;
	if (config_value('TESTING')) {
	    use tests::mocks::MockTagInfo;
	    $ti = new tests::mocks::MockTagInfo( playlist => $self );		
	} else {
	    use MP3S::Music::TagInfo;
	    $ti = new MP3S::Music::TagInfo( playlist => $self );
	}
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
    my $thash      = undef;

    my $ti = $self->get_tag_info;
    if ($ti) {
        $tname   = $ti->get_trackname($song_obj);
        $tsecs   = $ti->get_tracksecs($song_obj);
        $tartist = $ti->get_artist($song_obj);
        $thash = $ti->get_hash($song_obj);

        #if unable to find the artist/title, make song title up from filename
        if ( $tname =~ /Unknown Title/i ) {
            ($tname) = $song_obj->get_filename =~ m/\/([^\/]*)$/;
        }

    }
    ( $tname, $tsecs, $tartist, $thash );
}

1;
