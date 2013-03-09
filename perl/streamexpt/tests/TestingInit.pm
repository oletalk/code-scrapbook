package TestingInit;

use MP3S::Misc::Logger qw(log_info);
use MP3S::Misc::MSConf qw(config_value);

sub init {
	my ($config_file) = @_;	
	
	$config_file ||= "tests/testdata/testing.conf";
	die "Unable to open testing config file: $!" unless -r $config_file;
	MP3S::Misc::MSConf::init($config_file);
	
	# erase the old logfile if it's there
	my $logfile_location = config_value('logfile');
	#if (-r $logfile_location) {
	#	system(rm -f $logfile_location);
	#}
	
	MP3S::Misc::Logger::init(
	    level           => MP3S::Misc::Logger::DEBUG,
		logfile			=> $logfile_location,
	    display_context => MP3S::Misc::Logger::NAME
	);
}

1;