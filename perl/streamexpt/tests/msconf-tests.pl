use lib '..';

# no use of TestingInit here as it already uses MSConf
use strict;
use Test::More tests => 4;

BEGIN { use_ok( 'MP3S::Misc::MSConf', qw(config_value) ) }

ok( MP3S::Misc::MSConf::init('tests/testdata/testing.conf'), 'pick up standard test conf ok');
eval {
	MP3S::Misc::MSConf::init('tests/testdata/bogus.conf');
	fail('error for nonexistent config file');	
};
MP3S::Misc::MSConf::init('tests/testdata/simple.conf');
is( config_value('port'), 8089, 'correct value for port');
is( config_value('debg'), undef, 'nothing for undefined config value');