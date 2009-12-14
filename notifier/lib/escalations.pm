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


sub getEscalationCounter
{
    my ($host, $svc, $rule) = @_;
    my $counter;

    my $query = 'select counter from escalation_stati where'.
        ' host=\''.$host.'\''.
        ' and notification_rule=\''.$rule.'\'';

    debug("service is \"$svc\"");
    if (defined($svc) and $svc ne '')
    {
        # service alert
        $query .= ' and service=\''.$svc.'\'';
    }
    else
    {
        $query .= ' and check_type=\'h\'';
    }

    my %dbResult = queryDB($query);

    $counter = $dbResult{0}->{counter}
      if ( defined( $dbResult{0}->{counter} ) );

    return $counter;


}

sub incrementEscalationCounter
{
    # N.B. no return value needed
    
    my ($host, $svc, $rule) = @_;
    my $query = 'update escalation_stati set counter=counter+1 where'.
        ' host=\''.$host.'\''.
        ' and notification_rule=\''.$rule.'\'';

    if (defined($svc) and $svc ne '')
    {
        # service alert
        $query .= ' and service=\''.$svc.'\'';
    }
    else
    {
        $query .= ' and check_type=\'h\'';
    }

    updateDB($query);

}

sub resetEscalationCounter
{
    
    my ($host, $svc, $rule) = @_;
    my $query = 'update escalation_stati set counter=1 where'.
        ' host=\''.$host.'\''.
        ' and notification_rule=\''.$rule.'\'';

    if (defined($svc) and $svc ne '')
    {
        # service alert
        $query .= ' and service=\''.$svc.'\'';
    }
    else
    {
        $query .= ' and check_type=\'h\'';
    }

    updateDB($query);
    return 1;

}

sub createEscalationCounter
{
    my (
        $esc_rule,
        $incident_id, $host, $host_alias,
        $host_address, $service,     $check_type,
        $status,       $datetime,    $notification_type,
        $output
    ) = @_;

    my $query =
            'insert into escalation_stati ('.
            'notification_rule,starttime,counter,incident_id,host,'.
            'host_alias,host_address,service,check_type,status,'.
            'time_string,type,output'.
            ') values ('.
            "'$esc_rule','".time()."',".
            "'1','$incident_id',".
            "'$host','$host_alias','$host_address','$service',".
            "'$check_type','$status','$datetime','$notification_type','$output'".
            ')';

    updateDB($query);


}


sub deleteFromEscalations
{
	my ($id) = @_;

	my $query = 'delete from escalation_stati';
    $query .= " where incident_id=$id" if $id;

	updateDB($query);
}

sub escalate
{
    # given an unique_id, generate an escalation

    my ($unique_id) = @_;


    # from the unique id we can retrieve
    # the counter, rule, host, svc
    #

    my $query = '
        select counter,host,service,notification_rule from notification_logs where
        unique_id=\''.$unique_id.'\'';

    my %dbResult = queryDB($query);

    my $host = $dbResult{0}->{'host'};
    my $svc = $dbResult{0}->{'service'};
    my $rule = $dbResult{0}->{'notification_rule'};
    my $counter = $dbResult{0}->{'counter'};

    if (!(defined($counter)))
    {
        # something went badly wrong
        debug("error escalating $unique_id, counter not found");
        return;
    }

    if (getEscalationCounter($host, $svc, $rule) <= $counter)
    {
        # prevent multiple escalations when multiple methods are selected
        # we parse results sequentially anyway so races cannot occur
        incrementEscalationCounter($host, $svc, $rule);

        $query = '
        select * from escalation_stati where'.
            ' host=\''.$host.'\''.
            ' and notification_rule=\''.$rule.'\'';

        if (defined($svc) and $svc ne '')
        {
            # service alert
            $query .= ' and service=\''.$svc.'\'';
        }
        else
        {
            $query .= ' and check_type=\'h\'';
        }

        my %dbResult = queryDB($query);

        my $cmdline = 
            $host.';'.
            $dbResult{0}->{'host_alias'}.';'.
            $dbResult{0}->{'host_address'}.';'.
            $svc.';'.
            $dbResult{0}->{'check_type'}.';'.
            $dbResult{0}->{'status'}.';'.
            $dbResult{0}->{'time_string'}.';'.
            $dbResult{0}->{'type'}.';'.
            $dbResult{0}->{'output'};


        $escq->enqueue(time().';'.$dbResult{0}->{'time_string'}.';'.$cmdline);
    }
}


sub needToEscalateUniqueID
{
    # returns true if the alert should be internally escalated

    my ($id) = @_;

    # global escalations?
    return 1 if ($ignore);

    # there may be more than one unique id for a rule so
    # convert unique id to a host/service/notification_rule triplet
    my $query = 'select es.id as id from escalation_stati as es,notification_logs as l where '.
        'es.host=l.host and es.service=l.service and '.
        'es.notification_rule=l.notification_rule and l.unique_id=\''.$id.'\'';

    # set for this ID?
    # if there is an entry in the escalation_stati table then yes
    #


    my %dbResult = queryDB($query);

    return 1 if (defined($dbResult{0}->{'id'}));
    return 0;
}



sub getUnhandledRules
{
    # given an ID array, return those where NoMa doesn't handle escalations
    #

    my ($ids) = @_;

    # if global escalation is enabled, all rules are "handled"
    return () if ($conf->{'escalator'}->{'internalEscalation'} == 1);

    my $query = 'select id from notifications where let_notifier_handle=\'0\' and id in ('.join(',',@$ids).')';


    my @tmparr = queryDB($query, 1);
    my @tmparr2;

    foreach my $tmpvar (@tmparr)
    {
        push @tmparr2, $tmpvar->{'id'}
    }
    return @tmparr2;
}

sub getHandledRules
{
    # given an ID array, return those where NoMa handles escalations
    #

    my ($ids) = @_;

    my $query = 'select id from notifications where id in ('.join(',',@$ids).')';
    $query .= ' and let_notifier_handle=\'1\''
        unless ($conf->{'escalator'}->{'internalEscalation'} == 1);


    my @tmparr = queryDB($query, 1);
    my @tmparr2;

    foreach my $tmpvar (@tmparr)
    {
        push @tmparr2, $tmpvar->{'id'}
    }
    return @tmparr2;
}




1;
