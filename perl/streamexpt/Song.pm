package Song;

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

sub set_URI_from_rootdir {
	my $self = shift;
	my ($rootdir) = @_;
	
	$rootdir ||= "/";
	
	my $songuri = $self->{'filename'};
	$songuri =~ s/^$rootdir// if $rootdir;
	$self->{'URI'} = $songuri;
}


sub get_URI {
	my $self = shift;
	my (%args) = @_;
	my $URI = $self->{'URI'};
	
	if ($args{'playlink'}) {
		$ret = qq |/play/${URI}|;
	} elsif ($args{'hyperlinked'}) {
		my $title = $args{'title'};
		$title ||= $URI;
		$ret = qq |${title} <a href="/play/${URI}">D</a><br/> \n|;
	} else {
		$ret = $URI;
	}
	
	$ret;
}

1;