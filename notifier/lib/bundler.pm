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
    my $query = 'select a.id,notify_id,dest,from_user,time_string,user,method,notify_cmd,retries,rule, external_id,host,host_alias,host_address,service,check_type,status,a.stime,notification_type,output from tmp_active as a left join tmp_commands as c on a.command_id=c.id where progress=\'0\' and bundled <= \'0\' and a.stime <= \''.time().'\'';
    %dbResult = queryDB($query, undef, 1);

    return unless (keys(%dbResult));


    foreach my $index (keys %dbResult)
    {
        # push @toNotify, $index if ($dbResult{$index}{stime} le (time()-$delay));

        # select everything
        push @toNotify, $index;
        push @ids, $dbResult{$index}{id};
    }

    setProgressFlag(\@ids);
    if ($bundle)
    {

        # generate a list of contact/method pairs to notify
        foreach my $item (@toNotify)
        {
            updateLog($dbResult{$item}{notify_id}, ", bundling");

            ## collect the IDs to delete
            #push @toDelete, $dbResult{$item}{notify_id};
    
            # bundle all messages to a particular destination by type
            my $bunref = $recipients{$dbResult{$item}{dest}}{$dbResult{$item}{notify_cmd}};
            $bunref->{count}++;
            $bunref->{from_user} = $dbResult{$item}{from_user};
            push @{ $bunref->{ids} }, $dbResult{$item}{notify_id};


            # create a bundled message
            # TODO: this should really be supported in the individual scripts
            # TODO: make the text configurable
            $recipients{$dbResult{$item}{dest}}{$dbResult{$item}{notify_cmd}}{message} .=
                ' '.$dbResult{$item}{host}.'/'.$dbResult{$item}{service}.' is '.$dbResult{$item}{status}."\n";
        }

        #foreach my $item (@toDelete)
        #{
        #    # delete the notifications from the tmp_active table because we have now bundled them
        #    # TODO: acknowledgements are not possible
        #    # TODO: consider flagging with a bundle ID
        #    deleteFromActive($item);
        #}


        


        foreach my $user (keys %recipients)
        {
            my $uref = $recipients{$user};

            foreach my $cmd (keys %$uref)
            {

                my $notify_id = unique_id();

                addToBundle($notify_id, $recipients{$user}{$cmd}{ids});

                # TODO: add the bundled command to the tmp_active table
                prepareNotification($notify_id, '(bundler)', 'Bundled', $cmd, $user, $recipients{$user}{$cmd}{from_user}, '12345', scalar(localtime()),
'h', $status,'PROBLEM', 'multiple alerts',     'multiple alerts', '0.0.0.0', 'nosvc', $recipients{$user}{$cmd}{message}, '0');

                
                $param = sprintf(
            "\"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\"",
                    $recipients{$user}{$cmd}{from_user},  $user,    'PROBLEM',
                    scalar(localtime()), 'WARNING',     'h',
                    'multiple alerts',     'multiple alerts', '0.0.0.0',
                    $recipients{$user}{$cmd}{message});

                my $start = time(); # what should the time be? earliest or latest?
                # queue notification (concat notify_id '/'), "There are count messages: " + message
                # $queue->{$cmd}->enqueue("$notify_id;$start;1;$param");
                print "enqueue to $cmd: $notify_id;$start;1;$param\n";
            }
        }
    } else {

        foreach my $item (@toNotify)
        {
            $param = sprintf(
        "\"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\"",
                 $dbResult{$item}{from_user},  $dbResult{$item}{dest}, $dbResult{$item}{check_type},
                $dbResult{$item}{stime}, $dbResult{$item}{status},     $dbResult{$item}{notification_type},
                $dbResult{$item}{host},     $dbResult{$item}{host_alias}, $dbResult{$item}{host_address},
                $dbResult{$item}{output});

            $param .= ' "'.$dbResult{$item}{service}.'"' if ( $dbResult{$item}{check_type} eq 's' );

            updateLog($dbResult{$item}{notify_id}, ", single alert");
            # queue notification "host + service is output"
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
    foreach my $value (@$arrptr)
    {
        updateDB("update tmp_active set bundle='".$bunid."' where notify_id in (".$list.")");
    }
}

# set the progress flag
sub setProgressFlag
{
    my ($arrptr) = @_;
    my $list;


    $list = join(',', @$arrptr);
    debug("setting progress flag for $list");
    updateDB("update tmp_active set progress='1' where id in (".$list.")");
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
