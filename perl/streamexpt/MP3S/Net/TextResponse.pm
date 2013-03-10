package MP3S::Net::TextResponse;

use strict;
use HTTP::Status;
use HTTP::Response;
use URI::Escape;
use Sys::Hostname;
use MP3S::Misc::MSConf qw(config_value);

sub print_list {
	my ($plist, $str_uri) = @_;
	
	my $cont = undef;
	if ($plist->process_playlist($str_uri)) {
		my @list = $plist->list_of_songs_URIs(1);

		my $ret = join("\n", @list);

		if ($ret) {
			my $links = get_links($str_uri);
			$ret = "<h2>Song list</h2> $links $ret";
			my $reason = $plist->gen_reason;
			$reason = " (reason: $reason )" if $reason;
			$ret .= "<p><em>Generated: " . $plist->gen_date . "$reason </em></p>";
		} else {
			$ret = "<h3>No results</h3>";		
		}
		$cont = HTTP::Response->new(RC_OK);
		$cont->header('Content-type' => 'text/html; charset=utf-8');
		$cont->content( $ret );		
	} else {
		$cont = HTTP::Response->new(RC_NOT_FOUND);
		$cont->content( "No matching results!");
	}
	
	$cont;
}

sub print_playlist {
	my ($plist, $str_uri, $port) = @_;
	
	my $plsname = $plist->reckon_m3u_name;
	my $cont = HTTP::Response->new(RC_NOT_FOUND);
	if ($plist->process_playlist($str_uri)) {
		my $ret = get_m3u($plist, $port);
		if ($ret) {
			$cont = HTTP::Response->new(RC_OK);
			$cont->header('Content-type' => 'application/octet-stream; charset=utf8');
			$cont->header("Content-Disposition" => "attachment; filename=$plsname");
			$cont->content( $ret );			
		}
	}
	

	$cont;
}

sub print_stats {
	my ($uri) = @_;
	my $ret = "";
	
	if (config_value('TESTING')) {
		use tests::mocks::MockStats qw(output_stats_n get_uptime_n);
		$ret .= "<pre>" . output_stats_n($uri) . "</pre>";
		$ret .= "<b>Uptime:</b> " . get_uptime_n();
		
	} else {
		use MP3S::Misc::Stats qw(output_stats get_uptime);		
		$ret .= "<pre>" . output_stats($uri) . "</pre>";
		$ret .= "<b>Uptime:</b> " . get_uptime();
		
	}
	
	
	
	my $cont = HTTP::Response->new(RC_OK);
	$cont->header('Content-type' => 'text/html; charset=utf-8');
	$cont->content( $ret );		

	$cont;
}

sub get_m3u {
	my ($plist, $port) = @_;
	my $ret = "";
	
	my @list = $plist->list_of_songs;
	my $host = hostname();
	
	$plist->generate_tag_info;  # CM FIXME this takes really long (minutes) for reasonably large playlist
	
	foreach my $song_obj (@list) {
		my $songURI = $song_obj->get_URI(playlink => 1);
		
		my $safe_entry = uri_escape($songURI, "^A-Za-z0-9\/\.");
		#print "REFERENCE: " . ref($song_obj);
		my ($tn, $ts) = $plist->get_trackinfo($song_obj);
		my $songline = "";
		if ($tn) {
			my $secs = $ts;
			my $tags = "$tn" || $song_obj->get_filename;
			my $m3uinf = "#EXTINF:${secs},${tags}";
			
			$songline .= "${m3uinf}\n";				
		}
		$songline .= "http://${host}:${port}${safe_entry}\n";
		
		$ret .= $songline;
	}
	$ret = "#EXTM3U\n${ret}" if $ret; # the M3U file header
	
	$ret;
}

sub get_links {
	my ($str_uri) = @_;
	
	my $playall = $str_uri;
	my $ret = qq~ <a href="/play${str_uri}">Play these songs</a> | <a href="/drop${str_uri}">Download playlist</a><br/>~;
		
	$ret;
}

1;