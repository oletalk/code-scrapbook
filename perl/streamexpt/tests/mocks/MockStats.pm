package tests::mocks::MockStats;
use Exporter 'import';
use MP3S::Misc::Logger qw(log_info);
@EXPORT_OK = qw (count_stat_n output_stats_n get_uptime_n);

use base MP3S::Misc::Stats;
use strict;

our $starttime;
our $stats;

sub set_starttime {
	$starttime = time;
}

sub output_stats_n {
	"No stats available yet (TEST)";
}

sub get_uptime_n {
	"1 second (TEST)\n";
}

sub count_stat_n {
	my ( $category, $item ) = @_;
	if ( $category && $item ) {
		$stats->{$category}->{$item}++;
	}
}

1;