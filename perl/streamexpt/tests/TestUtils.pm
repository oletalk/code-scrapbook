package TestUtils;

use LWP::Simple;

sub getlocal {
	my ($port, $uri) = @_;
	# example '/list/first.mp3'
	return get("http://localhost:$port$uri");
}

sub getlinks {
	my ($string) = @_;
	my @matches = $string =~ /href=\"([^"]*)\"/g;
	@matches;
}

sub compare_result {
	my ($actual, $resultfile) = @_;
	die "Problem accessing resultfile: $!" unless -r $resultfile;
	open my $fh, $resultfile or die "Problem accessing resultfile: $!";
	local $/;
	my $expected = <$fh>;
	close $fh;
	warn "EXPECTED:\n$expected\nACTUAL:\n$actual\n" unless $expected eq $actual;
	$expected eq $actual;
}

# LINE: <h2>Song list</h2>  <a href="/play">Play these songs</a> | <a href="/drop">Download playlist</a><br/> first.mp3 <a href="/play/first.mp3">D</a><br/>  
# LINE:  
# LINE: second.mp3 <a href="/play/second.mp3">D</a><br/>  
# LINE:  
# LINE: third.mp3 <a href="/play/third.mp3">D</a><br/>  
# LINE: <p><em>Generated: Sun 10 Mar 2013,19:11 (reason: No particular reason ) </em></p> 

1;