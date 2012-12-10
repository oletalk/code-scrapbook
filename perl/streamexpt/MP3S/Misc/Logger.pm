package MP3S::Misc::Logger;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw (log_info log_error log_debug);


use POSIX qw/strftime/;
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

our $logging_level = 3;
our @levels = qw(none FATAL ERROR WARNING INFO DEBUG);
our $st_onerr = 1;
our $display_context = 0;

sub init {
	my (%args) = @_;
	
	if ($args{display_context}) {
		$display_context = 1;
	}
	
	if ($args{level}) {
		my $l = $args{level};
		if ($l >= FATAL && $l <= DEBUG) {
			$logging_level = $l;			
		} else {
			die "Level $l is unsupported";
		}
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

#sub log_info {
#	_log(INFO, @_);
#}

#sub log_error {
#	_log(ERROR, @_);
#}

#sub log_debug {
#	_log(DEBUG, @_);
#}

# reuses Log::Message::Simple, but does a little preprocessing first
sub _log {
	my ($level, $ctxt, @arr) = @_;
	return if $level > $logging_level;
	my @messages = log_prep(@arr);

	my $leveldisp = $levels[$level];
	my $ctxtdisp;
	$ctxtdisp = " ($ctxt)" if $display_context;
	my $tstamp = strftime( "%d-%m-%Y,%H:%M:%S", localtime );
	foreach (@messages) {
		print "${tstamp}${ctxtdisp} [$leveldisp] $_ \n";
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