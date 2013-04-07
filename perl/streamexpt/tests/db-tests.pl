use lib '..';
use strict;

use Test::More tests => 7;

BEGIN { use_ok( 'MP3S::DB::Access' ) }

use MP3S::Misc::MSConf;
use MP3S::Misc::Logger;
MP3S::Misc::MSConf::init('tests/testdata/testing-withdb.conf');
MP3S::Misc::Logger::init(level => MP3S::Misc::Logger::INFO);

eval {
	my $baddb = MP3S::DB::Access->new( quiet => 1, dbname => 'bogusdb');
	$baddb->execute('SELECT 1');
	fail('no error thrown with nonexistent db');
};


my $db = MP3S::DB::Access->new( quiet => 1);
ok ($db, 'DB handle created ok');
ok($db->execute('SELECT 1'), 'DB connected ok');
my $setupsql = qq{
	drop table if exists dbtest0704;
	create table dbtest0704 ( a varchar(20) not null, b int not null default 0, primary key (a));
	insert into dbtest0704 values('the first row', 1),('another row', 20),('yet another', 2),('something else', 33);
};
$db->execute($setupsql);

my $row = $db->exec_single_row('SELECT a, b from dbtest0704 WHERE a = ?', ('yet another'));
is( $row->[1], 2, 'exec_single_row ok');
my $res = $db->exec_single_cell('SELECT count(*) from dbtest0704');
is( $res, 4, 'exec_single_cell ok');
my $list = $db->execute('SELECT b from dbtest0704');
is( scalar @$list, 4, 'execute ok');

$db->execute('SELECT 1 from othertable');
ok( $db->errstr =~ /does not exist/, 'errstr returned from bad SQL');
my $teardownsql = qq{
	drop table dbtest0704;
};
$db->execute($teardownsql);