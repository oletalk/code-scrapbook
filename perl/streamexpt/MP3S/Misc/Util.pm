package MP3S::Misc::Util;

use warnings;
use Encode;
use POSIX qw/strftime/;

sub filename_only {
	my $str = shift;
	$str =~ s/^.*\///g;
	$str;
}

sub format_datetime {
	my ($format, $timesecs) = @_;
	# note: using Time::localtime breaks this - use CORE::localtime only
	strftime( $format, localtime($timesecs) );
}

sub get_hour {
	strftime( '%H', localtime() );
}

1;