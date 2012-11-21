package TextResponse;

use strict;
use HTTP::Status;
use HTTP::Response;

sub print_list {
	my ($plist, $str_uri) = @_;
	
	my $cont = undef;
	if ($plist->process_playlist($str_uri)) {
		my @list = $plist->list_of_songs;
		my $rootdir = $plist->get_rootdir;

		my $ret = "";
		foreach my $songpath (@list) {
			my $songuri = $songpath;
			$songuri =~ s/$rootdir//;
			$ret .= qq |<a href="/play/${songuri}">${songpath}</a><br/> \n|;
		}

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

sub get_links {
	my ($str_uri) = @_;
	
	my $playall = $str_uri;
	my $ret = qq~ <a href="/play${str_uri}">Play these songs</a> | <a href="">Download playlist</a><br/>~;
		
	$ret;
}

1;