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
	my $conn = undef;
	$conn = DBI->connect( "DBI:Pg:dbname=$dbname;host=$host",
        $user, $pass, { AutoCommit => 1, RaiseError => 1, PrintError => 0 } )
      or die DBI->errstr;
	$conn;
}

sub setup {
	my $self = shift;
	my $conn = $self->{'conn'};
	_connect() unless $conn; # TODO: hmm, this might be bad if 'new' had override args...
	my $create_tables = $conn->prepare(qq{
		DROP TABLE IF EXISTS stats;
		
		CREATE TABLE stats
		( category varchar(50) not null,
		  item     varchar(2000) not null,
		  count int not null default 0,
		PRIMARY KEY (category, item) );
	});
	$create_tables->execute();
}

sub exec {
	my $self = shift;
	my $conn = $self->{'conn'};
	my ($sql, @args) = @_;
	_connect() unless $conn;
	my $sth = $conn->prepare($sql);
	log_info("Preparing SQL $sql");
	
	my $ctr = 1;
	foreach my $arg (@args) {
		my $rc = $sth->bind_param($ctr++, $arg);
	}
	
	$sth->execute;
	
	my $ret = undef;
	if (defined wantarray) {
		$ret = $sth->fetchall_arrayref;		
	}
	$ret;
}

sub DESTROY {
	my $self = shift;
	my $conn = $self->{'conn'};
	log_info("Disconnecting from the database.");
	$conn->disconnect();
}

1;
