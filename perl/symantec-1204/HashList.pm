package HashList;
$VERSION=1.00;
use strict;

sub new
{
	my $class = shift;
	my %list = ();
	bless {
		'_list' => \%list
	}, $class;
}

sub clear_list {
	my $self = shift;
	%{$self->{'_list'}} = ();
}

sub add_to_list {
	my $self = shift;
	my ($spec) = @_;
	$self->{'_list'}{$spec} = 1;
}

sub remove_from_list {
	my $self = shift;
	my ($spec) = @_;
	$self->{'_list'}{$spec} = 0;	
}

sub display_list {
	my $self = shift;
	
	foreach my $item (keys %{$self->{'_list'}}) {
		print "  -> $item \n" if $self->{'_list'}{$item} == 1;
	}
}

sub matches_start {
	my $self = shift;
	my ($spec) = @_;
	my $ret = 0;
	
	foreach my $item (keys %{$self->{'_list'}}) {
		if ($spec =~ qr{^$item}) {
			$ret = 1;
		}
	}
	$ret;
}

sub matches_exact {
	my $self = shift;
	my ($spec) = @_;
	my $ret = 0;
	
	foreach my $item (keys %{$self->{'_list'}}) {
		if ($spec eq $item) {
			$ret = 1;
		}
	}
	$ret;
}