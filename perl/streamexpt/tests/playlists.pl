use lib '..';

use strict;
use Test::More tests => 3;

BEGIN { use_ok( 'Playlist' ) }

my $p1 = Playlist->new(playlist => '/path/to/awesomelist.m3u');
my $p2 = Playlist->new(rootdir => '/home/foo/bar/albums/coolartist/greatalbum');
ok( 'awesomelist.m3u' eq $p1->reckon_m3u_name, "Name reckoning for given playlist works" );
ok( 'greatalbum.m3u' eq $p2->reckon_m3u_name, "Name reckoning for directory-based pl works" );
