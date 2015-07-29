package MP3S::Net::TextResponse;

use strict;
use HTTP::Status;
use HTTP::Response;
use HTML::Template;

use URI::Escape;
use Sys::Hostname;
use MP3S::Misc::MSConf qw(config_value);
use MP3S::Misc::Logger qw(log_info log_error);

sub print_list {
	my ($plist, $str_uri, $new_template) = @_;
	
	my $cont = undef;
	if ($plist->process_playlist($str_uri)) {
		my @list = $plist->list_of_songs_URIs(1);

		my ($reason, $date);
		if (@list) {
			$reason = $plist->gen_reason;
			$date = $plist->gen_date;
		}

		my $fnm = $new_template ? $new_template : 'templates/song-list.tmpl';
		my $template = HTML::Template->new(filename => $fnm );
		unless ($new_template) {
			$template->param(URI => $str_uri);
			$template->param(GENDATE => $date);
			$template->param(REASON => $reason);
		}
		$template->param(SONGS_URIS => \@list);
		
		$cont = HTTP::Response->new(RC_OK);
		$cont->header('Content-type' => 'text/html; charset=utf-8');
		$cont->content( $template->output );		
	} else {
		$cont = HTTP::Response->new(RC_NOT_FOUND);
		$cont->content( "No matching results!");
	}
	
	$cont;
}

sub print_ssjson {
	my ($plist, $str_uri, $headerhost) = @_;

	use JSON;  # TODO: put this away somewhere
	my $cont = undef;
	if ($plist->process_playlist($str_uri)) {
		my @list = $plist->list_of_songs_URIs(1);

		my $hash;
		$cont = HTTP::Response->new(RC_OK);
		$cont->header('Content-type' => 'text/plain; charset=utf-8');
		my $wrapper;
		foreach my $song (@list) {
			my $j = MP3S::Misc::Util::servestream_fmt($song->{'URI'}, $headerhost);
			push @{$wrapper->{'backup'}{'uri'}}, $j;
		}
		$cont->content( to_json($wrapper, { escape_slash => 1 }) );
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

sub get_stored_playlist {
  my ($plist, $uri, $headerhost) = @_;
  # the rest of the url should just be a playlist name - alphanumeric/spaces
  my $stored_pls_name = $uri;
  $stored_pls_name =~ s/\///;
   
  my $cont = undef; 
  # we don't have objects for 'adhoc' playlists - we go to the database for these
  use MP3S::Handlers::AdhocSQL;

  if ($plist->process_playlist('/')) {
    my $res = MP3S::Handlers::AdhocSQL::fetch_playlist($stored_pls_name);
    if ($res && scalar @{$res}) {
      my $m3u = get_adhoc_m3u($plist, $res, $headerhost);
      $cont = HTTP::Response->new(RC_OK);
      $cont->header('Content-type' => 'text/plain; charset=utf-8');
      $cont->content( $m3u );
    } else {
      $cont = HTTP::Response->new(RC_NOT_FOUND);
      $cont->content( "No matching results!");
    }
  }
#        t.song_filepath, t.artist, t.title, t.secs, s.song_order
  $cont;
}

sub print_adhoc_playlist {
	my ($urislist_ref, $headerhost) = @_;

	my $ret = "";
	my $plsname = "genplaylist.m3u";
	my $cont = HTTP::Response->new(RC_NOT_FOUND);
	foreach my $uri (@{$urislist_ref}) {
		$ret = "#EXTM3U\n" unless $ret;
		$ret .= "#EXTINF:-1,none\n"; #FIXME
		$ret .= "http://${headerhost}${uri}\n";

	}
	if ($ret) {
		$cont = HTTP::Response->new(RC_OK);
		$cont->header('Content-type' => 'application/octet-stream; charset=utf8');
		$cont->header("Content-Disposition" => "attachment; filename=$plsname");
		$cont->content( $ret );			
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

sub get_adhoc_m3u {
  my ($plist, $adhoc_result_ref, $headerhost) = @_;

  my $template = HTML::Template->new(filename => 'templates/get-m3u.tmpl');
  my @m3ulist = ();

  log_info("Playlist appears to be of size " . scalar @{$adhoc_result_ref} . ".");
  foreach my $row (@$adhoc_result_ref) {
#        t.song_filepath, t.artist, t.title, t.secs, s.song_order
    my %objhash = ();
    my ($song_filepath, $artist, $title, $secs, $song_order) = @$row;
    my $uri = $plist->reckon_URI_from_path($song_filepath);

    my $safe_entry = uri_escape($uri, "^A-Za-z0-9\/\.");
    $objhash{SONGURL} = "http://${headerhost}/play/${safe_entry}\n";

    if (defined $safe_entry) {
      push @m3ulist, \%objhash;
    } else {
      log_error("Skipping song $song_filepath - not found in current playlist :-(");
    }
  }

  $template->param(SONGS => \@m3ulist);

  $template->output;
}

1;
