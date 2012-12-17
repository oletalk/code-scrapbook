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

    my $db           = MP3S::DB::Access->new;
    my $elapsed_secs = $db->exec_single_cell(
"select cast(date_part('epoch', now() - start) as integer) from starttime"
    );
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

# ------------ MISCELLANEOUS EXTERNALLY DEFINED STATS -------

sub count_stat {
    my ( $category, $item ) = @_;

    if ( $category && $item ) {
        my $db    = MP3S::DB::Access->new;
        my $count = $db->exec_single_cell(
            "SELECT count FROM stats WHERE category = ? AND item = ?",
            $category, $item );

        if ($count) {
            $count++;
            $db->execute(
                "UPDATE stats SET count = ? WHERE category = ? AND item = ?",
                $count, $category, $item );
        }
        else {
            $db->execute(
                "INSERT INTO stats(category, item, count) VALUES (?, ?, 1)",
                $category, $item );
        }
    }

}

sub output_stats {
    my ($order) = @_;

    my $ret = "";
    my $db  = MP3S::DB::Access->new;
    my $res = $db->execute(
        "SELECT category, item, count FROM stats ORDER BY category, count desc, item"
    );

    my $prevcat = "";
    foreach my $row (@$res) {
        my ( $category, $item, $count ) = @$row;
        if ( $prevcat ne $category ) {
            $ret .= " -------- $category ---------\n";
        }
        $ret .= "\t$count\t - $item \n";
        $prevcat = $category;
    }

    $ret || "No stats available yet";
}

1;
