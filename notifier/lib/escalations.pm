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
    my ($host, $svc, $rule, $flag) = @_;

    $counter = 0 unless defined($flag);

    my $query = 'select counter from escalation_stati where'.
        ' host=\''.$host.'\''.
        ' and notification_rule=\''.$rule.'\'';

    debug("service is \"$svc\"", 2);
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


sub clearEscalationCounter
{

    my ( $host, $svc ) = @_;

    my $query = 'delete from escalation_stati
			where host=\''.$host.'\'';
                
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



sub createEscalationCounter
{
    my ($esc_rule, %eventh) = @_;
#        $incident_id, $host, $host_alias,
#        $host_address, $service,     $check_type,
#        $status,       $datetime,    $notification_type,
#        $output

    my $query =
            sprintf('insert into escalation_stati (notification_rule,starttime,counter,incident_id,recipients,host,host_alias,host_address,hostgroups,service,servicegroups,check_type,status,time_string,type,authors,comments,output) values (\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\')',
            $esc_rule,time(),
            '1',$eventh{external_id},$eventh{recipients},
            $eventh{host},$eventh{host_alias},$eventh{host_address},$eventh{hostgroups},$eventh{service},$eventh{servicegroups},
            $eventh{check_type},$eventh{status},$eventh{stime},$eventh{notification_type},$eventh{authors},$eventh{comments},$eventh{output});

    updateDB($query);


}


sub deleteFromEscalations
{
	my ($id) = @_;

	return unless (defined($id) and $id > 0);
	my $query = 'delete from escalation_stati';
    $query .= " where incident_id=$id" if $id;

	updateDB($query);
}

sub escalate
{
    my ($cmdq, $conf) = @_;
    my $query;
    my %dbResult;
    my @dbResult;
    my $cmd;
    my $wait = 60;
    my $maxwait = 7200;

    $wait = $conf->{timeToWait}
      if (defined($conf->{timeToWait}));
    $maxwait = $conf->{stopAfter}
      if (defined($conf->{stopAfter}));


    # retrieve all incidents where an escalation exists in the stati table but no alerts are active, using time (UTC epoch, not local!)
    $query = 'select distinct id from escalation_stati where incident_id not in (select external_id from tmp_commands as c inner join tmp_active as a on a.command_id=c.id) and (time_string+(counter*'.$wait.'))<'.time();
    $query .= ' and time_string>('.time().'-'.$maxwait.')' if ($wait > 0);
    debug('Escalate query: '.$query,3);
    @dbResult = queryDB($query, 1, 1);

    foreach my $res (@dbResult)
    {
      # increase the counter
      # $query = "update escalation_stati set counter=counter+1 where id='".$res->{id}."'";
      # %dbResult = updateDB($query);

      $query = 'select incident_id,recipients,host,host_alias,host_address,hostgroups,service,servicegroups,check_type,status,time_string,type,authors,comments,output from escalation_stati where id=\''.$res->{id}.'\'';
      %dbResult = queryDB($query);

      debug('incident with escalation without alert active, dbResult: '.Dumper(\%dbResult),3);

      # Make a command for escalation notification.
      $cmd = 'escalation;'.$dbResult{0}{incident_id}.';'.$dbResult{0}{recipients}.";".$dbResult{0}{host}.";".$dbResult{0}{host_alias}.';'.$dbResult{0}{host_address}.';'.$dbResult{0}{hostgroups}.';'.$dbResult{0}{service}.';'.$dbResult{0}{servicegroups}.';'.$dbResult{0}{check_type}.';'.$dbResult{0}{status}.';'.$dbResult{0}{time_string}.';'.$dbResult{0}{type}.';'.$dbResult{0}{authors}.';'.$dbResult{0}{comments}.';'.$dbResult{0}->{output};

      debug('incident with escalatiion without active alert, $cmd: '.$cmd,2);

      $cmdq->enqueue($cmd);
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
    return () if scalar @$ids < 1;

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
    return () if scalar @$ids < 1;

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


sub getNextMethod
{

    # get params
    my ( $notify_id ) = @_;
    my $query;
    my $next_id;
    my $method;
    my $command;
    my $sender;
    my $tofield;
    my $to;

	debug("getting next method for notify id $notify_id", 3);
    # get next escalation method
    $query =
      sprintf(
'select id, method, command, sender, contact_field from notification_methods where id = (select m.on_fail from notification_methods m left join notification_logs as l on l.last_method=m.id where l.unique_id=\'%s\')',
	$notify_id);
    my %dbResult = queryDB($query);

    ($next_id, $method, $command, $sender, $tofield) = ($dbResult{0}->{id}, $dbResult{0}->{method}, $dbResult{0}->{command}, $dbResult{0}->{sender}, $dbResult{0}->{contact_field});
    return (0, '/bin/true') if (!defined($next_id) or $next_id == 0);

    $query = sprintf('select %s from contacts as c, notification_logs as l where c.username=l.user and l.unique_id=\'%s\'', $tofield, $notify_id);
    %dbResult = queryDB($query);
    $to = $dbResult{0}->{$tofield};

    $query = sprintf('update notification_logs set last_method=\'%s\' where unique_id=\'%s\'', $next_id, $notify_id);
    updateDB($query);

    return ($next_id, $method, $command, $sender, $to);

}

sub getRetryCounter
{

    # get params
    my ( $notify_id ) = @_;
    my $query;
    my $counter;

    $query = sprintf('select retries from tmp_active where notify_id = \'%s\'', $notify_id);
    my %dbResult = queryDB($query);

    $counter = $dbResult{0}->{retries};
    return 0 if (!defined($counter));

    return $counter;

}

sub requeueNotification
{
	# get params
	my ( $id ) = @_;
	my $query;
	my %dbResult;
	my $counter = 0;
	my ($ss,$mm,$hh) = localtime();

	# log the retry
	updateLog($id, " failed ($hh:$mm:$ss). Retrying. ");

    # if there is no configured retry delay, add 60 to the start time
    my $wait = $conf->{notifier}->{timeToWait};
    $wait = 60 unless defined($wait);

	# increment counter
	$query = sprintf('update tmp_active set retries=retries+1,
                        stime=\'%s\', progress=\'0\' where notify_id=\'%s\'', 
                        time()+$wait, $id);
	updateDB($query);
}

sub getNextMethodCmd
{

    # get params
    my ( $notify_id, $method_id ) = @_;
    my %dbResult;
    my %dbResult2;
    my $query;


	$query = sprintf('select distinct n.counter, m.contact_field, m.method, n.user, n.incident_id, n.notification_rule, m.id as last_method, m.command, c.email, m.sender, t.check_type, t.status, t.type, t.host, t.host_alias, t.host_address, t.service, t.output, n.timestamp from tmp_active as t left join notification_logs as n on n.unique_id=t.notify_id left join contacts as c on c.username=n.user, notification_methods as m where n.unique_id=t.notify_id and t.notify_id=\'%s\' and m.id=\'%s\'', $notify_id, $method_id);
    	
    %dbResult = queryDB( $query );
    
    $query = sprintf('select %s from contacts where username=\'%s\'', $dbResult{0}{contact_field}, $dbResult{0}{user});
    %dbResult2 = queryDB( $query );

    # call prepareNotification and return result
    #
    

    my $cline = prepareNotification($dbResult{0}{user}, $dbResult{0}{method}, $dbResult{0}{command},
	    $dbResult2{0}{$dbResult{0}{contact_field}}, $dbResult{0}{sender}, $notify_id, 
	    $dbResult{0}{timestamp},$dbResult{0}{check_type}, $dbResult{0}{status}, 
	    $dbResult{0}{type}, $dbResult{0}{host},$dbResult{0}{host_alias}, 
	    $dbResult{0}{host_address}, $dbResult{0}{hostgroups}, $dbResult{0}{service}, 
	    $dbResult{0}{servicegroups}, $dbResult{0}{authors},$dbResult{0}{comments}, $dbResult{0}{output});
    return $cline;

}


1;
