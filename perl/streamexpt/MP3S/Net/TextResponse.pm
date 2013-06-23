package MP3S::Net::TextResponse;

use strict;
use HTTP::Status;
use HTTP::Response;
use HTML::Template;

use URI::Escape;
use Sys::Hostname;
use MP3S::Misc::MSConf qw(config_value);

sub print_list {
	my ($plist, $str_uri) = @_;
	
	my $cont = undef;
	if ($plist->process_playlist($str_uri)) {
		my @list = $plist->list_of_songs_URIs(1);

		my ($reason, $date);
		if (@list) {
			$reason = $plist->gen_reason;
			$date = $plist->gen_date;
		}

		my $template = HTML::Template->new(filename => 'templates/song-list.tmpl');
		$template->param(URI => $str_uri);
		$template->param(SONGS_URIS => \@list);
		$template->param(GENDATE => $date);
		$template->param(REASON => $reason);
		
		$cont = HTTP::Response->new(RC_OK);
		$cont->header('Content-type' => 'text/html; charset=utf-8');
		$cont->content( $template->output );		
	} else {
		$cont = HTTP::Response->new(RC_NOT_FOUND);
		$cont->content( "No matching results!");
	}
	
	$cont;
}

sub print_latest {
	my ($plist, $str_uri) = @_;
	my ($days) = $str_uri =~ /(\d+)/;
	$days ||= 7;
	
	my $cont = undef;
	if ($plist->process_playlist('/')) {
		my @latest = ();
		my $cutoff = time - (86400 * $days);
		foreach my $song ($plist->list_of_songs) {
			if ($song->get_modified_time > $cutoff) {
				push @latest, { 'TITLE' => $song->get_URI( hyperlinked => 1 ) , 'URI' => $song->get_URI() };
			}
		}
		
		my $template = HTML::Template->new(filename => 'templates/song-latest.tmpl');
		$template->param(SONGS_URIS => \@latest);
		$template->param(DAYS => $days);

		$cont = HTTP::Response->new(RC_OK);
		$cont->header('Content-type' => 'text/html; charset=utf-8');
		$cont->content( $template->output );
		
	} else {
		$cont = HTTP::Response->new(RC_NOT_FOUND);
		$cont->content( "No matching results!");	
	}
	$cont;
}

sub print_playlist {
	my ($plist, $str_uri, $headerhost) = @_;
	
	my $plsname = $plist->reckon_m3u_name;
	my $cont = HTTP::Response->new(RC_NOT_FOUND);
	if ($plist->process_playlist($str_uri)) {
		my $ret = get_m3u($plist, $headerhost);
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
	
	my $template = HTML::Template->new(filename => 'templates/stats.tmpl');
	
	if (config_value('TESTING')) {
		use tests::mocks::MockStats qw(output_stats_n get_uptime_n);
		$template->param(STATS => output_stats_n($uri));
		$template->param(UPTIME => get_uptime_n());
		
	} else {
		use MP3S::Misc::Stats qw(output_stats get_uptime);		
		$template->param(STATS => output_stats($uri));
		$template->param(UPTIME => get_uptime());		
	}
		
	my $cont = HTTP::Response->new(RC_OK);
	$cont->header('Content-type' => 'text/html; charset=utf-8');
	$cont->content( $template->output );		

	$cont;
}

sub get_m3u {
	my ($plist, $headerhost) = @_;
	my $ret = "";
	
	my @list = $plist->list_of_songs;
	
	$plist->generate_tag_info;  # CM FIXME this takes really long (minutes) for reasonably large playlist
	
	my $template = HTML::Template->new(filename => 'templates/get-m3u.tmpl');
	
	my @m3ulist = ();
	foreach my $song_obj (@list) {
		my $songURI = $song_obj->get_URI(playlink => 1);
		
		my $safe_entry = uri_escape($songURI, "^A-Za-z0-9\/\.");
		#print "REFERENCE: " . ref($song_obj);
		my ($tn, $ts) = $plist->get_trackinfo($song_obj);

		my %objhash = ();
		if ($tn) {
			$objhash{SECS} = $ts;
			$objhash{TAGS} = "$tn" || $song_obj->get_filename;
		}
		$objhash{SONGURL} = "http://${headerhost}${safe_entry}\n";
		push @m3ulist, \%objhash;
		
	}
	$template->param(SONGS => \@m3ulist);
	
	$template->output;
}

1;