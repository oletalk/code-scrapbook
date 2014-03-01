package TaskUtil;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(read_cfg process_overrides);

sub read_cfg {
	my ( $config_file ) = @_;
	my $config;
	open my $fh, $config_file or die "Unable to open config file: $!";
	while (<$fh>) {
		my ($key, $value) = /^\s*(\w+)\s*=(.*)$/;
		$key =~ s/^\s+//;
		$key =~ s/\s+$//;
		chomp $value;
		#print "key is '$key', value is '$value'\n";
		if (defined $key && defined $value) {
			$config->{$key} = $value;			
		}
	}
	$config;
}

sub process_overrides {
	my ( $config_hashref, $replacements_hashref ) = @_;
	# where config is as above,
	# and replacements is of the form
	#   ( 'foo_option' => $ref_to_var_to_change, 'next' => $next_ref ... )
	
	my @overrides = ();
	foreach my $key (sort keys %{$replacements_hashref}) {
		my $varref = $replacements_hashref->{$key};
		if (defined $config_hashref->{$key}) {
			if ($$varref ne $config_hashref->{$key}) {
				$$varref = $config_hashref->{$key};			
				push @overrides, $key;				
			}
		}
	}
	if (scalar @overrides > 0) {
		print " (overridden: " . join(', ', @overrides) . ")\n";
	}
}

1;