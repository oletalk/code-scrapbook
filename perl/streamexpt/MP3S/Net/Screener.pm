package MP3S::Net::Screener;

use strict;
use Carp;

use MP3S::Misc::Logger qw(log_info log_debug log_error);
use MP3S::Misc::MSConf qw(config_value);

use NetAddr::IP;
use constant ALLOW => 'ALLOW';
use constant DENY  => 'DENY';
use constant BLOCK => 'BLOCK';

use constant DOWNSAMPLE => 'DOWNSAMPLE';
use constant NO_DOWNSAMPLE => 'NO_DOWNSAMPLE';

sub new {
	my $class = shift;
	bless { 'default_action' => ALLOW, 
				@_ }, $class;
}

sub get_default_action {
	my $self = shift;
	$self->{'default_action'};
}

sub set_default_action {
	my $self = shift;
	my ($action) = @_;
	$self->{'default_action'} = $action;
	log_info( "Screener's default action has just been set to $action" );
}

sub reload {
	my $self = shift;
	log_info( "Reloading screener." );
	$self->read_client_list($self->{'ipfile'});
}

sub screen {
	my $self = shift;
	my ($ip_string) = @_;

	my $ret = [ $self->get_default_action ];
	
	if (!$self->{'clientlist'} && $self->{'ipfile'}) {
		log_info( "client_screen without read_client_list called ... doing that now\n" );
		$self->read_client_list($self->{'ipfile'});
	}
	
	if ($self->{'clientlist'}) {
		my $ip = NetAddr::IP->new($ip_string);
		if ($ip) {
			foreach my $actionbl (qw(ALLOW DENY BLOCK)) {
				my $listref = $self->{'clientlist'}{$actionbl};
				if ($listref) {
					my @list = @$listref;
					foreach my $ipbl (@list) {
						my ($ip_block, @ip_options) = @$ipbl;
						if ($ip_block->contains($ip)) {
							$ret = [ $actionbl, @ip_options ];
						}
					}

				}
			}

		} else {
			# invalid!? block it then
			$ret = [ BLOCK ];
		}
		
	} else {
		my $retaction = $ret->[0];
		log_info( "No clientfile (allow/deny) specified so defaulting to $retaction.\n" );		
	}
	my ($action, @options) = @$ret;
	log_info("Action for client $ip_string is $action.");
	$self->_countstats('CLIENTS' => $ip_string,
				       'ACTIONS' => $ret);
	
	return $ret;
}

sub _countstats {
	my $self = shift;
	my %args = @_;
	
	if (config_value('TESTING')) {
		use tests::mocks::MockStats qw(count_stat_n);
	} else {
		use MP3S::Misc::Stats qw(count_stat);
	}
	foreach my $cat (keys %args) {
		if (config_value('TESTING')) {
			count_stat_n($cat, $args{$cat});			
		} else {
			count_stat($cat, $args{$cat});			
		}
	}
}

sub read_client_list {
	my $self = shift;
	my ($clfile) = @_;
	open my $fh, $clfile or die "Unable to open client list file: $!";
	
	$self->{'clientlist'} = ();
	while (<$fh>) {
		my $cline = $_;
		chomp $cline;
		my ($net, $spec, @options) = split /\s+/, $cline;
		unless ($net =~ /^\#/) {
			my $ip = NetAddr::IP->new($net);
			if ($ip) {
				push @{$self->{'clientlist'}->{$spec}}, [$ip, @options];
			} else {
				log_error( "Unable to recognise $ip as a valid IP address/subnet" );
			}
		}
	}
}

1;