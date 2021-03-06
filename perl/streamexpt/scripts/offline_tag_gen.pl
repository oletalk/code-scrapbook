#!/usr/bin/perl -w

use strict;
use MP3S::Misc::MSConf qw(config_value);
use MP3S::Music::Playlist;
use MP3S::DB::Setup;
use Sys::Hostname;
use MP3S::Net::TextResponse;

use Getopt::Long;

our $playlist;
our $rootdir;
our $config_file = "default.conf";
our $debug;
our $cleartags;

my $host = hostname();
my $port;
my $m3ufile;

# same usage (basically) as mp3server
my $res = GetOptions("playlist=s" => \$playlist,
					 "rootdir=s"  => \$rootdir,
					 "cleartags"  => \$cleartags,
					 "config_file=s" => \$config_file,
					 "m3uoutput=s" => \$m3ufile,
					 "debug"      => \$debug);

MP3S::Misc::MSConf::init($config_file);


$port ||= config_value('port');

if (defined $cleartags) {
	print "WARNING! This will clear out any existing tag info in the database!  If this is OK, hit Enter.\n";
	my $dummy = <STDIN>;
	MP3S::DB::Setup::create_tagstable;	
}
if (defined $m3ufile && !defined $port) {
	die "Port needed to generate m3u file (which consists of URLs)";
}
# either playlist or root dir must be specified
die "Either playlist or rootdir must be specified" 
	unless (defined $playlist or defined $rootdir);

my $plist = MP3S::Music::Playlist->new(playlist => $playlist, rootdir => $rootdir); # rootdir overrides playlist

print "Specified output m3u file: $m3ufile\n" if $m3ufile;

print "Now generating tags for the playlist.  Please wait.";
$plist->process_playlist("/");
$plist->generate_tag_info;  # CM this takes really long (minutes) for reasonably large playlist

if (defined $m3ufile) {
	open (my $fh, ">", "$m3ufile") or die "Unable to open file $m3ufile for writing: $!";
	print $fh MP3S::Net::TextResponse::get_m3u($plist, $port);
	close $fh;
}

print "DONE\n";