package MP3S::Misc::Util;

use warnings;
use Encode;

use Time::localtime;

sub unbackslashed {
	my ($title) = @_;
	
	#$title =~ s/\\(\d\d\d)/encode('utf-8', chr(oct($1)))/ge;
	$title =~ s/\\\d\d\d/_/g;
	$title;
}

sub get_hour {
	localtime->hour();
}

1;