package MP3S::Music::Song;

use MP3S::Misc::Util;

sub new {
	my $class = shift;
	my %args = @_;
	
	croak ("No filename given") unless $args{'filename'};
	bless \%args, $class;
}

sub get_filename {
	my $self = shift;
	$self->{'filename'};
}

sub get_uni_filename {
	my $self = shift;
	$self->{'uni_filename'};
}

sub set_URI_from_rootdir {
	my $self = shift;
	my ($rootdir) = @_;
	
	$rootdir ||= "/";
	
	my $songuri = $self->{'uni_filename'} || $self->{'filename'};
	if ($rootdir) {
		$songuri = _cut_rootdir($songuri, $rootdir);
		$self->{'nonuni_URI'} = _cut_rootdir($self->{'filename'}, $rootdir);
	}
	$self->{'URI'} = $songuri;
}

sub _cut_rootdir {
	my ($str, $rootdir) = @_;
	$str =~ s/^$rootdir//;
	$str;
}

sub get_URI {
	my $self = shift;
	my (%args) = @_;
	my $URI = $self->{'URI'};
	
	if ($args{'playlink'}) {
		$ret = qq |/play/${URI}|;
	} elsif ($args{'hyperlinked'}) {
		my $title = $args{'title'};
		#$title ||= $URI;
		$title ||= $self->{'nonuni_URI'} || $URI;

		$ret = qq |${title} <a href="/play/${URI}">D</a><br/> \n|;
	} else {
		$ret = $URI;
	}
	
	$ret;
}

1;