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
use datetime;
use Data::Dumper;


##############################################################################
# NOTIFICATION- AND CONTACT-FILTERING FUNCTIONS
##############################################################################

# generate a list of contacts from an id, counter and status
sub getContacts
{

    my ($ids, $notificationCounter, $status, $notification_type, $incident_id) = @_;
    debug('trying to getUsersAndMethods', 2);
    my %contacts_c =
    getUsersAndMethods( $ids, $notificationCounter, $notification_type,$status );
    debug("Users from rules: ". debugHashUsers(%contacts_c), 2);
    my %contacts_cg =
    getUsersAndMethodsFromGroups( $ids, $notificationCounter, $notification_type,
        $status );
    debug( 'Users from groups: '.debugHashUsers(%contacts_cg), 2);

    # merge contact hashes
    my %contacts = mergeHashes( \%contacts_c, \%contacts_cg );
    %contacts = removeHashEntryDuplicates( \%contacts );
    debug("Removing duplicates. Users remaining: ". debugHashUsers(%contacts), 2);

    # get current time
    my $now = time();

    # check contacts for holidays
    %contacts = checkHolidays(%contacts);
    debug("Holidays. Users remaining: ". debugHashUsers(%contacts), 2);

    # check contacts for working hours
    %contacts = checkContactWorkingHours(%contacts);
    debug("Working hours. Users remaining: ". debugHashUsers(%contacts), 2);

    # check contacts for multiple alert suppression
    # --> only sends one alert if the incident_id is the same - be careful
    %contacts = checkSuppressionFlag($incident_id, %contacts) if ( $status ne 'OK' && $status ne 'UP');
    debug("Suppression. Users remaining: ". debugHashUsers(%contacts), 2);

    # convert contact hash into array
    my @contactsArr = hash2arr(%contacts);
    return @contactsArr;
}

