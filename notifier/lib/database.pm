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


sub queryDB
{

    my ( $queryStr, $array, $nolog ) = @_;
    my $debug_queries = $conf->{debug}->{queries};
    my $database_type = $conf->{db}->{type};
    my $dbh;

    debug('Database type: '.$database_type,3) unless defined($nolog);
    if ($database_type eq 'mysql'){
            debug('Going to use MySQL as backend...',3) unless defined($nolog);
	    $dbh = DBI->connect(
	        'DBI:mysql:host='
	          . $conf->{db}->{mysql}->{host}	# MySQL NoMa Host
	          . ';database='
	          . $conf->{db}->{mysql}->{database},	# MySQL NoMa DB
	        $conf->{db}->{mysql}->{user}, 		# MySQL Username
		$conf->{db}->{mysql}->{password}	# MySQL Password
	    ) or debug($DBI::errstr,1);
    } elsif ($database_type eq 'sqlite3'){
            debug('Going to use SQLite3 as backend...',3) unless defined($nolog);
	    $dbh = DBI->connect(
		"dbi:SQLite:dbname=$conf->{db}->{sqlite3}->{dbfile}","","") or debug($DBI::errstr,1);
    } else {
	debug(' Invalid database set: '.$database_type.' Fix your configuration!',1);
    }
    if ( !defined($dbh)) {
        return undef;
    }
    debug("QUERY: " . $queryStr, 2) if (defined($debug_queries) and ($debug_queries != 0) and not defined($nolog));
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

sub dbVersion
{
	my ($expecteddbversion,$loopstopper) = @_;
        my $database_type = $conf->{db}->{type};
	my $database_upgrade = $conf->{db}->{automatic_db_upgrade};

        debug(' Checking DB schema version ',2);
	# Create if not exists.
#	my $query = 'CREATE TABLE if not exists information (id INTEGER  NOT NULL PRIMARY KEY AUTOINCREMENT,type varchar(20) NOT NULL,content varchar(20)  NOT NULL);';
	my $query = 'CREATE TABLE IF NOT EXISTS information (id int(11) NOT NULL,  `type` varchar(20)   NOT NULL,  content varchar(20)   NOT NULL)';
	my $dbResult = queryDB($query);
	# Select, if empty, should detect that the rest is empty/mismatch
        $query = 'select content from information where type=\'dbversion\'';
        my %dbResult = queryDB($query);
        my $dbversion = $dbResult{0}{content};
	if(!$dbversion){
	$dbversion=0;};

        debug(' DB schema version: '.$dbversion,2) if ($dbversion);

        if ($loopstopper eq 0){
                $loopstopper=1;
        } else {
                debug('Preventing the infinite loop, stopping...',3);
                return $dbversion;
        }

	# Check first if its filled with data, if not, just return with dbversion.
	if (($expecteddbversion) and ($expecteddbversion > $dbversion) and ($database_upgrade eq 'yes')){
		# Is the expected version not equal to dbversion?
		if ($expecteddbversion ne $dbversion){
			debug ('Mismatch in schema versions',1);
			# Only be nice if its SQLite3!
			if ($database_type eq 'sqlite3'){
				# CHECK IF THERE IS ANYTHING THERE, LIKE AN OLDER VERSION
				if ($expecteddbversion < $dbversion){
					debug('The expected dbversion is lower than the actual db version, script mismatched to database?',1);
				}
				elsif ($dbversion ne '0' and $expecteddbversion > $dbversion){
					# its just outdated, update.
                                        debug('The expected dbversion is higher than the actual db version, will upgrade schema',1);
					if(dbSchemaUpdate('update') eq 1){
						exit;};
                                        $dbversion=dbVersion($expecteddbversion,$loopstopper);
				} else {
					debug('The database is empty, will try to create it from scracth!',1);
					# needs to be created and filled with the normal structure
					if(dbSchemaUpdate('create_structure') eq 1){
						exit; # Failed to create database schema structure.
					}

					# fill with data
					if(dbSchemaUpdate('fill_data') eq 1){
						exit; # failed to fill database with data.
					}
					$dbversion=dbVersion($expecteddbversion,$loopstopper);
				}
			}
			elsif($database_type eq 'mysql'){
                                # CHECK IF THERE IS ANYTHING THERE, LIKE AN OLDER VERSION
                                if ($expecteddbversion < $dbversion){
                                        debug('The expected dbversion is lower than the actual db version, script mismatched to database?',1);
                                }
                                elsif ($expecteddbversion > $dbversion){
                                        # its just outdated, update.
                                        debug('The expected dbversion is higher than the actual db version, will upgrade schema',1);
					if(dbSchemaUpdate('update') eq 1){
						exit;}; # failed to update schema.
                                } else {
                                        debug('The database is empty, please create it and update credentials to it accordingly.',1);
                                }
                        }
		} else {
			# Versions match
			debug(' Database schema version OK',3);
		}
	}
	elsif($expecteddbversion and $expecteddbversion > $dbversion and $database_upgrade eq 'no'){
		debug(' Automatic DB upgrade turned off, upgrade manually. ',1);
	}
        return $dbversion;
}

sub dbSchemaUpdate
{
	my ($operation) = @_;
        my $database_type = $conf->{db}->{type};
        my $database_upgrade = $conf->{db}->{automatic_db_upgrade};
	my $database_example_dir = $conf->{db}->{db_example_dir};
	my %dbSchemaFiles = (
                'sqlite_new_install_structure'  => 'sqlite3/install/default_schema.sql',
                'sqlite_new_install_data'	=> 'sqlite3/install/default_data.sql',
		'mysql_upgrade_200'		=> ''
 	);

	if ($database_upgrade eq 'no'){ debug('Automatic upgrade is turned off, no automatic schema update!',1);return 1;}; # Its NO to automatic in configuration, this a safety measure.
	debug('Will try to create/upgrade the '.$database_type.' DB schema. ',1);

	if ($database_type eq 'sqlite3'){
		if ($operation eq 'create_structure'){
						# first ensure that the DB is group writeable
						chmod 0664, $conf->{db}->{sqlite3}->{dbfile};
                        # Read file, LINE BY LINE and query.
			debug('Creating new database schema structure',1);

                        # Read file, LINE BY LINE and query.
                        debug('Inserting default schema to database',1);
                        if (-e $database_example_dir.'/'.$dbSchemaFiles{sqlite_new_install_structure}){
                                open FILE, "<$database_example_dir/$dbSchemaFiles{sqlite_new_install_structure}" or die $!;
                                while (my $query = <FILE>){
                                        my $dbResult = queryDB($query); # this might take a while.
                                }
                                close(FILE);
                                debug('Inserted default database schema',1);
                        } else {
                                debug('Cant find the needed schema file! Does it exist? Permissions? '.$database_example_dir.'/'.$dbSchemaFiles{sqlite_new_install_structure},1);
                        }

		
			#if (-e $database_example_dir.'/'.$dbSchemaFiles{sqlite_new_install_structure}.'/contactgroups.sql'){
#				my $sqldir = $database_example_dir.'/'.$dbSchemaFiles{sqlite_new_install_structure};
#				debug('SQLdir: '.$sqldir,3);
#				opendir(DIR, "$sqldir");
#				my @files = grep(/\.sql$/,readdir(DIR));
#				closedir(DIR);
#				debug('Files read in folder: '.@files,2);
#				foreach my $file (@files){
#					debug('About to import file:'.$file,3);
#		                        open FILE, "<$database_example_dir/$dbSchemaFiles{sqlite_new_install_structure}/$file" or die $!;
#					my @query = <FILE>; # Read EVERYTHING
#					$query = "@query";
#					my $dbResult = queryDB($query); # this might take a while.
#					close(FILE);
#				}
#				debug('Inserted database schema structure',1);
			#} else {
			#	debug('Cant find the needed schema file! Does it exist? Permissions? '.$database_example_dir.'/'.$dbSchemaFiles{sqlite_new_install_structure}.'/contactgroups.sql',1);
			#}
		}
                elsif ($operation eq 'fill_data'){
                        # Read file, LINE BY LINE and query.
                        debug('Inserting default data to database',1);
                        if (-e $database_example_dir.'/'.$dbSchemaFiles{sqlite_new_install_data}){
                                open FILE, "<$database_example_dir/$dbSchemaFiles{sqlite_new_install_data}" or die $!;
				while (my $query = <FILE>){
					my $dbResult = queryDB($query); # this might take a while.
				}
				close(FILE);
				debug('Inserted database default data',1);
                        } else {
                                debug('Cant find the needed schema file! Does it exist? Permissions? '.$database_example_dir.'/'.$dbSchemaFiles{sqlite_new_install_data},1);
                        }

                }
		elsif ($operation eq 'update'){
			# Read file, LINE BY LINE and query.
			# If loop per version on future updates.
			#open FILE, "<", "$database_example_dir.$dbSchemaFiles{sqlite_update_sth}" or die $!;
			#while (my $query = <FILE>){
			#	my $dbResult = queryDB($query);
			#}
		}
	}
	elsif($database_type eq 'mysql'){
		# NO UPDATES FOR YOU (-:
	} else {
		debug('Unknown backend to create/update!',1);
	}

	return 0;
}

1;
# vim: ts=4 sw=4 expandtab
