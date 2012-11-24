package SongPlayer;

use strict;
use Carp;
use File::Temp qw/ tempfile /; # if we need to generate a temp playlist file

sub new {
	my $class = shift;
	bless { 'downsample' => 0, 
			@_	}, $class;
	
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

sub debug {
	my $self = shift;
	$self->{'debug'};
}

sub play {
	my $self = shift;
	
	my ($song) = @_;
	
	#downsampling?
	if ($self->downsampling_on) {
		warn "Downsampling song...\n";
		$song = $self->downsample($song);
	}
	
	my $conn = $self->{'conn'};
	$conn->send_file( $song );
	
	if ($self->downsampling_on && -r $song) {
		warn "Deleting temp file $song";
		system("rm -f '$song'");
		#$delete_list{$song} = undef;
	}
	
}


sub downsample {
	
	my $self = shift;
	my ($song) = @_;

	my ($fh, $dsfilename) = tempfile( DIR => '/tmp', SUFFIX => '.mxx');
	#add_delete_list($dsfilename);
	my $safe_songname = $song;
	chomp $safe_songname;
	$safe_songname =~ s/\"/\\\"/g;

	if ($safe_songname =~ /mp3$/i) {
		warn "Downsampling as MP3";
		system qq{/usr/local/bin/lame --mp3input -b 32 "$safe_songname" $dsfilename} or warn "Downsampling was not possible: $!";
	} elsif ($safe_songname =~ /ogg$/i) {
		warn "Downsampling as OGG";
		system qq{/usr/local/bin/sox -t ogg "$safe_songname" -t raw - | oggenc --raw --downmix -b 64 -o $dsfilename - } or warn "Downsampling was not possible: $!";

	} else {
		warn "No idea how to downsample this file";
	}

	warn "Done downsampling." if $self->debug;
	$dsfilename;
}


1;