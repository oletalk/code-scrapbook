package Playlist; # DON'T USE AS YET

use strict;
use Carp;
use File::Find::Rule;
use File::Temp qw/ tempfile /;

sub new {
	my $class = shift;
	bless { @_ }, $class;
}




sub rm_temp_playlist {
	my $self = shift;
	if (defined $self->{'temp_playlist'}) {
		my $plsname = $self->{'temp_playlist'};
		system("rm -f $plsname");
		undef $self->{'temp_playlist'};
	}
}


sub gen_playlist {
	my $self = shift;
	my ($rootdir) = @_;
	
	my ($fh, $plsname) = tempfile();
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
	
	$self->{'temp_playlist'} = $plsname;
	return $plsname;
}
1;