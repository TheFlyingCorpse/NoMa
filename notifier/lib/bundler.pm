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

use threads;
use Thread::Queue;
use FindBin;
use lib "$FindBin::Bin";
use database;
# use DBI;
use Data::Dumper;


sub sendNotifications
{

    my ( $queue, $config ) = @_;
    # my $delay = $$config{delay};
    my $bundle = $$config{bundle};
    my %dbResult;
    my @toNotify;
    my @ids;
    my @toDelete;
    my %recipients;
    my $param;

    # select notifications due to be executed that are not currently in progress and that have not already been bundled
    # N.B. a bundled notification will also appear here as a notification with a separate field.
    my $query = 'select a.id,notify_id,dest,from_user,time_string,user,method,notify_cmd,retries,rule, external_id,host,host_alias,host_address,service,check_type,status,a.stime,notification_type,output from tmp_active as a left join tmp_commands as c on a.command_id=c.id where progress=\'0\' and bundled = \'0\' and a.stime <= \''.time().'\'';
    %dbResult = queryDB($query, undef, 1);

    return unless (keys(%dbResult));


    foreach my $index (keys %dbResult)
    {

        # select everything
        push @toNotify, $index;
        push @ids, $dbResult{$index}{notify_id};
    }

    if ($bundle)
    {



        # generate a list of contact/method pairs to notify
        foreach my $item (@toNotify)
        {

            # save all relevant data in case there is no bundling required
            # N.B. set the count to 0 because we are counting in the next stage
            $recipients{$dbResult{$item}{dest}}{$dbResult{$item}{notify_cmd}}{count} = 0;
            $recipients{$dbResult{$item}{dest}}{$dbResult{$item}{notify_cmd}}{from_user} = $dbResult{$item}{from_user};
			$recipients{$dbResult{$item}{dest}}{$dbResult{$item}{notify_cmd}}{dest} = $dbResult{$item}{dest};
			$recipients{$dbResult{$item}{dest}}{$dbResult{$item}{notify_cmd}}{check_type} = $dbResult{$item}{check_type};
			$recipients{$dbResult{$item}{dest}}{$dbResult{$item}{notify_cmd}}{stime} = $dbResult{$item}{stime};
			$recipients{$dbResult{$item}{dest}}{$dbResult{$item}{notify_cmd}}{status} = $dbResult{$item}{status};
			$recipients{$dbResult{$item}{dest}}{$dbResult{$item}{notify_cmd}}{notification_type} = $dbResult{$item}{notification_type};
			$recipients{$dbResult{$item}{dest}}{$dbResult{$item}{notify_cmd}}{host} = $dbResult{$item}{host};
			$recipients{$dbResult{$item}{dest}}{$dbResult{$item}{notify_cmd}}{service} = $dbResult{$item}{service};
			$recipients{$dbResult{$item}{dest}}{$dbResult{$item}{notify_cmd}}{host_alias} = $dbResult{$item}{host_alias};
			$recipients{$dbResult{$item}{dest}}{$dbResult{$item}{notify_cmd}}{host_address} = $dbResult{$item}{host_address};
			$recipients{$dbResult{$item}{dest}}{$dbResult{$item}{notify_cmd}}{output} = $dbResult{$item}{output};
			$recipients{$dbResult{$item}{dest}}{$dbResult{$item}{notify_cmd}}{notify_id} = $dbResult{$item}{notify_id};

        }

        # now repeat the query without the time restriction to fetch any other notifications that have been queued

        my $query2 = 'select a.id,notify_id,dest,from_user,time_string,user,method,notify_cmd,retries,rule, external_id,host,host_alias,host_address,service,check_type,status,a.stime,notification_type,output from tmp_active as a left join tmp_commands as c on a.command_id=c.id where progress=\'0\' and bundled <= \'0\'';
        my %res = queryDB($query2, undef, 1);

        foreach my $index (keys %res)
        {

            # retrieve anything where the hash is already defined
            if (defined($recipients{$res{$index}{dest}}{$res{$index}{notify_cmd}}{count}))
            {
                # 
                # updateLog($dbResult{$item}{notify_id}, ", bundling");
                $recipients{$res{$index}{dest}}{$res{$index}{notify_cmd}}{count}++;
                push @{ $recipients{$res{$index}{dest}}{$res{$index}{notify_cmd}}{ids} }, $res{$index}{notify_id};

                # create a bundled message
                # TODO: this should really be supported in the individual scripts
                # TODO: make the text configurable
                $recipients{$res{$index}{dest}}{$res{$index}{notify_cmd}}{multi_message} .=
                    ' '.$res{$index}{host}.'/'.$res{$index}{service}.' is '.$res{$index}{status}."\n";
            }
        }



        foreach my $user (keys %recipients)
        {

            my $uref = $recipients{$user};

            foreach my $cmd (keys %$uref)
            {
                # only bundle if more than 1 alert for a single destination is outstanding
                next unless defined($recipients{$user}{$cmd}{count});
		if ($recipients{$user}{$cmd}{count} < 2 or $cmd ne 'voicecall')
                {
                    #
		    debug(" ---> Single alert ($cmd)\n");
                    $param = sprintf(
                "\"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\"",
                        $recipients{$user}{$cmd}{from_user},
                        $recipients{$user}{$cmd}{dest},
                        $recipients{$user}{$cmd}{check_type},
                        $recipients{$user}{$cmd}{stime},
                        $recipients{$user}{$cmd}{status},
                        $recipients{$user}{$cmd}{notification_type},
                        $recipients{$user}{$cmd}{host},
                        $recipients{$user}{$cmd}{host_alias},
                        $recipients{$user}{$cmd}{host_address},
                        $recipients{$user}{$cmd}{output});

                    $param .= ' "'.$recipients{$user}{$cmd}{service}.'"' if ( $recipients{$user}{$cmd}{check_type} eq 's' );

                    updateLog($recipients{$user}{$cmd}{notify_id}, ", single alert");
                    # queue notification "host + service is output"
                    my @tmp = ($recipients{$user}{$cmd}{notify_id});
                    setProgressFlag(\@tmp);
                    $queue->{$cmd}->enqueue($recipients{$user}{$cmd}{notify_id}.';'.$recipients{$user}{$cmd}{stime}.';1;'.$param);
                }
                else
                {

	    debug(" ---> Bundle alert\n");
                # create a new notify ID for this bundle
                my $notify_id = unique_id();

                # mark all the constituent parts as in_progress
                my @tmp =  $recipients{$user}{$cmd}{ids};
                addToBundle($notify_id, @tmp);
                setProgressFlag(@tmp);


                # $recipients{$user}{$cmd}{multi_message} = $recipients{$user}{$cmd}{count}." alerts: ".$recipients{$user}{$cmd}{multi_message};

                my $now = time();
                # create a fake command
                $sql = sprintf('insert into tmp_commands (operation, external_id, host, host_alias, host_address, service, check_type, status, stime, notification_type, output) values (\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\')',
                    'NOTIFICATION',
                    $notify_id,
                    'multiple alerts',
                    'multiple alerts',
                    '127.0.0.1',
                    'nosvc',
                    's',
                    'WARNING',
                    $now,
                    'PROBLEM',
                    $recipients{$user}{$cmd}{multi_message});
                updateDB($sql);
                
                # add the bundled command to the tmp_active table as a new notification WITHOUT delay
                prepareNotification($notify_id, '(bundler)', 'Bundled', $cmd, $user, $recipients{$user}{$cmd}{from_user}, $notify_id, $now,
'h', 'WARNING','PROBLEM', 'multiple alerts',     'multiple alerts', '127.0.0.1', 'nosvc', $recipients{$user}{$cmd}{multi_message}, '0', 1);

                # now create the actual alert
                
                $param = sprintf(
                    "\"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\"",
                    $recipients{$user}{$cmd}{from_user},
                    $user,
                    'PROBLEM',
                    $now,
                    'WARNING', # TODO this may be wrong
                    's',
                    'multiple alerts',
                    'multiple alerts',
                    '127.0.0.1',
                    $recipients{$user}{$cmd}{multi_message},
                    $recipients{$user}{$cmd}{count});

                my $start = time(); # what should the time be? earliest or latest?
                # queue notification (concat notify_id '/'), "There are count messages: " + message
                setProgressFlag([$notify_id]);
                $queue->{$cmd}->enqueue("$notify_id;$start;1;$param");
                debug("enqueue to $cmd: $notify_id;$start;1;$param");
                }
            }
        }
    } else {

        # flag that we are processing an alert to avoid multiple voice alerts :-)
        setProgressFlag(\@ids);
        foreach my $item (@toNotify)
        {
            $param = sprintf(
                "\"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\"",
                $dbResult{$item}{from_user},
                $dbResult{$item}{dest},
                $dbResult{$item}{check_type},
                $dbResult{$item}{stime},
                $dbResult{$item}{status},
                $dbResult{$item}{notification_type},
                $dbResult{$item}{host},
                $dbResult{$item}{host_alias},
                $dbResult{$item}{host_address},
                $dbResult{$item}{output});

            $param .= ' "'.$dbResult{$item}{service}.'"' if ( $dbResult{$item}{check_type} eq 's' );

            updateLog($dbResult{$item}{notify_id}, ", single alert");
            # queue notification "host + service is output"
            debug("no bundle enqueue");
            $queue->{$dbResult{$item}{notify_cmd}}->enqueue($dbResult{$item}{notify_id}.';'.$dbResult{$item}{stime}.';1;'.$param);
        }
    }
    




# 	# create parameter (FROM DESTINATION CHECK-TYPE DATETIME STATUS NOTIFICATION-TYPE HOST-NAME HOST-ALIAS HOST-IP OUTPUT [SERVICE])
# 	my $param = sprintf(
# "\"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\"",
# 	    $from,  $dest,    $check_type,
# 	    $datetime, $status,     $notification_type,
# 	    $host,     $host_alias, $host_address,
# 	    $output
# 	);
# 	$param .= " \"$service\"" if ( $check_type eq 's' );
# 
# 	debug("$whoami: BEFORE call - $method  $param");
# 
# 
}

