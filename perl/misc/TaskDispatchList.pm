package TaskDispatchList;

use strict;
use vars qw( $quiet );

#contains all of the function definitions for the 'log' tool

sub commands {

    # Guide:
    # 'foo' => [ sub { do stuff }, 'Do foo task', 'foo \'desired args\'' ],
    #  The 3rd list item is a sample call for your task type and is optional.

    my %commands = (
		'reopen' => [
			sub {
				my ( $list, $task, $options ) = @_;
				my $task_descr;
				if ( $task_descr = $list->reopen_closed_task( $task, $options->[0] ) ) {
					$list->do_pending_writes;
					print "OK, reopened task '$task_descr'.\n" unless $quiet;
					return 1;
				}
				else {
					print $list->error_message;
					return 0;
				}
			},
			'Shortcut to reopen a closed task',
			'reopen <X> [<HH:MM>]'
		],
        'start' => [
            sub {
                my ( $list, $task, $options ) = @_;
                if ( $list->open_task( $task, $options->[0] ) ) {
                    $list->do_pending_writes;
                    print "OK, task started.\n" unless $quiet;
					return 1;
                }
                else {
                    print $list->error_message;
					return 0;
                }
            },
            'Start a new task',
            'start \'task description\' [<HH:MM>]'
        ],

        'stop' => [
            sub {
                my ( $list, $task, $options ) = @_;
                if ( $list->close_task( $task, $options->[0] ) ) {
                    $list->do_pending_writes;
                    print "OK, task stopped.\n" unless $quiet;

					# and, we assume the user is always busy,
					# so if no tasks are 'open', ask if the user wants to
					# reopen a previously closed task.
					my $tasks_open = $list->number_of_open_tasks;
					$list->read_activities_file;  # refresh ourselves
					if ( $list->number_of_open_tasks < 1 && !$quiet) {
						print "You now have no open tasks.\nUse 'log reopen <number from 'log times' list>' if you wish to reopen a task.\n"
					}
					return 1;
                }
                else {
                    print $list->error_message;
					return 0;
                }
            },
            'Stops a task in progress',
            'stop \'task description\'  [<HH:MM>]'
        ],

        'status' => [
            sub {
                my ($list) = @_;
                TaskDisplay::display_open_tasks($list);
            },
            'Lists tasks in progress'
        ],

        'times' => [
            sub {
                my ($list) = @_;
                TaskDisplay::display_closed_tasks($list);
            },
            'Shows elapsed times for stopped tasks'
        ],

        'details' => [
            sub {
                my ( $list, $task ) = @_;
                if ( defined $task ) {
                    TaskDisplay::display_task_details( $list, $task );
                }
                else {
                    TaskDisplay::display_all_task_details($list);
                }
            },
            'Shows details on elapsed times for task',
            'details \'task description\''
        ],

        'today' => [
            sub {
                my ( $list, $task, $options ) = @_;
                push @$options, $task;
                my %opts = map { $_ => 1 } @$options;
                TaskDisplay::display_today(
                    tasks    => $list,
                    begin    => '08:00',
                    end      => '18:00',
                    collapse => defined $opts{flat},
                    trails   => defined $opts{trails}
                );
            },
            'Shows calendar-style view of today\'s tasks',
            'today [flat] [trails]'
        ],

        'back' => [
            sub {
                my ( $list, $task, $options ) = @_;

                #push @options, $task;
                #my %opts = map { $_ => 1 } @options;
                TaskDisplay::display_today(
                    tasks      => $list,
                    begin      => '08:00',
                    end        => '18:00',
                    day_offset => $task
                );
            },
            'Shows calendar-style view for tasks X days ago',
            'back <X=1 to 7>'
        ],

        'quit' => [
            sub {
                my ( $list, $task, $options ) = @_;
                my $size = $list->number_of_open_tasks;
                if ( $size > 0 ) {
                    my $descr = $size == 1 ? 'this task' : 'these tasks';
					if (!$quiet) {
	                    TaskDisplay::display_open_tasks($list);
	                    print
						"If you REALLY want to close $descr, hit Enter; otherwise hit Ctrl-C now!\n";
	                    my $dummy = <STDIN>;
						
					}
                    $list->close_all_tasks;
                    $list->do_pending_writes;
                    print "OK, closed $descr.\n" unless $quiet;
                }
                else {
                    print "No open tasks at this time.\n";
                }
            },
            'Close ALL currently open tasks'
        ],

		'clear' => [
			sub {
				my ( $list ) = @_;

				print "This will back up the current activities list, then clear it.\n";
				print "If this is fine, hit Enter; otherwise hit Ctrl-C now!\n";
				my $dummy = <STDIN>;
				$list->close_all_tasks;
				$list->do_pending_writes;
				$list->backup_and_clear_file;
				print "OK, your activities file is now empty.\n" unless $quiet
			},
			'Archive activities file'
		]
    );

    #aliases
    $commands{'begin'} = $commands{'start'};
    $commands{'end'}   = $commands{'stop'};
    $commands{'list'}  = $commands{'status'};

    return \%commands;
}

sub usage {
    my $cmds = commands();
    print "Usage: log.pl <command> <options>\n";
    foreach my $cmd (qw(start stop reopen status times details today back quit clear)) {
        my $description = $cmds->{$cmd}[2] || $cmd;
        printf( "     %-35s - %-45s\n", $description, $cmds->{$cmd}[1] );
    }
    print "Aliases: 'begin' = start, 'end' = stop, 'list' = status\n";

}

1;
