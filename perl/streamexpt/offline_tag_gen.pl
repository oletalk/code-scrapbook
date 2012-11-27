#!/usr/bin/perl -w

use strict;
use MSConf qw(config_value);
use Playlist;

use Getopt::Long;

our $playlist;
our $rootdir;
our $config_file = "default.conf";
our $debug;

# same usage (basically) as mp3server
my $res = GetOptions("playlist=s" => \$playlist,
					 "rootdir=s"  => \$rootdir,
					 "config_file=s" => \$config_file,
					 "debug"      => \$debug);

MSConf::init($config_file);

die "Tags file is not specified in config" unless config_value('tagsfile');

# either playlist or root dir must be specified
die "Either playlist or rootdir must be specified" 
	unless (defined $playlist or defined $rootdir);

my $plist = Playlist->new(playlist => $playlist, rootdir => $rootdir); # rootdir overrides playlist


print "Now generating tags for the playlist.  Please wait.";
$plist->process_playlist("/");
$plist->generate_tag_info;  # CM this takes really long (minutes) for reasonably large playlist

print "DONE\n";