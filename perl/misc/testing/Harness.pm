package Harness;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(setup);

use strict;
use lib '..';
use TaskList;
use TaskDispatchList;
use TaskUtil qw(read_cfg process_overrides);

use Cwd;

sub new {
	my $class = shift;
	my %args = @_;
	
	my %stuff = ();
	$stuff{activities_file} = $args{activities_file};
	$stuff{timestamp_format} = $args{timestamp_format};
	die "You need both activities_file and timestamp_format defined to initialise the harness"
		unless (defined $stuff{activities_file} && defined $stuff{timestamp_format});
	
	# set it up now too
	my $dir = getcwd;
	print "CURRENT DIR FOR TESTING IS $dir \n";
	die "Please start the tests from within the testing directory" unless $dir =~ /testing$/;

	system( "rm -f $stuff{activities_file} && touch $stuff{activities_file}" ) && die "Unable to recreate test activities file: $@";
	
	bless \%stuff, $class;
}

sub do_log {
	my $self = shift;
	my ( $command, $task, $options_aref ) = @_;
	my $commands = TaskDispatchList::commands;
	my $exec = $commands->{$command}[0];

	my $list = new TaskList(
		timestamp_format => $self->{timestamp_format}, 
		file => $self->{activities_file},
	);

	$list->read_activities_file;
	&{$exec}($list, $task, $options_aref);
}

sub do_overrides {
	my $self = shift;
	my ( $config_file ) = @_;
	print "CONFIG FILE IS $config_file\n";
	
	my ( $activities_file, $timestamp_format );
	
	process_overrides( read_cfg($config_file), 
					{ activities_file => \$self->{activities_file},
					  timestamp_format => \$self->{timestamp_format} } );
	#$self->{activities_file} = $activities_file;
	#$self->{timestamp_format} = $timestamp_format;
	
}

sub activities_file {
	my $self = shift;
	$self->{activities_file};
}

sub internal_structure {
	my $self = shift;
	my $list = new TaskList(
		timestamp_format => $self->{timestamp_format}, 
		file => $self->{activities_file},
	);

	$list->read_activities_file;
	$list;
}

sub timestamp_format {
	my $self = shift;
	$self->{timestamp_format};
}

sub log_contents {
	my $self = shift;
	local $/ = undef;
	open my $fh, $self->{activities_file} or die "Unable to open activities file: $!";
	my $filecont = <$fh>;
	close $fh;

	my $ret;
	foreach my $line (split(/\n/, $filecont)) {
		my ($cmd, $task, $timestamp) = split(/#/, $line);
		# for testing purposes, timestamp needs to be converted to 'HH:MM:SS'
		my @ltime = localtime($timestamp);
		my $ts = sprintf("%02d", $ltime[2]) . ":" . sprintf("%02d", $ltime[1]);
		push @{$ret}, {cmd => $cmd, task => $task, timestamp => $ts};
	}
	$ret;
}

sub _assignedfromvar {
	my $self = shift;
	my ( $propname, $newval ) = @_;
	if ( defined $newval ) {
		$self->{$propname} = $newval;
	}
	$self->{$propname};
}

1;