package MP3S::Misc::Logger;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw (log_info log_error log_debug);

use strict;
use warnings;
use Log::Message::Simple qw(:STD);

our $verbose = 1;
our $debug   = 0;
our $st_onerr = 1;

sub init {
	my (%args) = @_;
	$verbose  = _first_nonempty($args{verbose}, $verbose);
	$debug    = _first_nonempty($args{debug},   $debug);
	$st_onerr = _first_nonempty($args{stacktrace}, $st_onerr);
	
	$Log::Message::Simple::STACKTRACE_ON_ERROR = $st_onerr;
}

sub log_info {
	_log('info', @_);
}

sub log_error {
	_log('error', @_);
}

sub log_debug {
	_log('debug', @_);
}

# reuses Log::Message::Simple, but does a little preprocessing first
sub _log {
	my ($level, @arr) = @_;
	my @messages = log_prep(@arr);
	if ($level eq 'info') {
		msg($_, $verbose) foreach @messages;
	} elsif ($level eq 'debug') {
		debug($_, $debug) foreach @messages;
	} elsif ($level eq 'error') {
		error($_, $verbose) foreach @messages;
	} else {
		warn "Log level $level not supported";
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