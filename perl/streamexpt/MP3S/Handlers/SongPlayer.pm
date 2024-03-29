package MP3S::Handlers::SongPlayer;

use strict;
use Carp;
use File::Temp qw/ tempfile /;    # if we need to generate a temp playlist file
use MP3S::Misc::Logger qw(log_info log_debug log_error);
use MP3S::Misc::Util;
use MP3S::Misc::MSConf qw/config_value/;

use Encode;

sub new {
    my $class = shift;
    bless {
        'downsample' => 0,
        @_
    }, $class;

}

sub set_connection {
    my $self = shift;
    my ($conn) = @_;
    $self->{'conn'} = $conn;
}

sub get_connection {
    my $self = shift;
    $self->{'conn'};
}

sub set_downsampling {
    my $self = shift;
    my ($downsample) = @_;
    $self->{'downsample'} = $downsample;
}

sub downsampling_on {
    my $self = shift;
    $self->{'downsample'};
}

sub play {
    my $self = shift;

    my ($song_obj) = @_;

	my $chunk_size = config_value('chunksize') || 1024;
	if ($chunk_size < 256) {
		$chunk_size = 256;
		log_error("Invalid chunksize provided - bumped up to 256")
	}
	log_debug("Sending song(s) over with chunk size $chunk_size");

    my $song = $song_obj->get_filename;

    #downsampling?
    if ( $self->downsampling_on ) {
        log_info("Downsampling song...\n");

        #$song = $self->downsample($song);
    }

    my $conn = $self->{'conn'};

    #$conn->send_file( $song );
    # send until finished or client stopped listening

    my $fh_song;
    if ( $self->downsampling_on ) {

        open( $fh_song, downsample_piped($song) )
          or log_error("Couldn't open downsampled song: $!");
    }
    else {
        open( $fh_song, $song ) or log_error("Unable to open song: $!");
    }

    my %caught;
    my $starttime = time;
    if ($fh_song) {
        local $SIG{'PIPE'} =
          sub { $caught{'PIPE'} ||= time; };
        #$conn->send_file($fh_song);

		my ($read_status, $print_status, $chunk) = (1,1);
		while ( $read_status && $print_status ) {
			$read_status = read ($fh_song, $chunk, $chunk_size);
			if ( defined $chunk && defined $read_status) {
				$print_status = print $conn $chunk;
			}
			undef $chunk;
		}

        close $fh_song;
    }

    my $ret = 0;
    if ( defined $caught{'PIPE'} ) {
        $ret = $caught{'PIPE'} - $starttime;
    }
    return $ret;

}

# private non-object method for returning command to pipe into filehandle if downsampling the song
sub downsample_piped {
    my ($song) = @_;

    my $ret;
    my $songname = $song;

    my $IFSC         = qq|IFS="\$(printf '\\n\\t')";|;
    my $new_songname = qx|${IFSC}printf "\%b" "$songname"|;

    $songname = "\"${new_songname}\"";
    if ( $song =~ /mp3$/i ) {
        log_info("Downsampling as MP3");
        $ret = qq{${IFSC}/usr/local/bin/lame --mp3input -b 32 $songname - | };
    }
    elsif ( $song =~ /ogg$/i ) {
        log_info("Downsampling as OGG");
        $ret =
qq{${IFSC}/usr/local/bin/ffmpeg -loglevel quiet -i $songname -acodec libvorbis -f ogg -ac 2 -ab 64k - < /dev/null | };
    }
    else {
        log_error("No idea how to downsample this file");
    }

    $ret;
}

1;
