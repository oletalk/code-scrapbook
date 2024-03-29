package TaskList;

use strict;
use warnings;
use Carp;
use POSIX qw/strftime/;
use Time::Local;  # ok, core module

use constant START => qr/^start|begin$/;
use constant STOP  => qr/^stop|end$/;

use constant DAY_SECONDS => 86400;

sub new {
	my $class = shift;
	my %args = @_;
	
	my %stuff = ();
	$stuff{input_timestamp_format} = 'HH:MM';
	$stuff{timestamp_format} = '%a %d %b %Y %T';
	$stuff{short_timestamp_format} = '%T';
	$stuff{archive_timestamp_format} = '%Y%m%d.%H%M';
	
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
	
	open my $fh, '<', $self->{file} or die "Problem opening activities file ".$self->{file}." for reading: $!";
	
	$self->{open_tasks} = ();
	while (my $line = <$fh>) {
		chomp $line;
		my ($state, $task, $timestamp) = split /#/, $line;
		
		my $ts = strftime( $self->{timestamp_format}, localtime($timestamp));
		print "$state, $task, $ts ($timestamp)\n" if $self->{debug};
		
		if ($state =~ START) {
			if (defined $self->{open_tasks}->{$task}) {
				carp "[Internal list error] 'start' being called on already-open task '$task'!";
			} else {
				$self->{open_tasks}->{$task} = $timestamp;
			}
		} elsif ($state =~ STOP) {
			if (defined $self->{open_tasks}->{$task}) {
				my $elapsed = $timestamp - $self->{open_tasks}->{$task};
				$self->_add_elapsed_time($task, $elapsed);  # adds task to closed_tasks
				$self->_add_period($task, $self->{open_tasks}->{$task}, $timestamp);
				delete $self->{open_tasks}->{$task};
			} else {
				carp "[Internal list error] 'stop' being called on not-open task '$task'!";
			}
		}
		
	}
}

sub _add_period {
	my $self = shift;
	my ($task, $period_start, $period_end) = @_;
	
	push @{$self->{periods}->{$task}}, [ $period_start, $period_end ];
}

sub get_periods {
	my $self = shift;
	my ($task) = @_;
	
	$self->{periods}->{$task};
}

sub get_timestamp_format {
	my $self = shift;
	$self->{timestamp_format};
}

sub get_short_timestamp_format {
	my $self = shift;
	$self->{short_timestamp_format};
}

# note that this number only gets updated *after* the activities file is read
# so immediately after an operation it will probably be wrong
sub number_of_open_tasks {
	my $self = shift;
	my $ctr = 0;
	foreach (keys %{$self->{open_tasks}}) {
		$ctr++ if defined $self->{open_tasks}->{$_};
	}
	$ctr;
}

sub get_open_tasks {
	my $self = shift;
	
	$self->{open_tasks};
}

sub get_closed_tasks {
	my $self = shift;
	$self->{closed_tasks};
}

