use lib '..';
use tests::TestingInit;

use strict;
use Test::More tests => 11;

BEGIN { use_ok( 'MP3S::Music::Playlist' ) }

TestingInit::init();
my $p1 = MP3S::Music::Playlist->new(rootdir => 'tests/testdata', testing => 1);
is( $p1->gen_reason, 'No particular reason', 'default reason as expected');

eval {
	my $x = $p1->list_of_songs;
	fail("should not have any song info as yet");
};

$p1->generate_tag_info();  

$p1->process_playlist("/");
my @songs = $p1->list_of_songs;
is( scalar @songs, 3, "pulled in and processed all 3 songs in test directory");

is( $p1->reckon_m3u_name, 'playlist.m3u', 'hardcoded m3u name as expected');

my $secondsong = $songs[1];
# some song-specific tests here
is( $secondsong->get_filename, 'tests/testdata/second.mp3', 'correct song name');
is( $secondsong->get_URI, '/second.mp3', 'correct song URI');
# getsong works as expected
is( $p1->get_song->get_URI, '/first.mp3', 'got first song out OK');
$p1->get_song;
my $s3 = $p1->get_song;
my @ti3 = $p1->get_trackinfo($s3);
is( $ti3[0], 'Mr Foo - Track 3', 'track info correct');
is( $p1->get_song, undef, "no more songs left");
print "Sleeping for 1 second to test is_stale functionality...\n";
sleep(1);
system qq{touch tests/testdata/verynew.mp3};
ok( $p1->is_stale, "New file, so playlist is stale");
$p1 = MP3S::Music::Playlist->new(rootdir => 'tests/testdata', testing => 1);
$p1->process_playlist("/");
@songs = $p1->list_of_songs;

is( scalar @songs, 4, "pulled in and processed new song additionally");

END {
	system(qq{rm -f tests/testdata/verynew.mp3});
} 