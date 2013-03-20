use lib '..';

use strict;
use Test::More tests => 4;

BEGIN { use_ok( 'MP3S::Music::Song' ) }

ok( my $s1 = MP3S::Music::Song->new( filename => '/a/file'), 'created a new Song object ok');

my $song = MP3S::Music::Song->new( filename => '/path/to/song.mp3');
is( $song->get_filename, '/path/to/song.mp3', 'path set correctly');

$song->set_URI_from_rootdir('/path/to');
is( $song->get_URI, '/song.mp3', 'set URI works correctly from given root dir');