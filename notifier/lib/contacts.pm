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
use time_frames;


##############################################################################
# NOTIFICATION- AND CONTACT-FILTERING FUNCTIONS
##############################################################################

# generate a list of contacts from an id, counter and status
sub getContacts
{

    my ($ids, $notificationCounter, $status, $notification_type, $incident_id) = @_;
    debug('trying to getUsersAndMethods');
    my %contacts_c =
    getUsersAndMethods( $ids, $notificationCounter, $notification_type,$status );
    debug("Users from rules: ". debugHashUsers(%contacts_c) );
    my %contacts_cg =
    getUsersAndMethodsFromGroups( $ids, $notificationCounter, $notification_type,
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
    %contacts = checkContactWorkingHours(%contacts);
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

    my ( $check_type, $notificationRecipients, $notificationHost, $notificationService, $notificationHostgroups, $notificationServicegroups, %dbResult ) = @_;

#    debug(' notificationHost: '.$notificationHost.' notificationService: '.$notificationService.' notificationHostgroups: '.$notificationHostgroups.' notificationServicegroups: '.$notificationServicegroups.' notificationRecipients: '.$notificationRecipients);

    my $cnt = 0;
    my %notifyList;
    my @recipients = split(",",$notificationRecipients);
    my @hostgroups = split(",",$notificationHostgroups);
    my @servicegroups = split(",",$notificationServicegroups);
    my $rCount = @recipients;
    if ($rCount < 1) {
        $recipients[0] = "__NONE";
    }
    my $hgCount = @hostgroups;
    if($hgCount < 1) {
        $hostgroups[0] = "__NONE";
    }
    my $sgCount = @servicegroups;
    if($sgCount < 1) {
        $servicegroups[0] = "__NONE";
    }
    # BEGIN - generate include and exclude lists for hosts and services
    while ( defined( $dbResult{$cnt} ) )
    {

	# generate recipients-include list
	foreach my $recipient(@recipients) {
            if (matchString( $dbResult{$cnt}->{recipients_include}, $recipient))
            {
                debug( "Step1: RecipientIncl: $recipient\t" . $dbResult{$cnt}->{id} );
                $notifyList{ $dbResult{$cnt}->{id} } = 1;
            }

            # remove recipients to be excluded
            if (matchString( $dbResult{$cnt}->{recipients_exclude}, $recipient))
            {
                debug( "Step1: RecipientExcl: $recipient\t" . $dbResult{$cnt}->{id} );
                undef( $notifyList{ $dbResult{$cnt}->{id} } )
                    if defined( $notifyList{ $dbResult{$cnt}->{id} } );
            }
        }

	# If its a service(group) check.
        if ( $check_type eq 's' )
        {

            # generate servicegroup-include list
            foreach my $servicegroup(@servicegroups) {
                if (matchString( $dbResult{$cnt}->{servicegroups_include}, $servicegroup))
                {
                    debug( "Step1: SvcGrpIncl: $servicegroup\t" . $dbResult{$cnt}->{id} );
                    $notifyList{ $dbResult{$cnt}->{id} } = 1;
                }

                    # remove services to be excluded
                if (matchString( $dbResult{$cnt}->{servicegroups_exclude}, $servicegroup))
                {
                    debug( "Step1: SvcGrpExcl: $servicegroup\t" . $dbResult{$cnt}->{id} );
                    undef( $notifyList{ $dbResult{$cnt}->{id} } )
                        if defined( $notifyList{ $dbResult{$cnt}->{id} } );

                }
            }
	}
	# generate hostgroup-include list
        foreach my $hostgroup(@hostgroups) {
            if (matchString( $dbResult{$cnt}->{hostgroups_include}, $hostgroup))
            {
		debug( "Step1: HostGrp:Incl: $hostgroup\t" . $dbResult{$cnt}->{id} );
                $notifyList{ $dbResult{$cnt}->{id} } = 1;
            }

            # remove hosts to be excluded
            if (matchString( $dbResult{$cnt}->{hostgroups_exclude}, $hostgroup))
            {
                debug( "Step1: HostGrp:Excl: $hostgroup\t" . $dbResult{$cnt}->{id} );
                undef( $notifyList{ $dbResult{$cnt}->{id} } )
                    if ( defined( $notifyList{ $dbResult{$cnt}->{id} } ) );
            }
        }


        # generate host-include list
        if (matchString( $dbResult{$cnt}->{hosts_include}, $notificationHost))
        {
            debug( "Step1: HostIncl: $notificationHost\t" . $dbResult{$cnt}->{id} );
            $notifyList{ $dbResult{$cnt}->{id} } = 1;
        }

        # remove hosts to be excluded
        if (matchString( $dbResult{$cnt}->{hosts_exclude}, $notificationHost))
        {
            debug( "Step1: HostExcl: $notificationHost\t" . $dbResult{$cnt}->{id} );
            undef( $notifyList{ $dbResult{$cnt}->{id} } )
                if defined( $notifyList{ $dbResult{$cnt}->{id} } );
        }

        if ( $check_type eq 's' )
        {
            # generate service-include list
            if (matchString( $dbResult{$cnt}->{services_include}, $notificationService))
            {
                debug( "Step1: ServiceIncl: $notificationService\t" . $dbResult{$cnt}->{id} );
                $notifyList{ $dbResult{$cnt}->{id} } = 1;
            }


            # remove services to be excluded
            if (matchString( $dbResult{$cnt}->{services_exclude}, $notificationService))
            {
                debug( "Step1: ServiceExcl: $notificationService\t" . $dbResult{$cnt}->{id} );
                undef( $notifyList{ $dbResult{$cnt}->{id} } )
                    if defined( $notifyList{ $dbResult{$cnt}->{id} } );
            }

        }
        # increase counter
        $cnt++;

    }

    # END - (of generate include and exclude lists for hosts and services)

    # BEGIN - collect all IDs to notify
    my %idList;
    my @ids;
    while ( my ($notifyIncl) = each(%notifyList) )
    {
            if ( defined( $notifyList{$notifyIncl}) )
            {
		# Verify that the notification is within the time frame.
		if (notificationInTimeFrame($notifyIncl) == '1'){
                $idList{$notifyIncl} = 1;
                debug("Step2: notifyIncl: $notifyIncl");
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

sub matchString
{
	# test a string against a comma separated list and return 1 if it matches
	my ($matchList, $match) = @_;

        my @items = split( ',', $matchList );
        @items = map( { lc($_) } @items );

        for my $item (@items)
        {
            # remove leading/trailing whitespace
            $item =~ s/^\s+|\s+$//g;

            if ( $item ne '' )
            {

		# Use * and ? as wildcards
                $item =~ s/\*/.*/g;
                $item =~ s/\./\./g;
                $item =~ s/\?/./g;

                # only add item to list if it matches the passed one
                return 1 if ( $match =~ m/^$item$/i );

            }

        }
	return 0;
}


sub getUsersAndMethods
{

    my ( $ids, $notificationCounter, $notification_type, $status ) = @_;

    my %dbResult;
    my @dbResult_arr;
    my @dbResult_not_arr;
    my @dbResult_esc_arr;
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
'select distinct c.username, c.phone, c.mobile, c.netaddress, c.email, tz.timezone, m.id mid, m.method, m.command, m.contact_field, m.from, m.on_fail, m.ack_able, n.notify_after_tries, n.let_notifier_handle, n.id rule from notifications n
					left join notifications_to_methods nm on n.id=nm.notification_id
					left join notification_methods m on m.id=nm.method_id
					left join notifications_to_contacts nc on n.id=nc.notification_id
					left join contacts c on c.id=nc.contact_id
					left join timezones tz on c.timezone_id=tz.id
					where n.active=\'1\' and (n.id=\'' . $where . '\')';
        @dbResult_not_arr = queryDB( $query, 1 );

        $where =~ s/n\.id/ec\.notification_id/g;

        $query =
'select distinct c.username, c.phone, c.mobile, c.netaddress, c.email, tz.timezone, m.id mid, m.method, m.command, m.contact_field, m.from, m.on_fail, m.ack_able, ec.notify_after_tries, n.let_notifier_handle, n.id rule from escalations_contacts ec
					left join escalations_contacts_to_contacts ecc on ec.id=ecc.escalation_contacts_id
					left join contacts c on c.id=ecc.contacts_id
					left join escalations_contacts_to_methods ecm on ec.id=ecm.escalation_contacts_id
					left join notification_methods m on ecm.method_id=m.id
					left join timezones tz on c.timezone_id=tz.id
					left join notifications n on ec.notification_id=n.id
					where n.active=\'1\' and (ec.notification_id=\'' . $where . '\')';
	@dbResult_tmp_arr = queryDB( $query, 1 );

        @dbResult_esc_arr =
          filterNotificationsByEscalation( \@dbResult_tmp_arr, $notificationCounter, $notification_type,
            $status );

        @dbResult_arr = ( @dbResult_not_arr, @dbResult_esc_arr );

        debug("To be notified: ".Dumper(@dbResult_arr));

        %dbResult = arrayToHash( \@dbResult_arr );

        %dbResult = () unless ( defined( $dbResult{0}->{username} ) );

    }

    return %dbResult;

}

sub getUsersAndMethodsFromGroups
{

    my ( $ids, $notificationCounter, $notification_type, $status ) = @_;

    my %dbResult;
    my @dbResult_arr;
    my @dbResult_not_arr;
    my @dbResult_esc_arr;
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
'select distinct c.username, c.phone, c.mobile, c.netaddress, c.email, tz.timezone, m.id mid, m.method, m.command, m.contact_field, m.from, m.on_fail, m.ack_able, n.notify_after_tries, n.let_notifier_handle, n.id rule from notifications n
					left join notifications_to_methods nm on n.id=nm.notification_id
					left join notification_methods m on m.id=nm.method_id
					left join notifications_to_contactgroups ncg on n.id=ncg.notification_id
					left join contactgroups cg on ncg.contactgroup_id=cg.id
					left join contactgroups_to_contacts cgc on cgc.contactgroup_id=cg.id
					left join contacts c on c.id=cgc.contact_id
					left join timezones tz on c.timezone_id=tz.id
					where cg.view_only=\'0\' and n.active=\'1\' and (n.id=\'' . $where . '\')';

        @dbResult_not_arr = queryDB( $query, 1 );

        $where =~ s/n\.id/ec\.notification_id/g;

        $query =
'select distinct c.username, c.phone, c.mobile, c.netaddress, c.email, tz.timezone, m.id mid, m.method, m.command, m.contact_field, m.from, m.on_fail, m.ack_able, ec.notify_after_tries, n.let_notifier_handle, n.id rule from escalations_contacts ec
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

        @dbResult_esc_arr =
          filterNotificationsByEscalation( \@dbResult_tmp_arr, $notificationCounter, $notification_type,
            $status );

	@dbResult_arr = ( @dbResult_not_arr, @dbResult_esc_arr );

	debug("To be notified: ".Dumper(@dbResult_arr));

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

sub checkContactWorkingHours
{

    my %contacts = @_;

    # set up variables
    my %newContacts;

    # loop through contacts
    while ( my ($contact) = each(%contacts) )
    {

	# REPLACE WHAT IS BELOW!!! 

	my $away = 0;

	# get timeframe_id for the current contact
	my $query = 'select contacts.timeframe_id from contacts where contacts.username=\'' . $contacts{$contact}->{username} . '\'';

        my %dbResult = queryDB($query);

	    # drop contact and break loop if outside time period
	    if ( (objectInTimeFrame($dbResult{0}->{timeframe_id}) eq 0 ))
	    {
		debug( "username: ".$contacts{$contact}->{username}." outside timeframe, dropping");
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

    my ( $dbResult_arr, $filter, $notification_type, $status ) = @_;
    my @return_arr;

    debug('filter: '.$filter.' notification_type: '.$notification_type.' status: '.$status);
    debug("dbResult_arr Array: ".Dumper($dbResult_arr));

    # prepare search filter
    if ( $status eq 'OK' || $status eq 'UP' || $notification_type eq 'ACKNOWLEDGEMENT' || $notification_type eq 'CUSTOM' || $notification_type eq 'FLAPPINGSTART' || $notification_type eq 'FLAPPINGSTOP' || $notification_type eq 'FLAPPINGDISABLED' || $notification_type eq 'DOWNTIMESTART' || $notification_type eq 'DOWNTIMEEND' || $notification_type eq 'DOWNTIMECANCELLED')
    {
        my @filter_entries;
        for ( my $x = 0 ; $x <= $filter ; $x++ )
        {
            push( @filter_entries, $x );
        }
        $filter = '[' . join( '|', @filter_entries ) . ']';
    }

    debug('filter2: '.$filter);

    # apply filter
    foreach my $row (@$dbResult_arr)
    {
	debug('row: '.Dumper($row));
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

    debug('return_arr: '.Dumper(@return_arr));

    return @return_arr;

}

sub getMaxValue
{
    # given a range string, return the maximum
    # e.g. 1-4,7-8,12
	my ($range) = @_;

	$range =~ s/[^0-9,;-]//g;

    return $range unless ($range =~ /[,;-]+/);

    my $newmax = 1;
    foreach my $crange (split(/[,;]/, $range))
    {
        debug("Expanding $crange");
        $crange =~ /(\d*)-(\d*)/;

        my $min = $1;
        my $max = $2;

        if ((not defined($min)) or ($min < 1))
        {
            debug("Invalid minimum value in range \"$crange\" - setting to 1");
            $min = 1;
        }

        if ((not defined($max)) or ($max < $min))
        {
            debug("Invalid maximum value in range \"$crange\" - setting to 99999");
            $max = 99999;
        }


        $newmax = $max if ($max > $newmax);
    }

    return $newmax;
}

1;
