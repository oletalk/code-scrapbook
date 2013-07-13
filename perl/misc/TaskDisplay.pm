package TaskDisplay;

use strict;
use warnings;
use POSIX qw/strftime/;

sub display_open_tasks {
	my ($tl) = @_;
	die "This is not a TaskList" unless $tl->isa('TaskList');
	my $o = $tl->get_open_tasks;
	
	my $ctr = 0;
	foreach my $opentask (keys %$o) {
		next unless defined $o->{$opentask};
		$ctr++;
		print " [$ctr] $opentask: started " . 
			strftime( $tl->get_timestamp_format, localtime ($o->{$opentask}) ) . "\n"; 
	}
	print "NO OPEN TASKS (you sure about that?)\n" if $ctr == 0;
}

sub display_closed_tasks {
	my ($tl, $detailed) = @_;
	die "This is not a TaskList" unless $tl->isa('TaskList');
	my $c = $tl->get_closed_tasks;
	
	foreach my $closedtask (keys %$c) {
		my $tme = hms( $c->{$closedtask} );
		if (!$detailed) {
			print "   $closedtask: elapsed $tme \n";			
		}
	}
}

sub hms {
	my ($secs) = @_;
	my ($mins, $hrs) = (0, 0);
	
	if ($secs >= 60) {
		$mins = int($secs / 60);
		$secs = $secs % 60;
		
		if ($mins >= 60) {
			$hrs = int($mins / 60);
			$mins = $mins % 60;
		}
	}
	my $ret = "$secs sec";
	$ret = "$mins min, $ret" if $mins > 0;
	$ret = "$hrs hr, $ret" if $hrs > 0;
	
	$ret;
}

1;