sub reopen_closed_task {
	my $self = shift;
	my ( $tasknum, $timespec ) = @_;
	
	# Find out the task name from closed_tasks
	my $ctr = 0;
	my $taskname;
	my %closed = %{$self->{closed_tasks}};
	foreach my $task (sort keys %closed) {
		$ctr++;
		$taskname = $task if $ctr == $tasknum;
	}
	
	if ( $self->open_task( $taskname, $timespec ) ) {
		return $taskname;
	}
	return 0;
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

# reset timestamp to given argument(s):
# either (1) a given 'time' e.g. '09:50' and day offset e.g. 2 days ago
#     or (2) a raw timestamp e.g. 1393166660
sub reset_timestamp {
	my $self = shift;
	my ($reset_time_HHMM, $day_offset) = @_;
	$day_offset = 0 unless defined $day_offset;
	
	my @localtime = localtime();
	my $timestamp;
	
	if ($reset_time_HHMM =~ /^\d+$/) {
		$timestamp = $reset_time_HHMM;
		warn "Given raw timestamp value to reset to";
	} else {
		my ($hh, $mm) = $reset_time_HHMM =~ /^(\d\d):(\d\d)$/;

		if ($day_offset < 0 || $day_offset > 7) {
			carp "Day offset must be between 0 and 7";
			$day_offset = 0;
		}
		if (!defined $hh || !defined $mm) {
			carp "Given reset time $reset_time_HHMM isn't valid - resetting to now";
		}
		elsif ($hh < 0 || $hh > 23 || $mm < 0 || $mm > 59) {
			carp "Given reset time $reset_time_HHMM isn't valid - resetting to now";
		} else { # reset the hours/minutes
			$localtime[2] = $hh;
			$localtime[1] = $mm;
			$localtime[0] = 0;
		}
		$timestamp = strftime('%s', @localtime);
		$timestamp -= $day_offset * DAY_SECONDS;		
	}
	$timestamp;
}

sub open_task {
	my $self = shift;
	my ($taskname, $timespec) = @_;
	if (defined $self->{open_tasks}->{$taskname}) {
		$self->{error} = "An open task by the name '$taskname' already exists!";
	} elsif ($taskname =~ /^\d+$/ ) {
		$self->{error} = "All-numeric task names are not allowed!";
	} else {
		undef $self->{error};
		push @{$self->{pending_writes}}, [ 'start', $taskname, $timespec ];
	}
	return !defined $self->{error};
}

sub close_task {
	my $self = shift;
	my ($taskname, $timespec) = @_;
	
	# can be given task number as well
	if ($taskname =~ /^\d+$/) {
		# see also TaskDisplay::display_open_tasks
		my $o = $self->{open_tasks};

		my $ctr = 0;
		foreach my $opentask (sort { $o->{$a} <=> $o->{$b} } keys %$o) {
			$ctr++;
			if ($taskname == $ctr) {
				$taskname = $opentask;
				last;
			}
		}
		
	}
	
	if (defined $self->{open_tasks}->{$taskname}) {
		undef $self->{error};
		# we could be given a pre-defined time that's before the open time!
		my $open_time = $self->{open_tasks}->{$taskname};
		if ($timespec) {
			my $adj_time = $self->reset_timestamp($timespec);
			if ($adj_time < $open_time) {
				my $fmt_begin_time = strftime( $self->{timestamp_format}, localtime($open_time));
				
				$self->{error} = "Given close time is before task '$taskname' begin time of $fmt_begin_time!";
			}
		}
		push @{$self->{pending_writes}}, [ 'stop', $taskname, $timespec ];
	} else {
		$self->{error} = "No open task identified by '$taskname' exists!";
	}
	return !defined $self->{error};
}

sub close_all_tasks {
	my $self = shift;
	foreach my $taskname (keys %{$self->{open_tasks}}) {
		$self->close_task($taskname);
	}
}

sub error_message {
	my $self = shift;
	my $ret = "";
	$ret = $self->{error} . "\n" if defined $self->{error};
	$ret;
}

sub backup_and_clear_file {
	my $self = shift;
	my $backupname = $self->{file};
	my $tstamp = strftime($self->{archive_timestamp_format}, localtime());
	$backupname =~ s/\.txt$/.$tstamp/;
	if ( system('mv', $self->{file}, $backupname) != 0 ) {
		die "Problem moving old file away: $!";
	}
	if ( system('touch', $self->{file}) != 0 ) {
		die "Problem re-creating new file: $!";
	}
}

sub do_pending_writes {
	my $self = shift;
	
	open my $fh, '>>', $self->{file} or die "Problem opening activities file for appending: $!";
	
	if ($self->{debug}) {
		use Data::Dumper;
		print "PENDING WRITES:\n";
		print Dumper ( $self->{pending_writes});		
	}
	
	my $changes = 0;
	foreach my $write ( @{$self->{pending_writes}} ) {
		$changes = 1;
		my ( $cmd, $taskname, $timespec ) = @$write;
		# timespec must be checked and made into a timestamp
		my $ts = $timespec ? $self->reset_timestamp($timespec) : time;
		print $fh qq{$cmd#$taskname#$ts\n};
	}
	close $fh;
	carp "No pending changes were committed" unless $changes;
}

1;