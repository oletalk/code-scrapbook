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
	my %args = @_;
	my $tl = $args{tasks};
	my $begin = $args{begin};
	my $end = $args{end};
	my $day_offset = $args{day_offset};
	my $collapse = $args{collapse};
	my $show_trails = $args{trails};
	
	die "This is not a TaskList" unless $tl->isa('TaskList');
	my $interval_size = $collapse ? 900: 1800; # half an hour

	my $begin_time = $tl->reset_timestamp($begin, $day_offset);
	my $end_time = $tl->reset_timestamp($end, $day_offset);
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
			$offsets{$task} = 0 if $collapse;
			push @{$schedule{$pstart}}, SPACER x $offsets{$task} . "$task START";
			push @{$schedule{$pend}}, SPACER x $offsets{$task} . "$task END";
		}
	}
	
	my $fmt = $tl->get_short_timestamp_format;
	
	my $num_trails = 0;
	my @trails = ();
	my $rhs_trail = 0;
	
	for (my $curr_time = $begin_time; $curr_time < $end_time; $curr_time += $interval_size) {
		
		my $lhs_disp = strftime( $fmt, localtime( $curr_time )) . PRE_SPACER;
		print $lhs_disp;
		my $secondline_spacer = ' ' x length($lhs_disp);
		my $first = 1;
				
		if (defined $schedule{$curr_time}) {
			my @tasks_in_interval = @{$schedule{$curr_time}};	
			foreach my $m (@tasks_in_interval) {
				print $secondline_spacer unless ($first);
				print replace_spacer_trails($m, \@trails) . "\n";
				$first = 0;
				
				if ($show_trails) {
					my ($spacer, $task, $cmd) = $m =~ /^(\s*)(.*)(START|END)$/;
					#print "SPACER: $spacer, TASK: $task, CMD: $cmd\n";
					my $num = length($spacer);
					if ($cmd eq 'START') {
						$trails[$num] = 1;
						$rhs_trail = $num > $rhs_trail ? $num : $rhs_trail;
						$num_trails++;
					} elsif ($cmd eq 'END') {
						undef $trails[$num];
						$num_trails--;
					}					
				}
			}
		} else {
			if ($num_trails > 0) {
				for (my $i = 0; $i <= $rhs_trail; $i++) {
					print defined $trails[$i] ? '|' : ' ';
				}
			}
			print "\n";
		}
	}
	

	display_open_tasks($tl);
}

sub replace_spacer_trails {
	my ($str, $trailsref) = @_;
	my @trails = @{$trailsref};
	for (my $i = 0; $i < scalar @trails; $i++) {
		if (substr($str, $i, 1) eq ' ' && defined $trails[$i]) {
			substr($str, $i, 1) = '|';
		}
	}
	$str;
}

# Display operations on open tasks --------------------
sub display_open_tasks {
	my ($tl) = @_;
	die "This is not a TaskList" unless $tl->isa('TaskList');
	my $o = $tl->get_open_tasks;
	
	my $ctr = 0;
	foreach my $opentask (sort { $o->{$a} <=> $o->{$b} } keys %$o) {
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