#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use Data::Dumper;
use TaskList;
use TaskDisplay;

# defaults
my $activities_file = "$ENV{HOME}/activities.txt";
my $debug;
my $TS_FORMAT = '%a %d %b %Y %T';
# TODO: format for parsing a 'supplied' time


# get options
my $res = GetOptions(
	"file=s"	=> \$activities_file,
	"timestampformat=s" => \$TS_FORMAT,
	"debug"		=> \$debug
);

# read command
my ($command, $task, @options) = @ARGV;
if ($command !~ /^start|begin|stop|end|status|times|details|today|back$/) {
	usage();
	exit 1;
}

my $list = new TaskList(
	timestamp_format => $TS_FORMAT, 
	file => $activities_file,
	debug => $debug);

$list->read_activities_file;
if ($command eq 'start' || $command eq 'begin') {
	if ($list->open_task($task, $options[0])) {
		$list->do_pending_writes;
	} else {
		print $list->error_message;
	}
} elsif ($command eq 'stop' || $command eq 'end') {
	if ($list->close_task($task, $options[0])) {
		$list->do_pending_writes;
	} else {
		print $list->error_message;
	}
} elsif ($command eq 'status' || $command eq 'list') {
	TaskDisplay::display_open_tasks( $list );
} elsif ($command eq 'times') {
	TaskDisplay::display_closed_tasks( $list );
} elsif ($command eq 'details') {
	if (defined $task) {
		TaskDisplay::display_task_details( $list, $task );
	} else {
		TaskDisplay::display_all_task_details( $list );
	}
} elsif ($command eq 'today') {
	push @options, $task;
	my %opts = map { $_ => 1 } @options;
	TaskDisplay::display_today( 
		tasks => $list, 
		begin => '08:00', 
		end => '18:00', 
		collapse => defined $opts{flat},
		trails => defined $opts{trails}
	);
} elsif ($command eq 'back') {
	#push @options, $task;
	#my %opts = map { $_ => 1 } @options;
	TaskDisplay::display_today( 
		tasks => $list, 
		begin => '08:00', 
		end => '18:00', 
		day_offset => $task
	);
}

exit 0;

################### SUBS ###################


sub usage {
	print STDERR qq{Usage: log.pl start|stop|status
		start 'task description' [<HH:MM>] - Start a new task
		stop 'task description'  [<HH:MM>] - Stops a task in progress
		status                             - Lists tasks in progress
		times                              - Shows elapsed times for stopped tasks
		details 'task description'         - Shows details on elapsed times for task
		today [flat] [trails]              - Shows calendar-style view of today's tasks
		back <X=1 to 7>                    - Shows calendar-style view for tasks X days ago
};
}