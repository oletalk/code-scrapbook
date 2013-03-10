package MP3S::Misc::Stats; 
require Exporter;
@ISA       = qw(Exporter);
@EXPORT_OK = qw (count_stat output_stats get_uptime);

use strict;
use MP3S::DB::Access;
use MP3S::Misc::Logger qw(log_error);

# ----- UPTIMES -----

sub get_uptime {
    my ( $days, $hours, $min, $secs );

    my $elapsed_secs = _get_db_time();
    log_error("Problem fetching elapsed secs") unless $elapsed_secs;
    $days  = int( $elapsed_secs / 86400 );
    $hours = int( $elapsed_secs / 3600 ) % 24;
    $min   = int( $elapsed_secs / 60 ) % 60;
    $secs  = $elapsed_secs % 60;

    my $ret = "$secs seconds";
    $ret = "$min minutes, $ret" if $min > 0;
    $ret = "$hours hours, $ret" if $hours > 0;
    $ret = "$days days, $ret"   if $days > 0;

    $ret;
}

sub _get_db_time {
    my $db  = MP3S::DB::Access->new;
    my $ret = $db->exec_single_cell(
"select cast(date_part('epoch', now() - start) as integer) from MP3S_starttime"
    );
	$ret;
}

# ------------ MISCELLANEOUS EXTERNALLY DEFINED STATS -------

sub count_stat {
    my ( $category, $item ) = @_;
    if ( $category && $item ) {
        my $db    = MP3S::DB::Access->new;
        my $count = $db->exec_single_cell(
            "SELECT count FROM MP3S_stats WHERE category = ? AND item = ?",
            $category, $item );

        if ($count) {
            $count++;
            $db->execute(
                "UPDATE MP3S_stats SET count = ? WHERE category = ? AND item = ?",
                $count, $category, $item );
        }
        else {
            $db->execute(
                "INSERT INTO MP3S_stats(category, item, count) VALUES (?, ?, 1)",
                $category, $item );
        }
    }

}

sub output_stats {
    my ($uri) = @_;

	my ($dummy, $cmd, @args) = split/\//, $uri;
	
	$cmd ||= "all";
	
	my $ret = "";

	if ($cmd =~ /^help|usage$/) {
		$ret = qq{
			<h3>Stats output</h3>
			<p>Command format: /command/specifier e.g. <tt>/all /artists/top10 /clients/top20 /songs/top10 </tt></p>
			<p>For a list of commands you can use /commands
			<p>Command for this display is /help or /usage.</p>
			<p>Default command is /all.</p>
		};
	} else {
	
		my $specif = undef;
		if ($cmd !~ /^all|commands$/) {
			$specif = uc $cmd;
		}

		my $res = _get_db_category_stats($specif);

	    my $prevcat = "";
		my $catcount = 0;
		my $max_for_cat = 0;
		
		# process args for cat-specific count requests e.g. 'top10' 'top20'
		foreach my $arg (@args) {
			if ($arg =~ /^top(\d+)$/) {
				my $c = $1;
				$max_for_cat = $c if ($c > 0 && ($c % 5 == 0) && $c <= 20);
			}
		}
		
	    foreach my $row (@$res) {
	        my ( $category, $item, $count ) = @$row;
	        if ( $prevcat ne $category ) {
				$catcount = 0;
	            $ret .= " -------- $category ---------\n";
	        }
			$catcount++;
			
			if ($cmd ne 'commands') {
				if ($max_for_cat == 0 || $catcount <= $max_for_cat) {
			        $ret .= "\t$count\t - $item \n";					
				}
			}
	        $prevcat = $category;
	    }

	    $ret || "No stats available yet";
		
	}

}

sub _get_db_category_stats {
    my ($specif) = @_;
	my $db  = MP3S::DB::Access->new;
	my $res = $specif ?
		$db->execute(
			"SELECT category, item, count FROM MP3S_stats WHERE category = ? ORDER BY count desc, item",
			$specif
			)
		: $db->execute(
			"SELECT category, item, count FROM MP3S_stats ORDER BY category, count desc, item"
		    );
    $res;
}

1;
