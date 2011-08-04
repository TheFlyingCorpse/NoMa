#!/usr/bin/perl

# COPYRIGHT:
#
# This software is Copyright (c) 2007-2009 NETWAYS GmbH, Christian Doebler
#                 some parts (c) 2009      NETWAYS GmbH, William Preston
#                                <support@netways.de>
#
# (Except where explicitly superseded by other copyright notices)
#
#
# LICENSE:GPL2
# see noma_daemon.pl in parent directory for full details.
# Please do not distribute without the above file!


# DB query
# TODO: implement cacheing
# TODO: graceful recovery on SQL errors


sub queryDB
{


    my ( $queryStr, $array, $nolog ) = @_;
    my $debug_queries = $conf->{debug}->{queries};
    my $database_type = $conf->{db}->{type};
    my $dbh;


    if ($database_type == 'mysql'){
	    $dbh = DBI->connect(
	        'DBI:mysql:host='
	          . $conf->{db}->{mysql}->{host}	# MySQL NoMa Host
	          . ';database='
	          . $conf->{db}->{mysql}->{database},	# MySQL NoMa DB
	        $conf->{db}->{mysql}->{user}, 		# MySQL Username
		$conf->{db}->{mysql}->{password}	# MySQL Password
	    ) or debug($DBI::errstr,1);
    } elsif ($database_type == 'sqlite3'){
	    $dbh = DBI->connect(
		"dbi:SQLite:dbname="
		. $conf->{db}->{sqlite3}->{dbfile},     # SQLite DB file
		"",					# No user
		"",					# No password
		( RaiseError => 1 ),			# Complain if something goes wrong
            ) or debug($DBI::errstr,1);
	
    }

    debug("QUERY: " . $queryStr) if (defined($debug_queries) and ($debug_queries != 0) and not defined($nolog), 2);
    my $query = $dbh->prepare($queryStr) or return undef;
    $query->execute or return undef;

    my $cnt = 0;

    if ( $dbh->rows && $queryStr =~ m/^\s*select/i )
    {
        if ( defined($array) )
        {
            my @dbResult;
            while ( my $row = $query->fetchrow_hashref )
            {
                push( @dbResult, \%{$row} );
            }
            $dbh->disconnect();
            return @dbResult;
        } else
        {
            my %dbResult;
            while ( my $row = $query->fetchrow_hashref )
            {
                $dbResult{ $cnt++ } = \%{$row};
            }
            $dbh->disconnect();
            return %dbResult;
        }
    }
    $dbh->disconnect();

    return 0;

}

# this function has been split from the queryDB to implement cacheing
# TODO: implement cacheing
sub updateDB
{
    my ($sql, $nolog) = @_;
    my $cache;

    if ( !defined( queryDB($sql, undef, $nolog) ) )
    {

	debug('Failed to query DB - serious error', 1);
        # DB not available, cache the SQL
        #open( LOG, ">> $cache" );
        #print LOG "$sql\n";
        #close(LOG);
    }
    
    # my $query = $dbh->prepare('select LAST_INSERT_ID') or return undef;
    # $query->execute or return undef;

}

1;
# vim: ts=4 sw=4 expandtab
