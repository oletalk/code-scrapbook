package tests::mocks::MockStats;
use Exporter 'import';
use MP3S::Misc::Logger qw(log_info);
@EXPORT_OK = qw (count_stat_n output_stats get_uptime);

use base MP3S::Misc::Stats;
use strict;

our $starttime;
our $stats;

sub set_starttime {
	$starttime = time;
}

sub count_stat_n {
	my ( $category, $item ) = @_;
	if ( $category && $item ) {
		$stats->{$category}->{$item}++;
	}
}

sub _get_db_time {
	time - $starttime;
}

sub _get_db_category_stats {
	my ($specif) = @_;
	my $result;
	foreach my $category (sort keys %$stats) {
		next if ($specif && $category ne $specif);
		
		foreach my $item (sort keys %$category) {
			push @$result, [ $category, $item, $stats->{$category}->{$item}];
		}
	}
	
	$result;
}

1;