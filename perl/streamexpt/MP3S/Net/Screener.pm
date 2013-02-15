package MP3S::Net::Screener;

use strict;
use Carp;

use MP3S::Misc::Logger qw(log_info log_debug log_error);
use MP3S::Misc::Stats qw(count_stat);

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

sub screen {
	my $self = shift;
	my ($ip_string) = @_;

	my $ret = $self->get_default_action;
	
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
			$ret = BLOCK;
		}
		
	} else {
		log_info( "No clientfile (allow/deny) specified so defaulting to $ret.\n" );		
	}
	my ($action, @options) = @$ret;
	log_info("Action for client $ip_string is $action.");
	count_stat('CLIENTS', $ip_string);
	count_stat('ACTIONS', $ret);
	
	return $ret;
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