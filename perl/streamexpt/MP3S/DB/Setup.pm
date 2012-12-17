package MP3S::DB::Setup;

use strict;
use MP3S::DB::Access;

sub init {
	my $db = MP3S::DB::Access->new;
	$db->execute(qq{
		DROP TABLE IF EXISTS stats;
		
		DROP TABLE IF EXISTS starttime;
		
		CREATE TABLE stats
		( category varchar(50) not null,
		  item     varchar(2000) not null,
		  count int not null default 0,
		PRIMARY KEY (category, item) );
		
		CREATE TABLE starttime
		( start timestamp not null );
		
		INSERT INTO starttime VALUES(now());
		
	});
}

1;