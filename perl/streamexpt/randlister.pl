#!/usr/bin/perl -w
#
# Generate a playlist based on the stats currently in the database
# 1. List of the most popular
# 2. Random list
# 3. List of songs by a certain artist
#
# As you can figure out, it doesn't need the server to be up, just the database
#
# Sample usage: ./randlister --size 50 --playlist ~/playlist.txt --option popular

use strict;

use Getopt::Long;
use MP3S::DB::Access;
use MP3S::Misc::MSConf;

# Defaults
my $config_file = "conf/default.conf";
my $size = 20;
my $debug;
my $playlist;
my $option = "popular";

# Get Options
GetOptions(
	"config_file=s" => \$config_file,
	"debug"		=> \$debug,
	"size=i"	=> \$size,
	"playlist=s"	=> \$playlist,
	"option=s" => \$option,
);

MP3S::Misc::MSConf::init($config_file);
my $db = MP3S::DB::Access->new;

# Don't proceed unless a playlist was provided
if (!$playlist) {
	die "Please provide a playlist (text file) with --playlist";
}

my $query = getQuery($option);
die "unknown option '$option'" unless $query;

my $res = $db->execute($query, $size);

my %favourites = (); # oh yeah, like that Windows folder!

foreach my $row (@$res) {
	my ($item, $count) = @{$row};
	#print "$item\n";
	$favourites{$item} = 1;
}
my $total = keys %favourites;

# Read playlist
open my $fh, $playlist or die "Unable to open provided playlist: $!";
while (my $line = <$fh>) {
	chomp $line;
	my ($song) = $line =~ /([^\/]+)$/;
	#print "SONG: $song \n";
	if (defined $favourites{$song}) {
		print "$line \n" ;
		delete $favourites{$song};
	}
}

# If favourites not found, print them
foreach (sort keys %favourites) {
		print "Not found: $_ \n";
}
print STDERR "Remainder: " . (keys %favourites) . " / $total \n";
print STDERR "DONE\n";
exit (0);

sub getQuery {
	my ($option) = @_;
	my $ret = undef;
	if ($option eq 'popular') {
		$ret = qq{
SELECT item, count 
FROM MP3S_stats 
WHERE category = 'SONGS PLAYED'
ORDER BY count desc, item
LIMIT ?};
	}
	$ret;
}
