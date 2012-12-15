package MP3S::Misc::Util;

use warnings;
use Encode;

sub unbackslashed {
	my ($title) = @_;
	
	#$title =~ s/\\(\d\d\d)/encode('utf-8', chr(oct($1)))/ge;
	$title =~ s/\\\d\d\d/_/g;
	$title;
}

1;