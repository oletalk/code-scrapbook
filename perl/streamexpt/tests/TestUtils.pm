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

sub logfile_result {
	my ($logfile) = @_;
	_slurp_file($logfile);
}

sub compare_result {
	my ($actual, $resultfile) = @_;
	my $expected = _slurp_file($resultfile);
	warn "EXPECTED:\n$expected\nACTUAL:\n$actual\n" unless $expected eq $actual;
	$expected eq $actual;
}

sub _slurp_file {
	my ($filename) = @_;
	die "Problem accessing file: $!" unless -r $filename;
	open my $fh, $filename or die "Problem accessing file: $!";
	local $/;
	my $ret = <$fh>;
	close $fh;
	$ret;
}

# LINE: <h2>Song list</h2>  <a href="/play">Play these songs</a> | <a href="/drop">Download playlist</a><br/> first.mp3 <a href="/play/first.mp3">D</a><br/>  
# LINE:  
# LINE: second.mp3 <a href="/play/second.mp3">D</a><br/>  
# LINE:  
# LINE: third.mp3 <a href="/play/third.mp3">D</a><br/>  
# LINE: <p><em>Generated: Sun 10 Mar 2013,19:11 (reason: No particular reason ) </em></p> 

1;