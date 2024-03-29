package MP3S::Music::PlaylistMaster;

use strict;
use Carp;
use File::Find;
use MP3S::Music::Song;
use MP3S::Misc::MSConf qw(config_value);
use MP3S::Misc::Logger qw(log_debug log_info);

sub new {
    my $class  = shift;
    my ($arg1) = @_;
    my %args   = ( 'songs' => gen_master_list($arg1) );

    bless \%args, $class;
}

sub is_stale {
    my $self = shift;
    my ( $rootdir, $orig_time ) = @_;

	no warnings 'File::Find';
    our $new_mp3s = 0;
    if ($rootdir) {
        find(
            {
                wanted => sub {
                    my ($song)   = $File::Find::name;
                    my $basename = $_;
                    my @stat     = stat($song);
                    if ( $stat[9] > $orig_time && $basename =~ /\.(mp3|ogg)$/i )
                    {
                        $new_mp3s++;
                        log_debug(
                            "Found a file newer than the playlist: $basename");
                    }

                },
                no_chdir => 1,
				follow_fast => 1,
            },
            $rootdir
        );
    }
    $new_mp3s;
}

sub songs {
    my $self = shift;
    $self->{'songs'};
}

#internal sub to generate song objects
sub gen_master_list {
    my ($arg1) = @_;

	log_info("Generating master playlist.");
	my $starttime = time;
    my @ret = ();
    if ( -f $arg1 ) {    #it's a playlist
        open my $f_pls, $arg1 or die "Unable to open playlist $arg1: $!";

		log_info("Using given playlist $arg1.");
        while (<$f_pls>) {
            my $s = $_;
            chomp $s;

            log_debug("  Adding '$s' to song_objects list\n");
            my $sn = MP3S::Music::Song->new( filename => $s );
            $sn->set_URI_from_rootdir($arg1);
            push @ret, $sn;
        }
    }
    elsif ( -d $arg1 ) {    #it's a rootdir
		log_info("Using given root directory $arg1.");
		
        our @mp3s = ();     # CM - check this for scope

		if (config_value('fromtags')) { # TODO: what if the playlist IS stale?
			#die "fromtags not supported yet";
			use MP3S::DB::Access;
			my $db = MP3S::DB::Access->new;

			my $res = $db->execute(qq{
				SELECT DISTINCT song_filepath, file_hash
				FROM MP3S_tags
				WHERE song_filepath like '${arg1}%'
				ORDER BY 1;
			});

			my $ctr = 0;
			foreach my $row(@$res) {
				$ctr++;
				my ($song, $hash) = @$row;
				my $songpath = $song; # should have stored the 'correct' characters in the db. qx{ls -1 -b "$song"};
                chomp $songpath;
                push @mp3s, [ $song, $songpath, $hash ] if $song =~ /\.(mp3|ogg)$/i;
			}
			log_info("Done figuring out song list from the tags in the database! $ctr song(s) found.");
			
		}
		else {
			no warnings 'File::Find'; #sshhhh
	        find(
	            {
	                wanted => sub {
	                    my ($song) = $File::Find::name;
	                    my $songpath = qx{ls -1 -b "$song"};
	                    chomp $songpath;
	                    push @mp3s, [ $song, $songpath ] if /\.(mp3|ogg)$/i;

	                },
	                no_chdir => 1,
	            },
	            $arg1
	        );			
		}

        foreach (@mp3s) {
            my ( $song, $songpath, $hash ) = @{$_};
            chomp $song;

            # strange ._Something.mp3 files in there
            next if $song =~ /\/\.[^\/]*$/;
            log_debug("  Adding '$song' to song_objects list\n");
            my $sn = MP3S::Music::Song->new(
                filename     => $song,
                uni_filename => $songpath,
                hash         => $hash
            );
            $sn->set_URI_from_rootdir($arg1);
            push @ret, $sn;
        }

    }
    else {
        croak "Can't call gen_song_objects with non-file, non-dir $arg1";
    }
	my $elapsed = time - $starttime;
	log_info("Generating master playlist complete - took $elapsed secs.");

    \@ret;
}

1;
