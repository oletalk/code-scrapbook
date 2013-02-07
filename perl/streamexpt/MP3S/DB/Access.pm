package MP3S::DB::Access;

use strict;
use DBI;
use MP3S::Misc::MSConf qw(config_value);
use MP3S::Misc::Logger qw(log_info log_debug log_error);


sub new {
	my $class = shift;
	my %args = @_;
    
	my %struc = ('conn' => _connect(%args));
	bless \%struc, $class;
}

sub _connect {
	my %args = @_;
    my $dbname = $args{'dbname'} ||= config_value("dbname");
    my $host = $args{'host'} ||= config_value("host");
    my $user = $args{'user'} ||= config_value("user");
    my $pass = $args{'pass'} ||= config_value("pass");

	my $password = $pass;
	if ( -f $pass) {
		open my $fh, '<', $pass or die "Problems getting db password from file: $!";
		$password = <$fh>;
		close $fh;
		chomp $password;
	}

	my $conn = undef;
	$conn = DBI->connect_cached( "DBI:Pg:dbname=$dbname;host=$host",
        $user, $password, { AutoCommit => 1, RaiseError => 0, PrintError => 1 } )
      or die DBI->errstr;
	$conn;
}

sub exec_single_row {
	my $self = shift;
	my ($sql, @args) = @_;
	my $res = $self->execute($sql, @args);
	
	my $ret = undef;
	my $had_result = 0;
	foreach my $row (@$res) {
		$ret = $row;
		$had_result++;
	}
	log_error("exec_single_row called but result had $had_result rows") if $had_result > 1;
	$ret;
}

sub exec_single_cell {
	my $self = shift;
	my ($sql, @args) = @_;
	my $res = $self->exec_single_row($sql, @args);
	
	my $ret = undef;
	$ret = $res->[0] if $res;
	$ret;
	
}

sub execute {
	my $self = shift;
	my $conn = $self->{'conn'};
	my ($sql, @args) = @_;
	_connect() unless $conn; # TODO: hmm, this might be bad if 'new' had override args...
	my $sth = $conn->prepare($sql);
	log_debug("Preparing SQL $sql");
	
	my $ctr = 1;
	foreach my $arg (@args) {
		my $rc = $sth->bind_param($ctr++, $arg);
	}
	
	my $had_error = 0;
	$sth->execute or $had_error = 1;
	$self->{'errstr'} = $DBI::errstr;
	
	my $ret = undef;
	if (defined wantarray && $had_error == 0) {
		$ret = $sth->fetchall_arrayref;		
	}
	$ret;
}

sub errstr {
	my $self = shift;
	$self->{'errstr'};
}

sub DESTROY {
	my $self = shift;
	my $conn = $self->{'conn'};
	if ($conn) {
		log_debug("Disconnecting from the database.");
		$conn->disconnect();		
	}
}

1;
