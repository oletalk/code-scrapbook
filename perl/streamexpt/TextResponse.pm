package TextResponse;

use strict;
use HTTP::Status;
use HTTP::Response;

use Sys::Hostname;

sub print_list {
	my ($plist, $str_uri) = @_;
	
	my $cont = undef;
	if ($plist->process_playlist($str_uri)) {
		my @list = $plist->list_of_songs_URIs(1);

		my $ret = join("\n", @list);

		if ($ret) {
			my $links = get_links($str_uri);
			$ret = "<h2>Song list</h2> $links $ret";
		} else {
			$ret = "<h3>No results</h3>";		
		}
		$cont = HTTP::Response->new(RC_OK);
		$cont->content( $ret );		
	} else {
		$cont = HTTP::Response->new(RC_NOT_FOUND);
		$cont->content( "No matching results!");
	}
	
	$cont;
}

sub print_playlist {
	my ($plist, $str_uri, $port, $plsname) = @_;
	
	my $cont = HTTP::Response->new(RC_NOT_FOUND);
	if ($plist->process_playlist($str_uri)) {
		my @list = $plist->list_of_songs_URIs;
		my $host = hostname();
		
		my $ret = "";
		foreach my $entry (@list) {
			$ret .= "http://${host}:${port}${entry}\n";
		}
		if ($ret) {
			$cont = HTTP::Response->new(RC_OK);
			$cont->header('Content-type' => 'application/octet-stream');
			$cont->header("Content-Disposition" => "attachment; filename=$plsname");
			$cont->content( $ret );			
		}
	}
	

	$cont;
}

sub get_links {
	my ($str_uri) = @_;
	
	my $playall = $str_uri;
	my $ret = qq~ <a href="/play${str_uri}">Play these songs</a> | <a href="/drop${str_uri}">Download playlist</a><br/>~;
		
	$ret;
}

1;