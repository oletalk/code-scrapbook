package TaskList;

use strict;
use warnings;
use Carp;
use POSIX qw/strftime/;

sub new {
	my $class = shift;
	my %args = @_;
	
	my %stuff = ();
	$stuff{input_timestamp_format} = 'HH:MM';
	$stuff{timestamp_format} = '%a %d %b %Y %T';
	
	# TODO: validation for each
	foreach my $arg (qw(timestamp_format input_timestamp_format file debug)) {
		if ( $args{$arg} ) {
			$stuff{$arg} = $args{$arg};
		}
	}
	croak "No associated file provided" unless defined $stuff{file};
	bless \%stuff, $class;
}

# read current state of activities file
# format: command#task description#timestamp
sub read_activities_file {
	my $self = shift;
	
	open my $fh, '<', $self->{file} or die "Problem opening activities file for reading: $!";
	
	$self->{open_tasks} = ();
	while (my $line = <$fh>) {
		chomp $line;
		my ($state, $task, $timestamp) = split /#/, $line;
		
		my $ts = strftime( $self->{timestamp_format}, localtime($timestamp));
		print "$state, $task, $ts ($timestamp)\n" if $self->{debug};
		
		if ($state =~ /^start|begin$/) {
			if (defined $self->{open_tasks}->{$task}) {
				carp "[Internal list error] 'start' being called on already-open task '$task'!";
			} else {
				$self->{open_tasks}->{$task} = $timestamp;
			}
		} elsif ($state =~ /^stop|end$/) {
			if (defined $self->{open_tasks}->{$task}) {
				my $elapsed = $timestamp - $self->{open_tasks}->{$task};
				$self->_add_elapsed_time($task, $elapsed);
				undef $self->{open_tasks}->{$task};
			} else {
				carp "[Internal list error] 'stop' being called on not-open task '$task'!";
			}
		}
		
	}
}

sub get_timestamp_format {
	my $self = shift;
	$self->{timestamp_format};
}

sub get_open_tasks {
	my $self = shift;
	
	$self->{open_tasks};
}

sub get_closed_tasks {
	my $self = shift;
	$self->{closed_tasks};
}

sub _add_elapsed_time {
	my $self = shift;
	my ($taskname, $elapsed_secs) = @_;
	if (!defined $self->{closed_tasks}->{$taskname}) {
		# initialise it to zero
		$self->{closed_tasks}->{$taskname} = 0;
	}
	$self->{closed_tasks}->{$taskname} += $elapsed_secs;
}

sub open_task {
	my $self = shift;
	my ($taskname, $timespec) = @_;
	if (defined $self->{open_tasks}->{$taskname}) {
		$self->{error} = "A task by the name '$taskname' already exists!";
	} else {
		undef $self->{error};
		push @{$self->{pending_writes}}, [ 'start', $taskname, $timespec ];
	}
	return !defined $self->{error};
}

sub close_task {
	my $self = shift;
	my ($taskname, $timespec) = @_;
	if (defined $self->{open_tasks}->{$taskname}) {
		undef $self->{error};
		push @{$self->{pending_writes}}, [ 'stop', $taskname, $timespec ];
	} else {
		$self->{error} = "No task by the name '$taskname' exists!";
	}
	return !defined $self->{error};
}

sub error_message {
	my $self = shift;
	$self->{error};
}

sub do_pending_writes {
	my $self = shift;
	
	open my $fh, '>>', $self->{file} or die "Problem opening activities file for appending: $!";
	
	if ($self->{debug}) {
		use Data::Dumper;
		print "PENDING WRITES:\n";
		print Dumper ( $self->{pending_writes});		
	}
	
	foreach my $write ( @{$self->{pending_writes}} ) {
		my ( $cmd, $taskname, $timespec ) = @$write;
		# TODO: timespec must be checked and made into a timestamp
		$timespec ||= time;
		print $fh qq{$cmd#$taskname#$timespec\n};
	}
	close $fh;
}

1;