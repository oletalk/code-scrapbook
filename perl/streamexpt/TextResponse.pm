package TextResponse;

use strict;
use HTTP::Status;
use HTTP::Response;

sub print_list {
	my (@list) = @_;
	
	my $ret = "";
	foreach (@list) {
		$ret .= qq {<a href="$_">$_</a><br/> \n};
	}
	
	if ($ret) {
		$ret = qq{ <h2>Song list</h2> $ret};
	} else {
		$ret = "<h3>No results</h3>";		
	}
	my $cont = HTTP::Response->new(RC_OK);
	$cont->content( $ret );
	
	$cont;
}


1;