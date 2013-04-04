package MP3S::Server;

use strict;
use MP3S::Net::Screener;
use MP3S::Misc::MSConf qw(config_value);
use MP3S::Misc::Logger qw(log_info log_debug log_error);
use MP3S::Handlers::CmdSwitch;
use MP3S::Music::Playlist;
use HTTP::Status;
use MP3S::DB::Setup;


sub new {
    my $class = shift;
    my %args  = (@_);

    my %content = ();

    __init($args{reuse_stats});

    # setup components
    __transfer_args( \%args, \%content, qw(downsample playlist rootdir) );

    my $rootdir = $args{rootdir};
    $rootdir = "${rootdir}/" unless $rootdir =~ /\/$/;
    $content{rootdir} = $rootdir;

    my $cl = MP3S::Net::Screener->new( ipfile => $args{ipfile} );
    if ( config_value('screenerdefault') ) {
        $cl->set_default_action(config_value('screenerdefault'));
    }

    $content{'screener'} = $cl;

    bless \%content, $class;
}

sub reload {
	my $self = shift;
	my %args = (@_);
	
	# reload by arguments
	if ($args{ipfile}) {
		$self->{'screener'}->reload;
	}
	
	
}

sub is_downsampling {
    my $self = shift;
    $self->{'downsample'};
}

sub playlist {
    my $self = shift;
    $self->{'plist'};
}

sub setup_playlist {
    my $self = shift;
    $self->{downsample} ||= config_value('downsample');
    log_info("Downsampling is ON.\n") if $self->is_downsampling;

    $self->_set_playlist(
        MP3S::Music::Playlist->new(
            playlist => $self->{playlist},
            rootdir  => $self->{rootdir}
        )
    );    # rootdir overrides playlist

    # get the tags in now
    $self->playlist->generate_tag_info();

    $self->{gen_time} = time;

    # if rootdir, how often will it check for new files?
    # regenplaylist option in config file TODO
    my $regen = config_value('regenplaylist');
    if ( $regen > 0 ) {
        if ( defined $self->{rootdir} ) {
            log_info("Playlist will regenerate every $regen minutes.");
        }
        else {
            $regen = 0;
            log_error(
                "Ignoring 'regenplaylist' since a fixed playlist was provided."
            );
        }
    }
    $self->{regen} = $regen;

}

sub process {
    my $self = shift;
    my ( $conn, $port ) = @_;

    my $child;

    my $cl         = $self->{'screener'};
    my $downsample = $self->is_downsampling;

    # who connected?
    my $peer       = $conn->peerhost;
    my $action_ref = $cl->screen($peer);
    my ( $action, @screener_options ) = @$action_ref;
    log_info("Got options @screener_options") if scalar @screener_options;

    if ( $action eq MP3S::Net::Screener::ALLOW ) {

        my $downsample_client = $downsample;

        foreach my $screener_opt (@screener_options) {

            # override global downsampling on a per-client basis
            #obviously if you include them both the last one wins!
            if ( $screener_opt eq MP3S::Net::Screener::NO_DOWNSAMPLE ) {
                $downsample_client = 0;
            }
            if ( $screener_opt eq MP3S::Net::Screener::DOWNSAMPLE ) {
                $downsample_client = 1;
            }
        }

        # perform the fork or exit
        die "Can't fork: $!" unless defined( $child = fork() );
        if ( $child == 0 ) {
            eval {
                MP3S::Handlers::CmdSwitch::handle(
                    connection => $conn,
                    playlist   => $self->playlist,
                    random     => $self->{random},
                    downsample => $downsample_client,
                    port       => $port,
                );
            };
            if ($@) {

                #$had_errors = 1;
                log_error("Problems handling request: $@");
            }

            #if the child returns, then just exit;
            exit 0;
        }
        else {
          #close the connection, the parent has already passed it off to a child
            $conn->close();
        }
    }
    elsif ( $action eq MP3S::Net::Screener::DENY ) {
        $conn->send_error(RC_FORBIDDEN);
        $conn->close();
    }
    else {    # BLOCK
        $conn->close();
    }

    # check if we were asked to regenerate the playlist
    if ( defined $self->{rootdir} && $self->{regen} > 0 ) {
        my $rootdir = $self->{rootdir};
        my $elapsed = time - $self->{gen_time};
        if ( $elapsed > ( $self->{regen} * 60 ) ) {
            my $newcount = $self->playlist->is_stale();
            if ($newcount) {
                log_info("Re-generating playlist from rootdir $rootdir");

                $self->_set_playlist(
                    MP3S::Music::Playlist->new(
                        playlist   => $self->{playlist},
                        rootdir    => $rootdir,
                        gen_reason => "$newcount new songs found",
                    )
                );    # rootdir overrides playlist
                $self->playlist->generate_tag_info();

            }
            else {
                log_info("Re-gen time passed but no new files encountered");
            }
            $self->{gen_time} = time;

        }
    }

    #go back and listen for the next connection

}


sub _set_playlist {
    my $self = shift;
    my ($plist) = @_;
    $self->{'plist'} = $plist;
}

sub __init {
	my ($reuse_stats) = @_;
	if (config_value('TESTING')) {
		log_info('database init not being called - Testing');
	} else {
	    # initialise database/stats
		if ($reuse_stats) {
			log_info('Requested NOT to drop and re-create stats table.');
		}
	    MP3S::DB::Setup::init($reuse_stats);		
	}
}

sub __transfer_args {
    my ( $from_ref, $to_ref, @args ) = @_;
    foreach my $arg (@args) {
        $to_ref->{$arg} = $from_ref->{$arg};
    }
}


1;
