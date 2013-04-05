use lib '..';

use strict;
use Test::More tests => 6;

BEGIN { use_ok( 'MP3S::Music::Song' ) }

ok( my $s1 = MP3S::Music::Song->new( filename => '/a/file'), 'created a new Song object ok');

my $song = MP3S::Music::Song->new( filename => '/path/to/song.mp3');
is( $song->get_filename, '/path/to/song.mp3', 'path set correctly');

my $realsong = MP3S::Music::Song->new( filename => './tests/testdata/first.mp3');
ok( defined $realsong->get_modified_time, 'modified time set');
my $realsong2 = MP3S::Music::Song->new( filename => './tests/testdata/third.mp3');

my @list1 = sort { $a->get_modified_time <=> $b->get_modified_time }($realsong2, $realsong);
is( $list1[0]->get_filename, './tests/testdata/first.mp3', 'sorted 2 songs in order of modified date ok');

$song->set_URI_from_rootdir('/path/to');
is( $song->get_URI, '/song.mp3', 'set URI works correctly from given root dir');