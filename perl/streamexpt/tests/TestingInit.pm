package TestingInit;

use MP3S::Misc::Logger qw(log_info);
use MP3S::Misc::MSConf qw(config_value);
use tests::mocks::MockStats;

sub init {
	my (%args) = @_;	
	
	my $config_file = $args{config_file};
	tests::mocks::MockStats::set_starttime();
	
	$config_file ||= "tests/testdata/testing.conf";
	die "Unable to open testing config file: $!" unless -r $config_file;
	MP3S::Misc::MSConf::init($config_file);
	
	die 'Testing config file did not set TESTING variable' unless config_value('TESTING');
	
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
	if ($initialise_tags) { # FIXME: can't create fake mp3s just yet 9/3/2013
		print "- Generating fake ID3 tags\n";
		setfakemp3s();		
	}
}


1;