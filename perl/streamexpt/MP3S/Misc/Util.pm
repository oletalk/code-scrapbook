package MP3S::Misc::Util;

use warnings;
use Encode;
use POSIX qw/strftime/;

sub filename_only {
	my $str = shift;
	$str =~ s/^.*\///g;
	$str;
}

sub servestream_fmt {
	my ($path, $hostheader) = @_;
	my $ds;
	my $proto = "http";
	if ($hostheader =~ /^([^:]+):(\d+)/) {
		my ($host, $port) = ($1, $2);
		my $slashuri = "/play/$path";
#$slashuri =~ s|/|$QB|g;
		$ds->{'lastconnect'} = -1;
		$ds->{'path'} = $slashuri;
		$ds->{'port'} = $port * 1;
		$ds->{'hostname'} = $host;
		$ds->{'protocol'} = $proto;
		$ds->{'nickname'} = "${proto}://${hostheader}${slashuri}";
	}
	$ds;
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