sub generateNotificationList
{

    my ( $check_type, $notificationRecipients, $notificationHost, $notificationService, $notificationHostgroups, $notificationServicegroups, $notificationCustomvariables, %dbResult ) = @_;

    debug(' notificationRecipients: '. $notificationRecipients . ' notificationHost: '.$notificationHost.' notificationService: '.$notificationService.' notificationHostgroups: '.$notificationHostgroups.' notificationServicegroups: '.$notificationServicegroups.' notificationCustomvariables: '.$notificationCustomvariables, 2);

	# debugging for test suite
	debug('Testdata: '.Dumper({checktype => $check_type, recipients => $notificationRecipients, host => $notificationHost, svc => $notificationService, hgs => $notificationHostgroups, sgs => $notificationServicegroups, dbresult => \%dbResult}), 3);

    my $cnt = 0;
    my %notifyList;
    my @recipients = split(",",$notificationRecipients);
    my @hostgroups = split(",",$notificationHostgroups);
    my @servicegroups = split(",",$notificationServicegroups);
    my @customvariables = split(",",$notificationCustomvariables);
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
    my $cvCount = @customvariables;
    if($cvCount < 1) {
        $customvariables[0] = "__NONE";
    }

    # BEGIN - generate include and exclude lists for hosts and services

    while ( my $res = $dbResult{$cnt++})
    {

	my $matched;

	# Implicit include means that we match if the include field is blank, except for customvariables!
	$res->{recipients_include} = '*' if !$res->{recipients_include};
	$res->{servicegroups_include} = '*' if !$res->{servicegroups_include};
	$res->{services_include} = '*' if !$res->{services_include};
	$res->{hostgroups_include} = '*' if !$res->{hostgroups_include};
	$res->{hosts_include} = '*' if !$res->{hosts_include};
	$res->{recipients_exclude} = '' if !$res->{recipients_exclude};
	$res->{servicegroups_exclude} = '' if !$res->{servicegroups_exclude};
	$res->{services_exclude} = '' if !$res->{services_exclude};
	$res->{hostgroups_exclude} = '' if !$res->{hostgroups_exclude};
	$res->{hosts_exclude} = '' if !$res->{hosts_exclude};
	$res->{customvariables_include} = '' if !$res->{customvariables_include};
	$res->{customvariables_exclude} = '' if !$res->{customvariables_exclude};

	# generate recipients list
	foreach my $recipient(@recipients) {
            if (!$recipient
				or (matchString($res->{recipients_include}, $recipient)
					and !matchString($res->{recipients_exclude}, $recipient)))
            {
                debug( "Step1: RecipientIncl: $recipient\t" . $res->{id}, 2);
                $matched = 1;
            }

	}
	next unless $matched;

	# If there is a customvariable to process 
	if ($cvCount > 0){
		$matched = 0;
            # generate customvariable list
            foreach my $customvariable(@customvariables) {
                if (!$customvariable or ($customvariable eq '__NONE')
                                        or (matchString($res->{customvariables_include}, $customvariable)
                                                and !matchString($res->{customvariables_exclude}, $customvariable)))
                {
                    debug( "Step1: CstVars: $customvariable\t" . $res->{id}, 2);
                    $matched = 1;
                }

            }
                        next unless $matched;

	}

	# If its a service(group) check.
        if ( $check_type eq 's' )
        {

			$matched = 0;
            # generate servicegroup list
            foreach my $servicegroup(@servicegroups) {
                if (!$servicegroup or ($servicegroup eq '__NONE')
					or (matchString($res->{servicegroups_include}, $servicegroup)
						and !matchString($res->{servicegroups_exclude}, $servicegroup)))
                {
                    debug( "Step1: SvcGrp: $servicegroup\t" . $res->{id}, 2);
                    $matched = 1;
                }

            }
			next unless $matched;
	}
	# generate hostgroup list
		$matched = 0;
        foreach my $hostgroup(@hostgroups) {
            if (!$hostgroup or ($hostgroup eq '__NONE')
				or (matchString($res->{hostgroups_include}, $hostgroup)
					and !matchString($res->{hostgroups_exclude}, $hostgroup)))
            {
		debug( "Step1: HostGrp: $hostgroup\t" . $res->{id}, 2);
                $matched = 1;
            }

        }

		next unless $matched;

		$matched = 0;
        # generate host list
        if (!$notificationHost
			or (matchString($res->{hosts_include}, $notificationHost)
				and !matchString($res->{hosts_exclude}, $notificationHost)))
        {
            debug( "Step1: Host: $notificationHost\t" . $res->{id}, 2);
            $matched = 1;
        }

		next unless $matched;

        if ( $check_type eq 's' )
        {
			$matched = 0;
            # generate service list
            if (!$notificationService
				or (matchString($res->{services_include}, $notificationService)
					and !matchString($res->{services_exclude}, $notificationService)))
            {
                debug( "Step1: Service: $notificationService\t" . $res->{id}, 2);
                $matched = 1;
            }


        }

		next unless $matched;

		$notifyList{ $res->{id} } = 1;

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
                debug("Step2: notifyIncl: $notifyIncl", 2);
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

# given a list of rules, the notification counter, and the type
# it returns an array of contacts to notify
#
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
			'select distinct c.username, c.phone, c.mobile, c.growladdress, c.email, tz.timezone, m.id mid, m.method, m.command, m.contact_field, m.sender, m.on_fail, m.ack_able, n.notify_after_tries, n.let_notifier_handle, n.id rule from notifications n
			left join notifications_to_methods nm on n.id=nm.notification_id
			left join notification_methods m on m.id=nm.method_id
			left join notifications_to_contacts nc on n.id=nc.notification_id
			left join contacts c on c.id=nc.contact_id
			left join timezones tz on c.timezone_id=tz.id
			where n.active=\'1\' and (n.id=\'' . $where . '\')';

		@dbResult_not_arr = queryDB( $query, 1 );

		$where =~ s/n\.id/ec\.notification_id/g;

		$query =
			'select distinct c.username, c.phone, c.mobile, c.growladdress, c.email, tz.timezone, m.id mid, m.method, m.command, m.contact_field, m.sender, m.on_fail, m.ack_able, ec.notify_after_tries, n.let_notifier_handle, n.id rule from escalations_contacts ec
			left join escalations_contacts_to_contacts ecc on ec.id=ecc.escalation_contacts_id
			left join contacts c on c.id=ecc.contacts_id
			left join escalations_contacts_to_methods ecm on ec.id=ecm.escalation_contacts_id
			left join notification_methods m on ecm.method_id=m.id
			left join timezones tz on c.timezone_id=tz.id
			left join notifications n on ec.notification_id=n.id
			where n.active=\'1\' and (ec.notification_id=\'' . $where . '\')';

		@dbResult_esc_arr = queryDB( $query, 1 );

		@dbResult_tmp_arr = ( @dbResult_not_arr, @dbResult_esc_arr );
		@dbResult_arr =
		filterNotificationsByEscalation( \@dbResult_tmp_arr, $notificationCounter, $notification_type, $status );


		debug("To be notified: ".Dumper(@dbResult_arr), 3);

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
	my @ignoreCGs;
	my $notcg = '';
	my $query;

	# get count of notification id's
	my $ids_cnt = @$ids;

	if ($ids_cnt)
	{

		if ( $ids_cnt == 1 )
		{

			my $query_temp = 'select ncg.contactgroup_id from notifications_to_contactgroups ncg where ncg.notification_id=\''.$ids->[0].'\'';
			my %dbResult_temp = queryDB($query_temp);
			foreach my $cg (keys %dbResult_temp )
			{
				if(contactgroupInTimeFrame($dbResult_temp{$cg}->{contactgroup_id}) eq 0)
				{
					debug(' Contactgroup ID to exclude from queries: '.$dbResult_temp{$cg}->{contactgroup_id},2);
					push(@ignoreCGs, $dbResult_temp{$cg}->{contactgroup_id});
				}
			}
			$query_temp = 'select eccg.contactgroup_id from escalations_contacts ec left join escalations_contacts_to_contactgroups eccg on ec.id=eccg.escalation_contacts_id where ec.notification_id=\''.$ids->[0].'\'';
			%dbResult_temp = queryDB($query_temp);
			foreach my $cg (keys %dbResult )
			{
				if(contactgroupInTimeFrame($dbResult_temp{$cg}->{contactgroup_id}) eq 0)
				{
					debug(' Contactgroup ID to exclude from queries: '.$dbResult_temp{$cg}->{contactgroup_id},2);
					push(@ignoreCGs, $dbResult_temp{$cg}->{contactgroup_id});
				}
			}

			$where = $ids->[0];
		}
		else
		{
			my $query_temp = 'select ncg.contactgroup_id from notifications_to_contactgroups ncg where ncg.notification_id=\''.$ids->[0].'\'';
			my %dbResult_temp = queryDB($query_temp);
			foreach my $cg (keys %dbResult )
			{
				if(contactgroupInTimeFrame($dbResult_temp{$cg}->{contactgroup_id}) eq 0)
				{
					debug(' Contactgroup ID to exclude from queries: '.$dbResult_temp{$cg}->{contactgroup_id},2);
					push(@ignoreCGs, $dbResult_temp{$cg}->{contactgroup_id});
				}
			}
			$query_temp = 'select eccg.contactgroup_id from escalations_contacts ec left join escalations_contacts_to_contactgroups eccg on ec.id=eccg.escalation_contacts_id where ec.notification_id=\''.$ids->[0].'\'';
			%dbResult_temp = queryDB($query_temp);
			foreach my $cg (keys %dbResult )
			{
				if(contactgroupInTimeFrame($dbResult_temp{$cg}->{contactgroup_id}) eq 0)
				{
					debug(' Contactgroup ID to exclude from queries: '.$dbResult_temp{$cg}->{contactgroup_id},2);
					push(@ignoreCGs, $dbResult_temp{$cg}->{contactgroup_id});
				}
			}
			$where = join( '\' or n.id=\'', @$ids );
		}

		# get count of contactgroups to ignore.
		my $ignoreCGs_cnt = @ignoreCGs;

		if ( $ignoreCGs_cnt == 1)
		{
			$notcg = $ignoreCGs[0];
		}
		else
		{
			$notcg = join( '\' or eccg.contactgroup_id<>\'', @ignore_cgs);
		}


		# get contactgroups of ID's
		# figure out what ID's NOT to select.

		# query db for contacts
		$query =
			'select distinct c.username, c.phone, c.mobile, c.growladdress, c.email, tz.timezone, m.id mid, m.method, m.command, m.contact_field, m.sender, m.on_fail, m.ack_able, n.notify_after_tries, n.let_notifier_handle, n.id rule from notifications n
			left join notifications_to_methods nm on n.id=nm.notification_id
			left join notification_methods m on m.id=nm.method_id
			left join notifications_to_contactgroups ncg on n.id=ncg.notification_id
			left join contactgroups cg on ncg.contactgroup_id=cg.id
			left join contactgroups_to_contacts cgc on cgc.contactgroup_id=cg.id
			left join contacts c on c.id=cgc.contact_id
			left join timezones tz on c.timezone_id=tz.id
			where cg.view_only=\'0\' and n.active=\'1\' and (n.id=\'' . $where . '\') and (ncg.contactgroup_id<>\'' . $notcg . '\')';

		@dbResult_not_arr = queryDB( $query, 1 );

		$where =~ s/n\.id/ec\.notification_id/g;
		$where =~ s/ncg\.contactgroup_id/eccg\.contactgroup_id/g;

		$query =
			'select distinct c.username, c.phone, c.mobile, c.growladdress, c.email, tz.timezone, m.id mid, m.method, m.command, m.contact_field, m.sender, m.on_fail, m.ack_able, ec.notify_after_tries, n.let_notifier_handle, n.id rule from escalations_contacts ec
			left join escalations_contacts_to_contactgroups eccg on ec.id=eccg.escalation_contacts_id
			left join contactgroups_to_contacts cgc on eccg.contactgroup_id=cgc.contactgroup_id
			left join contacts c on cgc.contact_id=c.id
			left join escalations_contacts_to_methods ecm on ec.id=ecm.escalation_contacts_id
			left join notification_methods m on m.id=ecm.method_id
			left join timezones tz on c.timezone_id=tz.id
			left join notifications n on ec.notification_id=n.id
			left join contactgroups cg on cgc.contactgroup_id=cg.id
			where cg.view_only=\'0\' and n.active=\'1\' and (ec.notification_id=\'' . $where . '\')  and (eccg.contactgroup_id<>\'' . $notcg . '\')';

		@dbResult_esc_arr = queryDB( $query, 1 );
		@dbResult_tmp_arr = ( @dbResult_not_arr, @dbResult_esc_arr );

		@dbResult_arr =
			filterNotificationsByEscalation( \@dbResult_tmp_arr, $notificationCounter, $notification_type, $status );


		debug("To be notified: ".Dumper(@dbResult_arr), 3);

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
        $query = 'select h.holiday_start,h.holiday_end from holidays h
					left join contacts c on c.id=h.contact_id
					where c.username=\'' . $contacts{$contact}->{username} . '\'';

        my @dbResult = queryDB($query, '1');

	# set timezone
	my $tz = DateTime::TimeZone->new( name =>  $contacts{$contact}->{timezone});
	my $dt = DateTime->now()->set_time_zone($tz);

        # check person's holiday data
	if (datetimeInPeriod(\@dbResult, $dt->ymd." ".$dt->hms))
        {
		debug(  "username: ".$contacts{$contact}->{username}." (GMT+".$dt->offset($dt)."s) on holiday, dropping", 2);
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
	    if ( (objectInTimeFrame($dbResult{0}->{timeframe_id},'contacts') eq 0 ))
	    {
		debug( "username: ".$contacts{$contact}->{username}." outside timeframe, dropping", 2);
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

    debug('filter: '.$filter.' notification_type: '.$notification_type.' status: '.$status, 2);
    debug("dbResult_arr Array: ".Dumper($dbResult_arr), 3);

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

    debug('filter2: '.$filter, 2);

    # apply filter
    foreach my $row (@$dbResult_arr)
    {
	debug('row: '.Dumper($row), 3);
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

    debug('return_arr: '.Dumper(@return_arr), 2);

    return @return_arr;

}

sub getMaxValue
{
    # given a range string, return the maximum
    # e.g. 1-4,7-8,12
	my ($range) = @_;

    my $min;
    my $max;

	$range =~ s/[^0-9,;-]//g;

    return $range unless ($range =~ /[,;-]+/);

    my $newmax = 1;
    foreach my $crange (split(/[,;]/, $range))
    {
		if ($crange =~ /-/)
		{
			debug("Expanding $crange", 3);
			$crange =~ /(\d*)-(\d*)/;

			$min = $1;
			$max = $2;

			if ((not defined($min)) or ($min < 1))
			{
				debug("Invalid minimum value in range \"$crange\" - setting to 1", 1);
				$min = 1;
			}

			if ((not defined($max)) or ($max < $min))
			{
				debug("Invalid maximum value in range \"$crange\" - setting to 99999", 1);
				$max = 99999;
			}
		} else {
            debug("Testing $crange", 3);
            $max = $crange;
        }


        $newmax = $max if ($max > $newmax);
    }

    return $newmax;
}

1;
