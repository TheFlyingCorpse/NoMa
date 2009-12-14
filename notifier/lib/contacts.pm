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



##############################################################################
# NOTIFICATION- AND CONTACT-FILTERING FUNCTIONS
##############################################################################

# generate a list of contacts from an id, counter and status
sub getContacts
{

    my ($ids, $notificationCounter, $status, $incident_id) = @_;
    debug('trying to getUsersAndMethods');
    my %contacts_c =
    getUsersAndMethods( $ids, $notificationCounter, $status );
    debug( debugHashUsers(%contacts_c) );
    my %contacts_cg =
    getUsersAndMethodsFromGroups( $ids, $notificationCounter,
        $status );
    debug( 'Users from groups: '.debugHashUsers(%contacts_cg) );

    # merge contact hashes
    my %contacts = mergeHashes( \%contacts_c, \%contacts_cg );
    %contacts = removeHashEntryDuplicates( \%contacts );
    debug("Removing duplicates. Users remaining: ". debugHashUsers(%contacts) );

    # get current time
    my $now = time();

    # check contacts for holidays
    %contacts = checkHolidays(%contacts);
    debug("Holidays. Users remaining: ". debugHashUsers(%contacts) );

    # check contacts for working hours
    %contacts = checkWorkingHours(%contacts);
    debug("Working hours. Users remaining: ". debugHashUsers(%contacts) );

    # check contacts for multiple alert suppression
    # --> only sends one alert if the incident_id is the same - be careful
    %contacts = checkSuppressionFlag($incident_id, %contacts) if ( $status ne 'OK' && $status ne 'UP');
    debug("Suppression. Users remaining: ". debugHashUsers(%contacts) );

    # convert contact hash into array
    my @contactsArr = hash2arr(%contacts);
    return @contactsArr;
}



