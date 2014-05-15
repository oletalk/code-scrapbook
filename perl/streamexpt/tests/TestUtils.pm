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
	if ( $expected ne $actual ) {
		warn "EXPECTED:\n$expected\nACTUAL:\n$actual\n";
		for my $i (0 .. length($expected)) {
			my $exp_char = substr($expected, $i, 1);
			my $act_char = substr($actual, $i, 1);
			if ($exp_char ne $act_char) {
				my $exp_ctx = substr($expected, $i-2, 5);
				my $act_ctx = substr($actual, $i-2, 5);
				$exp_ctx =~ s/\n//g;
				$act_ctx =~ s/\n//g;
				print "First difference is at: [$exp_ctx] vs [$act_ctx] (char $i)\n";
				print "                           ^         ^\n";
				last;
			}
		}		
	}
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