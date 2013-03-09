package MP3S::Misc::Logger;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw (log_info log_error log_debug);


use POSIX qw/strftime/;
use Log::LogLite;
use strict;
use Carp;
use warnings;
use constant {
	FATAL => 1,
	ERROR => 2,
	WARNING => 3,
	INFO => 4,
	DEBUG => 5
};

use constant {
	NONE => 0,
	NAME => 1,
	FULL => 2
};

our $logging_level = 3;
our @levels = qw(none FATAL ERROR WARNING INFO DEBUG);
our $st_onerr = 1;
our $display_context = 0;
our $log;

sub init {
	my (%args) = @_;
	
	if ($args{display_context}) {
		$display_context = 1;
	}
		
	if ($args{logfile}) {
		$log = new Log::LogLite( $args{logfile}, $args{level} );
		$log->template('<date><message>');
	}
		
}

sub AUTOLOAD {
	my $sub = our $AUTOLOAD;
	$sub =~ s/.*:://;
	my @lines = @_;
	if ($sub =~ /^log_(\w+)$/) {
		my $level = $1;
		my $ctr = 0;
		my ($c_sub, $c_fil, $c_lne) = (caller 0);
		my $clr = "??";
		if ($c_sub) {
			$clr = "$c_sub:$c_lne";			
		}
		foreach my $ll (@levels) {
			if ($level eq lc($ll)) {
				_log($ctr, $clr, @lines);
			}
			$ctr++;
		}
	} else {
		carp "Logger function $sub not defined!";
	}
}

sub _log {
	my ($level, $ctxt, @arr) = @_;
	my @messages = log_prep(@arr);

	my $leveldisp = $levels[$level];
	my $ctxtdisp = "";
	my $ctxt_name = $ctxt;
	$ctxt_name =~ s/.*:://g if $display_context == NAME;
	$ctxtdisp = " ($ctxt_name)" if $display_context > NONE;
	my $tstamp = strftime( "%d-%m-%Y,%H:%M:%S", localtime );
	foreach my $m (@messages) {
		if ($log) {
			$log->write("${ctxtdisp} [$leveldisp] $m \n", $level);
		} else {
			print "${tstamp}${ctxtdisp} [$leveldisp] $m \n";			
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