sub generateNotificationList
{

    my ( $check_type, $notificationHost, $notificationService, %dbResult ) = @_;

    my $cnt = 0;
    my %hostList;
    my %serviceList;

    # BEGIN - generate include and exclude lists for hosts and services
    while ( defined( $dbResult{$cnt} ) )
    {

        # generate host-include list
        my @hosts = split( ',', $dbResult{$cnt}->{hosts_include} );
        @hosts = map( { lc($_) } @hosts );

        # check each host against the host, passed with command-line parameters
        # and add it to the include list
        for my $host (@hosts)
        {

            $host =~ s/^\s+|\s+$//g;

            if ( $host ne '' )
            {

                $host =~ s/\*/.*/g;

                # only add host to list if it matches the passed one
                if ( $notificationHost =~ m/^$host$/i )
                {
                    debug( "Step1: HostIncl: $host\t" . $dbResult{$cnt}->{id} );
                    $hostList{ $dbResult{$cnt}->{id} } = 1;
                }

            }

        }

        # remove hosts to be excluded
        @hosts = split( ',', $dbResult{$cnt}->{hosts_exclude} );
        @hosts = map( { lc($_) } @hosts );

        # check each host against the host, passed with command-line parameters
        # and remove them from host list
        for my $host (@hosts)
        {

            $host =~ s/^\s+|\s+$//g;

            if ( $host ne '' )
            {

                $host =~ s/\*/.*/g;

                if ( $notificationHost =~ m/^$host$/i )
                {
                    debug( "Step1: HostExcl: $host\t" . $dbResult{$cnt}->{id} );
                    undef( $hostList{ $dbResult{$cnt}->{id} } )
                      if ( defined( $hostList{ $dbResult{$cnt}->{id} } ) );
                }

            }

        }

        if ( $check_type eq 's' )
        {

            # generate service-include list
            my @services = split( ',', $dbResult{$cnt}->{services_include} );
            @services = map( { lc($_) } @services );

   # check each service against the service, passed with command-line parameters
   # and add it to the include list
            for my $service (@services)
            {

                $service =~ s/^\s+|\s+$//g;

                if ( $service ne '' )
                {

                    $service =~ s/\*/.*/g;

                    # only add service to list if it matches the passed one
                    if ( $notificationService =~ m/^$service$/i )
                    {
                        debug( "Step1: ServiceIncl: $service\t"
                              . $dbResult{$cnt}->{id} );
                        $serviceList{ $dbResult{$cnt}->{id} } = 1;
                    }

                }

            }

            # remove services to be excluded
            @services = split( ',', $dbResult{$cnt}->{services_exclude} );
            @services = map( { lc($_) } @services );

      # check each host against the service, passed with command-line parameters
      # and remove them from service list
            for my $service (@services)
            {

                $service =~ s/^\s+|\s+$//g;

                if ( $service ne '' )
                {

                    $service =~ s/\*/.*/g;

                    if ( $notificationService =~ m/^$service$/i )
                    {
                        debug( "Step1: ServiceExcl: $service\t"
                              . $dbResult{$cnt}->{id} );
                        undef( $serviceList{ $dbResult{$cnt}->{id} } )
                          if defined( $serviceList{ $dbResult{$cnt}->{id} } );
                    }

                }

            }

        }

        # increase counter
        $cnt++;

    }

    # END   - generate include and exclude lists for hosts and services

    # BEGIN - collect all IDs to notify
    my %idList;
    my @ids;
    while ( my ($hostIncl) = each(%hostList) )
    {
        debug("Step2: HostIncl: $hostIncl");
        if ( $check_type eq 's' )
        {
            $idList{$hostIncl} = 1
              if ( defined( $serviceList{$hostIncl} )
                && defined( $hostList{$hostIncl} ) );
        } else
        {
            $idList{$hostIncl} = 1 if ( defined( $hostList{$hostIncl} ) );
        }
    }
    if ( $check_type eq 's' )
    {
        while ( my ($serviceIncl) = each(%serviceList) )
        {
            if ( defined( $serviceList{$serviceIncl} ) )
            {
                debug("Step2: ServiceIncl: $serviceIncl");
                $idList{$serviceIncl} = 1
                  if ( defined( $hostList{$serviceIncl} ) );
            }
        }
    }
    while ( my ($id) = each(%idList) )
    {
        push( @ids, $id );
    }

    # END   - collect all IDs to notify

    return @ids;

}

sub getUsersAndMethods
{

    my ( $ids, $notificationCounter, $status ) = @_;

    my %dbResult;
    my @dbResult_arr;
    my @dbResult_tmp_arr;
    my $where = '';
    my $query;

    # standard query
    my $ids_cnt = scalar(@$ids);

    if ($ids_cnt)
    {

        if ( $ids_cnt == 1 )
        {
            $where = $ids->[0];
        } else
        {
            $where = join( '\' or n.id=\'', @$ids );
        }

        $query =
'select distinct c.username, c.phone, c.mobile, c.email, tz.timezone, m.id mid, m.method, m.command, m.contact_field, m.from, m.on_fail, m.ack_able, n.notify_after_tries, n.let_notifier_handle, n.id rule from notifications n
					left join notifications_to_methods nm on n.id=nm.notification_id
					left join notification_methods m on m.id=nm.method_id
					left join notifications_to_contacts nc on n.id=nc.notification_id
					left join contacts c on c.id=nc.contact_id
					left join timezones tz on c.timezone_id=tz.id
					where n.active=\'1\' and (n.id=\'' . $where . '\')';
        @dbResult_tmp_arr = queryDB( $query, 1 );

        $where =~ s/n\.id/ec\.notification_id/g;

        $query =
'select distinct c.username, c.phone, c.mobile, c.email, tz.timezone, m.id mid, m.method, m.command, m.contact_field, m.from, m.on_fail, m.ack_able, ec.notify_after_tries, n.let_notifier_handle, n.id rule from escalations_contacts ec
					left join escalations_contacts_to_contacts ecc on ec.id=ecc.escalation_contacts_id
					left join contacts c on c.id=ecc.contacts_id
					left join escalations_contacts_to_methods ecm on ec.id=ecm.escalation_contacts_id
					left join notification_methods m on ecm.method_id=m.id
					left join timezones tz on c.timezone_id=tz.id
					left join notifications n on ec.notification_id=n.id
					where n.active=\'1\' and (ec.notification_id=\'' . $where . '\')';
        @dbResult_arr = queryDB( $query, 1 );

        @dbResult_arr = ( @dbResult_arr, @dbResult_tmp_arr );
	debug("Contacts Array: ".Dumper(@dbResult_arr));

        updateMaxNotificationCounter( \@dbResult_arr, $notificationCounter );

        @dbResult_arr =
          filterNotificationsByEscalation( \@dbResult_arr, $notificationCounter,
            $status );
	debug("Filtered Array: ".Dumper(@dbResult_arr));
        %dbResult = arrayToHash( \@dbResult_arr );

        %dbResult = () unless ( defined( $dbResult{0}->{username} ) );

    }

    return %dbResult;

}