# tag the individual elements as being part of the bundle
sub addToBundle
{
    my ($bunid, $arrptr) = @_;
    my $list;


    $list = join(',', @$arrptr);
    debug("adding $list to bundle $bunid\n");
    updateDB("update tmp_active set bundled='".$bunid."' where notify_id in (".$list.")");
}

# check if the ID is part of a bundle
sub is_a_bundle
{
    my ($bunid) = @_;


    # debug("Checking if $bunid is bundled\n");
    my %dbResult = queryDB("select count(*) as count from tmp_active where bundled=\"".$bunid."\"");

    return 0 unless (defined($dbResult{0}->{count}) and ($dbResult{0}->{count} > 0));
    debug("$bunid is bundled (".$dbResult{0}->{count}." alerts)");
    return 1;
}

# return a list of IDs that were in a bundle and remove the tag
sub unbundle
{
    my ($bunid) = @_;
    my @tmp;

    my %dbResult = queryDB("select notify_id from tmp_active where bundled=\"".$bunid."\"");
    updateDB("update tmp_active set bundled=\"0\" where bundled=\"".$bunid."\"");
    updateDB("delete from tmp_commands where external_id=\"".$bunid."\"");

    foreach my $key (keys %dbResult)
    {
        push @tmp, $dbResult{$key}{notify_id};
    }
    debug("unbundle returned ".join(',',@tmp));
    return @tmp;
}

# set the progress flag
sub setProgressFlag
{
    my ($arrptr) = @_;
    my $list;


    $list = join(',', @$arrptr);
    debug("setting progress flag for $list");
    updateDB("update tmp_active set progress='1' where notify_id in (".$list.")");
}

sub suppressionIsActive
{
    # check that the notification method isn't currently being suppressed
    my ($cmd, $length) = @_;
    # debug("Suppression hash is ".Dumper(%suppressionHash));
    # debug("Suppression cmd: $cmd, len: $length");

    return 0 unless (defined($length) and ($length > 0));

    if ($suppressionHash{$cmd} and ($suppressionHash{$cmd} + ($length * 60)) > time())
    {
        return 1;
    }
    return 0;

}


1;
