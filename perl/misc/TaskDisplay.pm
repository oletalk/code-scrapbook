package TaskDisplay;

use strict;
use warnings;
use POSIX qw/strftime/;
use Carp;

use constant DAY_SECS => 86400;
use constant SPACER => '   ';
use constant PRE_SPACER => '---- ';

# Date-sensitive display operations -------------
sub display_today {
	my ($tl, $begin, $end, $interval_size) = @_;
	die "This is not a TaskList" unless $tl->isa('TaskList');
	$interval_size ||= 1800; # half an hour

	my $begin_time = $tl->reset_timestamp($begin);
	my $end_time = $tl->reset_timestamp($end);
	croak "Given end time is before given begin time" if $end_time < $begin_time;
	
	# 14 Jul 13:55
	# what to do when tasks overlap?
	
	my %schedule = ();
	my %offsets = ();
	my $col_offset = 1;
	
	my $c = $tl->get_closed_tasks;
	my $ctasks = $tl->get_closed_tasks;
	foreach my $task (keys %$ctasks) {
		my $periods = $tl->get_periods($task);
		foreach my $period (@$periods) {
			my ($pstart, $pend) = @$period;
			# put these on the schedule
			
			$pstart = quantize_diff($begin_time, $pstart, $interval_size);
			$pend   = quantize_diff($begin_time, $pend  , $interval_size);
			
			if (!defined $offsets{$task}) {
				$offsets{$task} = ++$col_offset;
			}
			push @{$schedule{$pstart}}, SPACER x $offsets{$task} . "$task START";
			push @{$schedule{$pend}}, SPACER x $offsets{$task} . "$task END";
		}
	}
	
	my $fmt = $tl->get_short_timestamp_format;
	
	for (my $curr_time = $begin_time; $curr_time < $end_time; $curr_time += $interval_size) {
		
		my $lhs_disp = strftime( $fmt, localtime( $curr_time )) . PRE_SPACER;
		print $lhs_disp;
		my $secondline_spacer = ' ' x length($lhs_disp);
		my $first = 1;
				
		if (defined $schedule{$curr_time}) {
			my @tasks_in_interval = @{$schedule{$curr_time}};	
			foreach my $m (@tasks_in_interval) {
				print $secondline_spacer unless ($first);
				print $m . "\n";
				$first = 0;
			}
		} else {
			print "\n";
		}
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

sub quantize_diff {
	my ($start, $qty, $int_size) = @_;
	
	my $startdiff = $qty - $start;
	$startdiff = int($startdiff / $int_size) * $int_size;
	$startdiff += $start;
	
	$startdiff;
}

1;