sub getUsersAndMethodsFromGroups
{

    my ( $ids, $notificationCounter, $status ) = @_;

    my %dbResult;
    my @dbResult_arr;
    my @dbResult_tmp_arr;
    my $where = '';
    my $query;

    my $ids_cnt = @$ids;

    if ($ids_cnt)
    {

        if ( $ids_cnt == 1 )
        {
            $where = $ids->[0];
        } else
        {
            $where = join( '\' or n.id=\'', @$ids );
        }

        # query db for contacts
        $query =
'select distinct c.username, c.phone, c.mobile, c.email, tz.timezone, m.id mid, m.method, m.command, m.contact_field, m.from, m.on_fail, m.ack_able, n.notify_after_tries, n.let_notifier_handle, n.id rule from notifications n
					left join notifications_to_methods nm on n.id=nm.notification_id
					left join notification_methods m on m.id=nm.method_id
					left join notifications_to_contactgroups ncg on n.id=ncg.notification_id
					left join contactgroups cg on ncg.contactgroup_id=cg.id
					left join contactgroups_to_contacts cgc on cgc.contactgroup_id=cg.id
					left join contacts c on c.id=cgc.contact_id
					left join timezones tz on c.timezone_id=tz.id
					where cg.view_only=\'0\' and n.active=\'1\' and (n.id=\'' . $where . '\')';

        @dbResult_arr = queryDB( $query, 1 );

        $where =~ s/n\.id/ec\.notification_id/g;

        $query =
'select distinct c.username, c.phone, c.mobile, c.email, tz.timezone, m.id mid, m.method, m.command, m.contact_field, m.from, m.on_fail, m.ack_able, ec.notify_after_tries, n.let_notifier_handle, n.id rule from escalations_contacts ec
					left join escalations_contacts_to_contactgroups eccg on ec.id=eccg.escalation_contacts_id
					left join contactgroups_to_contacts cgc on eccg.contactgroup_id=cgc.contactgroup_id
					left join contacts c on cgc.contact_id=c.id
					left join escalations_contacts_to_methods ecm on ec.id=ecm.escalation_contacts_id
					left join notification_methods m on m.id=ecm.method_id
					left join timezones tz on c.timezone_id=tz.id
					left join notifications n on ec.notification_id=n.id
					left join contactgroups cg on cgc.contactgroup_id=cg.id
					where cg.view_only=\'0\' and n.active=\'1\' and (ec.notification_id=\'' . $where . '\')';

        @dbResult_tmp_arr = queryDB( $query, 1 );

        @dbResult_arr = ( @dbResult_arr, @dbResult_tmp_arr );

        updateMaxNotificationCounter( \@dbResult_arr, $notificationCounter );
	debug("notification counter = $notificationCounter");

        @dbResult_arr =
          filterNotificationsByEscalation( \@dbResult_arr, $notificationCounter,
            $status );
        %dbResult = arrayToHash( \@dbResult_arr );

        %dbResult = () unless ( defined( $dbResult{0}->{username} ) );

    }

    return %dbResult;

}

