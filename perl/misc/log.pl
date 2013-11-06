#!/usr/bin/perl

use strict;
use warnings;
use feature qw(state);
use Getopt::Long;
use Data::Dumper;
use TaskList;
use TaskDisplay;
use TaskDispatchList;

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

$command = "" unless defined $command;
my $commands = TaskDispatchList::commands;
my $exec = $commands->{$command}[0];

if (!defined $exec) {
	TaskDispatchList::usage(); 
	exit 1;
}

my $list = new TaskList(
	timestamp_format => $TS_FORMAT, 
	file => $activities_file,
	debug => $debug);

$list->read_activities_file;
&{$exec}($list, $task, \@options);

exit 0;
