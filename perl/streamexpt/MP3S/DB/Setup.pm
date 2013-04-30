package MP3S::DB::Setup;

use strict;
use MP3S::DB::Access;

sub init {
	my ($reuse_stats) = @_;
	my $db = MP3S::DB::Access->new;
	
	unless ($reuse_stats) {
		$db->execute(qq{
			DROP TABLE IF EXISTS MP3S_stats;
			
			CREATE TABLE MP3S_stats
			( category varchar(50) not null,
			  item     varchar(2000) not null,
			  count int not null default 0,
			PRIMARY KEY (category, item) );		
			GRANT SELECT on MP3S_stats to public;
		});
	}
	
	$db->execute(qq{
		
		DROP TABLE IF EXISTS MP3S_starttime;
				
		CREATE TABLE MP3S_starttime
		( start timestamp not null );
		
		INSERT INTO MP3S_starttime VALUES(now());
		
	});
}

sub create_tagstable {

	my $db = MP3S::DB::Access->new;
	$db->execute(qq{
		DROP TABLE IF EXISTS MP3S_tags;
		
		CREATE TABLE MP3S_tags
		( song_filepath varchar(2000) not null,
		  file_hash varchar(50) null,
		  artist varchar(100) null,
		  title varchar(200) null,
		  secs integer not null default -1,
		  PRIMARY KEY (song_filepath) );
	});
}

1;