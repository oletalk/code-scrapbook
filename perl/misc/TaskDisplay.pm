package TaskDisplay;

use strict;
use warnings;
use POSIX qw/strftime/;

use constant DAY_SECS => 86400;

# Date-sensitive display operations -------------
sub display_today {
	my ($tl, $begin, $end) = @_;
	die "This is not a TaskList" unless $tl->isa('TaskList');



	my $c = $tl->get_closed_tasks;
	my $ctasks = $tl->get_closed_tasks;
	foreach my $task (keys %$ctasks) {

	}
	

	display_open_tasks($tl);
}

# Display operations on open tasks --------------------
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

# Display operations on closed tasks ---------------
sub display_closed_tasks {
	my ($tl, $detailed) = @_;
	die "This is not a TaskList" unless $tl->isa('TaskList');
	my $c = $tl->get_closed_tasks;
	
	foreach my $closedtask (keys %$c) {
		my $tme = hms( $c->{$closedtask} );
		print "   $closedtask: elapsed $tme \n";			
	}
}

sub display_all_task_details {
	my ($tl) = @_;
	die "This is not a TaskList" unless $tl->isa('TaskList');
	
	my $ctasks = $tl->get_closed_tasks;
	foreach my $task (keys %$ctasks) {
		display_task_details ($tl, $task);
	}
}

sub display_task_details {
	my ($tl, $task) = @_;
	die "This is not a TaskList" unless $tl->isa('TaskList');
	
	my $periods = $tl->get_periods($task);
	
	if ($periods) {
		print " --  $task: \n";
		my $fmt = $tl->get_timestamp_format;
		my $s_fmt = $tl->get_short_timestamp_format;
		
		foreach my $period (@$periods) {
			my ($pstart, $pend) = @$period;
			my $plen = $pend - $pstart;
			my $disp_fmt = $plen > DAY_SECS ? $fmt : $s_fmt;
			$pstart = strftime( $disp_fmt, localtime($pstart));
			$pend   = strftime( $disp_fmt, localtime($pend));
			$plen   = hms($plen);
			print "Period: $pstart - $pend ($plen)\n";
		}
	} else {
		print "No details found - do 'log times' to ensure this task has been closed\n";
	}
	
}

# Utilities ------------

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
	my $ret = "${secs}s";
	$ret = "${mins}m $ret" if $mins > 0;
	$ret = "${hrs}h $ret" if $hrs > 0;
	
	$ret;
}

1;