use lib '..';
use tests::TestingInit;

use strict;
use Test::More tests => 4;

BEGIN { use_ok( 'MP3S::Misc::Util' ) }

TestingInit::init;
is( MP3S::Misc::Util::filename_only('/this/is/a/path/to/a/file.mp3'), 'file.mp3', 'filename_only returns just that');
is( MP3S::Misc::Util::format_datetime('%d/%m/%Y %H:%M', 1362859467), '09/03/2013 20:04', 'format_datetime works as expected');

my $gh = MP3S::Misc::Util::get_hour;
ok( $gh =~ /^\d\d$/, 'get_hour works as expected');
