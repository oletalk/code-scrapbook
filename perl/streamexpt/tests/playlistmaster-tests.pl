use lib '..';
use tests::TestingInit;

use strict;
use Test::More tests => 3;

BEGIN { use_ok( 'MP3S::Music::PlaylistMaster' ) }

TestingInit::init;

my $p1 = MP3S::Music::PlaylistMaster->new('tests/testdata/testpls.m3u');
my @p1songs = @{$p1->songs};

is( scalar @p1songs, 2, "Created Playlist master list fine");

my $p2 = MP3S::Music::PlaylistMaster->new('tests/testdata/');
my @p2songs = @{$p2->songs};

is( scalar @p2songs, 3, "Created (rootdir-based) Playlist master list fine");


#ok( 'greatalbum.m3u' eq $p2->reckon_m3u_name, "Name reckoning for directory-based pl works" );
