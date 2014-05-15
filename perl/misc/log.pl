#!/usr/bin/perl

use strict;
use warnings;
use feature qw(state);
use Getopt::Long;
use Data::Dumper;
use TaskList;
use TaskDisplay;
use TaskDispatchList;
use TaskUtil qw(read_cfg process_overrides);

# defaults
my $config_file = "$ENV{HOME}/.activities.cfg";
my $activities_file = "$ENV{HOME}/activities.txt";
my $debug;
my $TS_FORMAT = '%a %d %b %Y %T';
# TODO: format for parsing a 'supplied' time


# get options
my $res = GetOptions(
	"config=s" => \$config_file,
	"file=s"	=> \$activities_file,
	"timestampformat=s" => \$TS_FORMAT,
	"debug"		=> \$debug
);

# override with config if provided
if ( -r $config_file ) {
process_overrides( read_cfg($config_file),
				{ activities_file => \$activities_file,
				  timestampformat => \$TS_FORMAT} );
} else {
	warn "Config file $config_file not provided, please create";
}

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
