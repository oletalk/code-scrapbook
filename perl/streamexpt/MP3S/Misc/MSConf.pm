package MP3S::Misc::MSConf;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw (config_value);

use strict;
use Config::General;
use Carp;

our %config;
our $initialised;


sub init {
	my ($config_file) = @_;
	
	my $conf = new Config::General($config_file);
	%config = $conf->getall;
	croak "Unable to get config info from config file $config_file: $!" unless $conf;
	$initialised = 1;
}

sub config_value {
	my ($prop, $verbose) = @_;
	croak "Config was not initialised" unless $initialised;
	print "config_value for $prop is '" . $config{$prop} . "'\n" if $verbose;
	$config{$prop};
}

1;