package MP3S::Misc::Logger;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw (log_info log_error log_debug);


use POSIX qw/strftime/;
use Log::Log4perl;
use Log::Log4perl::Level;
use strict;
use Carp;
use warnings;
use constant {
	FATAL => $FATAL,
	ERROR => $ERROR,
	WARNING => $WARN,
	INFO => $INFO,
	DEBUG => $DEBUG
};

use constant {
	NONE => 0,
	NAME => 1,
	FULL => 2
};

our $logging_level = 3;
our @levels = qw(none FATAL ERROR WARNING INFO DEBUG);
our %LOG_LEVELS = ( none => $TRACE, 
					debug => $DEBUG,
					info => $INFO,
					warning => $WARN,
					error => $ERROR,
					fatal => $FATAL);
our $st_onerr = 1;
our $display_context = 0;
our $log;

sub init {
	my (%args) = @_;
	
	if ($args{display_context}) {
		$display_context = 1;
	}
		
	if ($args{logconf}) {
		my $logconffile = $args{logconf};
		if (-r $logconffile) {
			Log::Log4perl->init( $logconffile );			
		} else {
			die "Couldn't find logconf at $logconffile";
		}
	}
	elsif (defined $args{logfile} && defined $args{level}) {
		Log::Log4perl->init(\ qq|
			log4perl.category.MP3.Server = $args{level}, Logfile
			
			log4perl.appender.Logfile  = Log::Log4perl::Appender::File
			log4perl.appender.Logfile.filename = $args{logfile}
			log4perl.appender.Logfile.layout = Log::Log4perl::Layout::PatternLayout
			log4perl.appender.Logfile.layout.ConversionPattern = %d{dd/MM/yyyy HH:mm:ss} [%p]%m%n
		|);
		#$log = new Log::LogLite( $args{logfile}, $args{level} );
		die "log wasn't initialised properly" unless Log::Log4perl->initialized();
	} else {
		die "Can't initialise logging without logconf or logfile";
	}
	$logging_level = $args{level}; # for print-based logging
		
}

sub AUTOLOAD {
	my $sub = our $AUTOLOAD;
	$sub =~ s/.*:://;
	my @lines = @_;
	if ($sub =~ /^log_(\w+)$/) {
		my $level = $1;
		my ($c_sub, $c_fil, $c_lne) = (caller 0);
		my $clr = "??";
		if ($c_sub) {
			$clr = "$c_sub:$c_lne";			
		}
		
		my $ctr = $LOG_LEVELS{lc $level};
		if (defined $ctr) {
			_log($ctr, $clr, @lines);
		} else {
			carp "Logger function $sub not defined!";
		}
	} else {
		carp "Logger function $sub not defined!";
	}
}

sub _log {
	my ($level, $ctxt, @arr) = @_;
	my @messages = log_prep(@arr);

	my $ctxtdisp = "";
	my $ctxt_name = $ctxt;
	$ctxt_name =~ s/.*:://g if $display_context == NAME;
	$ctxtdisp = " ($ctxt_name)" if $display_context > NONE;
	my $tstamp = strftime( "%d-%m-%Y,%H:%M:%S", localtime );
	$log = Log::Log4perl::get_logger("MP3::Server");
	foreach my $m (@messages) {
		if ($log) {
			$log->log( $level, "${ctxtdisp} $m \n");
		} else {
			if ($level <= $logging_level) {
				print "${tstamp}${ctxtdisp} $m \n";				
			}
		}
	}
}

sub log_prep {
	my (@arr) = @_;
	my @ret = ();
	foreach my $elem (@arr) {
		my $el = $elem;
		chomp $el;
		push @ret, $el;
	}
	@ret;
}


sub _first_nonempty {
	my @list = @_;
	
	my $ret;
	foreach (@list) {
		$ret ||= $_;
	}
	$ret;
}

1;