sub checkSuppressionFlag
{

    my ($id, %contacts) = @_;


    	return %contacts if not (scalar %contacts);

	# get list of users we don't want to inform
	$query = 'select distinct c.username from contacts as c
					left join notification_logs as l on c.username=l.user 
					where l.incident_id=\'' . $id . '\' and restrict_alerts=1';
					

	my @dbResult = queryDB($query, '1');

	foreach my $contact (@dbResult)
	{
		delete $contacts{$contact};
	}

    return %contacts;

}

sub checkHolidays
{

    my %contacts = @_;

    # set up variables
    my $on_holiday;
    my %newContacts;

    # loop through contacts
    while ( my ($contact) = each(%contacts) )
    {

        # init on-holiday flag
        $on_holiday = 0;

        # get holiday entries for current contact
        $query = 'select h.start,h.end from holidays h
					left join contacts c on c.id=h.contact_id
					where c.username=\'' . $contacts{$contact}->{username} . '\'';

        my @dbResult = queryDB($query, '1');

	# set timezone
	my $tz = DateTime::TimeZone->new( name =>  $contacts{$contact}->{timezone});
	my $dt = DateTime->now()->set_time_zone($tz);

        # check person's holiday data
	if (datetimeInPeriod(\@dbResult, $dt->ymd." ".$dt->hms))
        {
		debug(  "username: ".$contacts{$contact}->{username}." (GMT+".$dt->offset($dt)."s) on holiday, dropping");
	        $on_holiday = 1;

        }

        # add contact to new contact list if not on holidays
        if ( !$on_holiday )
        {
            $newContacts{$contact} = $contacts{$contact};
        }

    }

    return %newContacts;

}

sub checkWorkingHours
{

    my %contacts = @_;

    # set up variables
    my $away;
    my %newContacts;

    # loop through contacts
    while ( my ($contact) = each(%contacts) )
    {

        # init away flag
        $away = 0;

        # get working hours for current contact
        $query = 'select s.days,s.starttime,s.endtime from time_slices s
			left join time_periods t on s.time_period_id=t.id
			left join contacts c on c.time_period_id=t.id
			where c.username=\'' . $contacts{$contact}->{username} . '\'';

        my @dbResult = queryDB($query, '1');

	# set timezone
	my $tz = DateTime::TimeZone->new( name =>  $contacts{$contact}->{timezone});
	my $dt = DateTime->now()->set_time_zone($tz);

    # drop contact and break loop if outside time period
    if (!(timeInPeriod(\@dbResult, $dt->day_of_week, $dt->hms)))
    {
	debug( "username: ".$contacts{$contact}->{username}." (GMT+".$dt->offset($dt)."s) outside time period, dropping");
	$away = 1;
	next;
    }

        # add contact to new contact list
        if ( !$away )
        {
            $newContacts{$contact} = $contacts{$contact};
        }

    }

    return %newContacts;

}



# TODO consider counter wrap
# only send alerts to contacts that have the correct notification nr.
# or recoveries / OKs to all preceding
sub filterNotificationsByEscalation
{

    my ( $dbResult_arr, $filter, $status ) = @_;
    my @return_arr;

    # prepare search filter
    if ( $status eq 'OK' || $status eq 'UP' )
    {
        my @filter_entries;
        for ( my $x = 0 ; $x <= $filter ; $x++ )
        {
            push( @filter_entries, $x );
        }
        $filter = '[' . join( '|', @filter_entries ) . ']';
    }

    # apply filter
    foreach my $row (@$dbResult_arr)
    {
        next
          if ( !defined( $row->{notify_after_tries} )
            || $row->{notify_after_tries} eq '' );
        my @notify_after_tries = getArrayOfNums( $row->{notify_after_tries} );
        if (   grep( /^$filter$/, @notify_after_tries )
            && defined( $row->{username} )
            && $row->{username} ne '' )
        {
            push( @return_arr, $row );
        }
    }

    return @return_arr;

}




1;
