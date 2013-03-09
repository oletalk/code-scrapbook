package TestingInit;

use MP3S::Misc::Logger qw(log_info);
use MP3S::Misc::MSConf qw(config_value);
use MP3S::DB::Setup;

sub init {
	my (%args) = @_;	
	
	my $config_file = $args{config_file};
	my $initialise_tags = $args{tags};
	
	$config_file ||= "tests/testdata/testing.conf";
	die "Unable to open testing config file: $!" unless -r $config_file;
	MP3S::Misc::MSConf::init($config_file);
	
	# create tags table if requested
	if ($initialise_tags) {
		MP3S::DB::Setup::create_tagstable;
	}
	
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

sub setfakemp3s {
	use MP3::Info;
	my $mp3dir = 'tests/testdata';
	my $mp3 = MP3::Info->new();
	$mp3->title('Foo Track');
	$mp3->artist('Mr Foo');
	$mp3->album('Awesome Album');
	set_mp3tag("$mp3dir/first.mp3", $mp3);

	set_mp3tag ("$mp3dir/second.mp3", "Track Bar", "Mr Foo", "Awesome Album", "2002", "-", "Rock");
	my $t = get_mp3tag("$mp3dir/first.mp3") or die "nothing there";
	use Data::Dumper;
	print Dumper(\$t);
}

1;