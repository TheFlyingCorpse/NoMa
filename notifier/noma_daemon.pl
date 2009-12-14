#!/usr/bin/perl -w

# nagios: -epn

# COPYRIGHT:
#
# This software is Copyright (c) 2007-2009 NETWAYS GmbH, Christian Doebler
#                 some parts (c) 2009      NETWAYS GmbH, William Preston
#                                <support@netways.de>
#
# (Except where explicitly superseded by other copyright notices)
#
#
# LICENSE:
#
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from http://www.fsf.org.
#
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 or visit their web page on the internet at
# http://www.fsf.org.
#
#
# CONTRIBUTION SUBMISSION POLICY:
#
# (The following paragraph is not intended to limit the rights granted
# to you to modify and distribute this software under the terms of
# the GNU General Public License and is only of importance to you if
# you choose to contribute your changes and enhancements to the
# community by submitting them to NETWAYS GmbH.)
#
# By intentionally submitting any modifications, corrections or
# derivatives to this work, or any other work intended for use with
# this Software, to NETWAYS GmbH, you confirm that
# you are the copyright holder for those contributions and you grant
# NETWAYS GmbH a nonexclusive, worldwide, irrevocable,
# royalty-free, perpetual, license to use, copy, create derivative
# works based on those contributions, and sublicense and distribute
# those contributions and any derivatives thereof.
#
# Nagios and the Nagios logo are registered trademarks of Ethan Galstad.

=head1 NAME

noma_daemon.pl  -  NETWAYS Notification Manager - Daemon

=head1 SYNOPSIS

=head1 OPTIONS

=head1 CAVEATS

This script uses Thread Queues which may have memory leak problems in Perl versions
< 5.8.1

Note that your DateTime::TimeZone package may have old time zone data in it, since the
perl zones are maintained separately from the system timezones!

If using MySQL Replication setups, be aware of the "ON DUPLICATE KEY UPDATE" bug.
As a workaround you could use "REPLACE" -> code changed to do select / update


=cut

use strict;
use warnings;

die
"WARNING: Your Perl is too old. I cannot guarantee that NoMa will be stable. Comment out this check if you want to continue anyway"
  if ( $] and $] < 5.008001 );

use Getopt::Long;
use Pod::Usage;
use POSIX;
use Digest::MD5 qw(md5_hex);
use FindBin;
use lib "$FindBin::Bin";
use lib "$FindBin::Bin".'/lib';
use noma_conf;
use thread_procs;
use escalations;
use array_hash;
use contacts;
use database;
use debug;


use Data::Dumper;
# use threads ('yield', 'stack_size' => 16*4096);
use threads;
use Thread::Queue;
use IO::Select;
use Fcntl qw(O_RDWR);
use IO::Socket;

use DateTime;
use DateTime::TimeZone;

# use Proc::ProcessTable;
use DBI;

our $processStart = time();
my $versionStr = 'current (1.0.5)';

my %stati_service = (
    'OK'       => 'on_ok',
    'WARNING'  => 'on_warning',
    'CRITICAL' => 'on_critical',
    'UNKNOWN'  => 'on_unknown'
);
my %stati_host = (
    'UP'          => 'on_host_up',
    'UNREACHABLE' => 'on_host_unreachable',
    'DOWN'        => 'on_host_down'
);
my %check_type_str = (
    'h' => 'Host',
    's' => 'Service',
    ''  => '',
);

my $host              = '';
my $host_alias        = '';
my $host_address      = '';
my $service           = '';
my $check_type        = '';
my $status            = '';
my $datetime          = '';
my $output            = '';
my $notification_type = '', my $verbose = undef;
my $version           = undef;
my $help              = undef;

my $query               = '';
my $notificationCounter = 0;
my $notifierPID         = 0;
my $notifierUser        = 'nagios';
my $notifierBin         = 'noma_notifier.pl';
my $now                 = 0;

my $reloop_delay    = 1;
my $acknowledged    = 0;
my $loop_until_ack  = 0;
my $sleep           = 0;
my $keep_on_looping = 1;
my $ignore        = 0;

my $log_count = 0;
my @triesPerID;
my $max_notificationCounter = 0;
my $additional_run          = 0;
my $whoami     = 'notifier';

my $conf  = conf();
my $cache = $conf->{path}->{cache};

my $debug = $conf->{debug}->{logging};
my $debug_queries = $conf->{debug}->{queries};
my $do_not_send   = undef;
my $debug_file = $conf->{debug}->{file};
my $paramlog = $conf->{debug}->{paramlog};
my $daemonize = $conf->{debug}->{daemonize};
my $pidfile = $conf->{path}->{pidfile};
$ignore = $conf->{escalator}{internalEscalation}
    if (defined($conf->{escalator}{internalEscalation}));


our %queue;                          # thread message queues
our %thread;                         # thread hash

##############################################################################
# HANDLING OF COMMAND-LINE PARAMETERS
##############################################################################

# log all command-line parameters
if ( defined($paramlog) )
{
    open( OUT, ">> $paramlog" );
    print OUT '[' . localtime() . ']  ' . join( ' ', @ARGV ) . "\n";
    close(OUT);
}

# TODO MySQL cache
# open(LOG, "+< $cache") or die "Offline cache file cannot be created";
# close(LOG);

Getopt::Long::Configure('bundling');
my $clps = GetOptions(

    "V|version" => \$version,
    "h|help"    => \$help

);

# display help?
if ( defined($help) )
{
    pod2usage( -verbose => 1 );
    exit(0);
}

# print version?
if ( defined($version) )
{
    print 'Version: ' . $versionStr . "\n";
    exit 0;
}

if(!($<))
# it may be better here to use the following
# if(!($>))
{
	die "This script should not be run as root";
}

if ( defined($daemonize) and $daemonize == 1)
{
	# fork, etc.
	my $parent;
	defined($parent = fork()) or die "Failed to fork";
	exit(0) if $parent;
	chdir('/');
    # create our PID file here
    # don't check that we are already running - that is a job for the init script
    if (defined($pidfile))
    {
        open (PID, ">$pidfile") or die "Can't create PIDfile";
        print PID "$$\n";
        close(PID);
    }
	setsid();
	close(STDIN);
	close(STDOUT);
	close(STDERR);
}

# delete any active notifications
# TODO: OBACHT! this is undesirable, think of something better
deleteFromActive();
# TODO: read escalations in and push into Queue???
deleteFromEscalations();

# create queues for replies from notifier plugins, commands, and escalations
my $msgq = Thread::Queue->new;
my $cmdq = Thread::Queue->new;
my $escq = Thread::Queue->new;

# create a thread for each notification type

foreach my $method ( getMethods() )
{

    my $proc = $$method{'command'};

    $queue{$proc} = Thread::Queue->new;
    $thread{$proc} =
      threads->new( \&spawnNotifierThread, $queue{$proc}, $msgq, $proc,
        $conf->{command}{$proc} );
    debug( 'spawned ' . $proc . ' with ID ' . $thread{$proc}->tid );
}

# the escalation thread (for internal escalation)
$thread{'escalator'} =
    threads->new(\&spawnEscalationThread, $cmdq, $escq);

if ($conf->{input}{pipeEnabled})
{
	$thread{'commandPipeThread'} =
	  threads->new(\&spawnCommandPipeThread, $cmdq, $conf->{input});
}

if ($conf->{input}{socketEnabled})
{
	$thread{'commandSocketThread'} =
	  threads->new(\&spawnCommandSocketThread, $cmdq, $conf->{input});
}

if ($conf->{debug}{watchdogEnabled})
{
	$thread{'watchdogThread'} =
	  threads->new(\&spawnWatchdogThread, $conf->{debug});
}

my $cmd;
my $msg;

#
# BEGIN - GLOBAL LOOP
#
do
{

    if ( $cmd = $cmdq->dequeue_nb )
    {
        {
            debug( 'processing command ' . $cmd );
            my ( $operation,
                $host,         $incident_id, $host_alias,
                $host_address, $service,     $check_type,
                $status,       $datetime,    $notification_type,
                $output
            ) = parseCommand($cmd);
            next if ( !defined $host );

            debug(
                "host = $host, incident_id = $incident_id, host_alias = $host_alias, host_address = $host_address, service = $service, check_type = $check_type, status = $status, datetime = $datetime, notification_type = $notification_type, output = $output"
            );

            # hosts and services in lower case
            $host = lc($host);
            $service = lc($service) if ( $check_type eq 's' );

##############################################################################
            # GENERATE LIST OF CONTACTS TO NOTIFY
##############################################################################

            # TODO DB not reachable? - add cacheing code
            #





            # generate query and get list of possible users to notify
            my $query =
            'select id,hosts_include,hosts_exclude,services_include,services_exclude from notifications';
            if ( $check_type eq 'h' )
            {
                $query .= ' where ' . $stati_host{$status} . '=\'1\'';
            } else
            {
                $query .= ' where ' . $stati_service{$status} . '=\'1\'';
            }
            my %dbResult = queryDB($query);

            # filter out unneeded users by using exclude lists
            my @ids_all =
            generateNotificationList( $check_type, $host, $service,
                %dbResult );
            debug( 'IDs collected (unfiltered): ' . join( '|', @ids_all ) );



            # We need to split the rules into 2 types
            # those that escalate internally - and normal rules
            #

            my @ids =();
            my @contactsArr = ();

            # first handle normal rules
            ############ NORMAL RULES ####################

            # only consider "real" alerts
            if ($operation eq 'notification')
            {
                @ids = getUnhandledRules(\@ids_all);


                $notificationCounter = getNotificationCounter($host, $service);

                if ($notificationCounter > 0)
                {
                    # notification already active

                    ## escalation handled internally - ignore it here

                    if ($status eq 'OK' || $status eq 'UP')
                    {
                        # clear counter
                        #
                        clearNotificationCounter($host, $service);
                    }
                    else
                    {
                        # increment counter
                        $notificationCounter =
                            incrementNotificationCounter( $status, $host, $service,$check_type);
                    }
                } else {
                    # notification returned 0
                    $notificationCounter =
		                incrementNotificationCounter( $status, $host, $service,$check_type);
		        }

                debug( 'notification counter: ' . $notificationCounter );

                # do we need to rollover the counter?
                # - this is a global check
                $notificationCounter = resetNotificationCounter($host, $service)
                    if (counterExceededMax(\@ids, $notificationCounter));

                # no matches!?
                my $idCount = @ids;
                if ( $idCount < 1 )
                {
                    debug('No rule matches!');
                    # TODO: clear stati??
                }
                else
                {

                    # get contact data
                    @contactsArr = getContacts(\@ids, $notificationCounter, $status, $incident_id);
                }
            }
            # now handle escalation rules
            debug("now handling escalation rules");
            ############ ESCALATION RULES ####################

            @ids = getHandledRules(\@ids_all);

            # the various rules may be at different stages, so handle them individually
            foreach my $esc_rule (@ids)
            {
                my @esc_arr;
                push @esc_arr, $esc_rule;
                debug("looking at rule $esc_rule");
                $notificationCounter = getEscalationCounter($host, $service, $esc_rule);

                if ($notificationCounter > 0)
                {
                    # notification already active
                    debug("rule $esc_rule is currently escalating");
                    # is this a faked alert? otherwise ignore it!
                    if ($operation eq 'escalation')
                    {
                        debug("rule $esc_rule is faked - checking for overflow");
                        $notificationCounter = resetEscalationCounter($host, $service, $esc_rule)
                            if (counterExceededMax(\@esc_arr, $notificationCounter));

                        @contactsArr = (@contactsArr, getContacts(\@esc_arr, $notificationCounter, $status, $incident_id));
                    }

                }
                else
                {
                    debug("creating a new escalation for rule $esc_rule");
                    # create status entry
                    createEscalationCounter($esc_rule,
                        $incident_id,  $host,        $host_alias,
                        $host_address, $service,     $check_type,
                        $status,       $datetime,    $notification_type,
                        $output
                    );
                    debug("adding contacts to array");
                    @contactsArr = (@contactsArr, getContacts(\@esc_arr, 1, $status, $incident_id));
                }

            }


##############################################################################
            # SEND COMMANDS
##############################################################################

            # loop through list of contacts
            for my $contact (@contactsArr)
            {

                my $user   = $contact->{username};
                my $method = $contact->{method};
                my $cmd    = $contact->{command};
                my $dest   = $contact->{ $contact->{contact_field} };
                my $from   = $contact->{from};
                my $id    = unique_id();

                # insert into DB
                createLog(
                    '1', $id, $incident_id, $contact->{rule},
                    $check_type_str{$check_type},          $status,
                    $host,                $service,
                    $method,           $contact->{mid}, $user,
                    'processing notification'
                );

                # TODO consider using timezones and converting time to user configurable format e.g. 
                # M/D/YY for USA
                # DD/MM/YYYY for UK
                # DD.MM.YYYY for EU
                # until this is implemented we just use what we were given
                $queue{$cmd}->enqueue(prepareNotification($user, $method, $cmd, $dest, $from, $id, $datetime, $check_type, $status,
                        $notification_type, $host, $host_alias, $host_address, $service, $output));

            }

        }
    }

    # check for notification results
    RESULTSLOOP: if ( $msg = $msgq->dequeue_nb )
    {
        # id= unique ID (per notification)
        my ( $id, $retval, @retstr ) = split( ';', $msg );
        my $retstr = join( ';', @retstr );

        debug(
            "received message from notifier: id=$id, retval=$retval, retstr=$retstr"
        );

        # retrieve details from DB

        # check whether sending was successful
        if ( $retval != 0 )
        {

            # sending was NOT successful

            if (getRetryCounter($id) < $conf->{notifier}->{maxAttempts})
            {
                # requeue notification and increment counter
                requeueNotification($id);
            }
            else
            {
                # retrieve the contact data

                # try to get next method (method escalation)
                my ($nextMethod, $nextMethodName) = getNextMethod($id);

                if ($nextMethod eq '0')
                {

                    debug("no more methods for $id");
                    if ( $retstr eq '' )
                    {
                        $retstr = ' failed - no methods left';
                    } else
                    {
                        $retstr .= ' - failed - no methods left';
                    }

                    # now try to escalate
                    # N.B. there may be more than 1 simultaneous notification
                    # that attempts to escalate.
                    #
                    # 
                    if (needToEscalateUniqueID($id))
                    {
                        $retstr .= '. Escalating';
                        debug("escalating $id");
                        updateLog( $id, $retstr );
                        deleteFromActive($id);
                        escalate($id);
                    }
                    else
                    {
                        # $retstr .= '. Not escalating';
                        debug("not escalating $id");
                        updateLog( $id, $retstr );
                        deleteFromActive($id);
                    }


                }
                else
                {

                    if ( $retstr eq '' )
                    {
                        $retstr = " failed\nTrying next method";
                    } else
                    {
                        $retstr .= " - failed\nTrying next method";
                    }

                    updateLog( $id, $retstr );
                    $queue{$nextMethodName}->enqueue(getNextMethodCmd($id, $nextMethod));

                }


            }
        }
        else
        {

            # sending was successful -> write to log
            if ( $retstr eq '' )
            {
                $retstr = ' successful';
            } else
            {
                $retstr .= ' - successful';
            }

            updateLog( $id, $retstr );

            # if this particular notification method was successful (e.g. email)
            # delete it from the tmp_active table
            deleteFromActive($id);

            # if the method is flagged as ACKable then additionally remove it from the status
            # table (i.e. Voicealert)
            if (notificationAcknowledgable($id))
            {
                # TODO feedback acknowledgement to nagios
                deleteFromStati($id);
            }
            else
            {
                # pass to escalator
                debug("ACK: escalating $id");
                escalate($id);
            }
        }

    }

    # sleep for a bit
    select( undef, undef, undef, 0.025 );

} while (1);

#
# END - GLOBAL LOOP
#

exit 0;

##############################################################################
# SUBROUTINES START HERE
##############################################################################

# parse a command into host array
sub parseCommand
{
    my $cmd = shift;
    my $sql;
    my @dbResult;

    # If using the Nagios internal macros XXXNOTIFICATIONID, then be aware that
    # the ID may not be globally unique.
    # use $TIMET$$HOSTNOTIFICATIONID$, $TIMET$$SERVICENOTIFICATIONID$ or similar
    # - alternatively leave the field blank

    # TODO convert datetime if necessary
    
    if ( $cmd =~ /^notification;/i
        || $cmd =~ /^escalation;/i )
    {
        my (
            $operation,             $id,           $host,
            $host_alias,        $host_address, $service,
            $check_type,        $status,       $stime,
            $notification_type, $output
        ) = split( ';', $cmd );

        if ( $id eq '' or $id < 1 ) { $id = unique_id(); }

        if ( ($stime =~ /\D/) or ($stime < 1000000000))
        {
            debug("Invalid date $stime for notification - using now()");
            $stime = now();
        }
        return (
            lc($operation),
            $host,         $id,       $host_alias,
            $host_address, $service,  $check_type,
            $status,       $stime, $notification_type,
            $output
        );
    }

    if ( $cmd =~ /^status/i )
    {

        foreach my $i (keys %queue)
        {
            debug("Queue $i has ".$queue{$i}->pending." pending jobs");
        }

        $sql = 'select count(*) as count from tmp_active';
        @dbResult = queryDB($sql, 1);
        debug("There are ".$dbResult[0]{count}." active escalations");

        $sql = 'select count(*) as count from notification_logs where timestamp>date_sub(now(), interval 1 hour)';
        @dbResult = queryDB($sql, 1);
        debug($dbResult[0]{count}." notifications were sent in the last hour");


    }

    return undef;

}


# ignores internally escalated rules
sub getNotificationCounter
{
    my ($host, $svc) = @_;

    #my $counter = undef;
    my $counter = 0;
    my $query = 'select counter from notification_stati where host=\''.$host.'\'';

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
sub prepareNotification
{
	my ($user, $method, $short_cmd, $dest, $from, $id,
	$datetime, $check_type, $status,
	$notification_type, $host, $host_alias, $host_address, $service, $output) = @_;

	# start of the notification
	my $start = time();

	my $cmd = $conf->{command}->{$short_cmd};
	# error if script is missing
	unless ( -x $cmd )
	{
	    debug( 'Missing script: ' . $cmd );
	    next;
	}

	# error if something is missing
	unless ( defined($cmd) )
	{
	    debug( 'Missing command for notification belonging to: ' . $user );
	    next;
	}
	unless ( defined($dest) )
	{
	    debug( 'Missing destination for notification belonging to: ' . $user );
	    next;
	}

	# default 'from'
	unless ( defined($from) )
	{
	    my $from = '';
	}

	# create parameter (FROM DESTINATION CHECK-TYPE DATETIME STATUS NOTIFICATION-TYPE HOST-NAME HOST-ALIAS HOST-IP OUTPUT [SERVICE])
	my $param = sprintf(
"\"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\"",
	    $from,  $dest,    $check_type,
	    $datetime, $status,     $notification_type,
	    $host,     $host_alias, $host_address,
	    $output
	);
	$param .= " \"$service\"" if ( $check_type eq 's' );

	debug("$whoami: BEFORE call - $method  $param");

	# insert the command into our active notification list
	my $query = sprintf('insert into tmp_active (start, time_string, notify_id, command, dest, from_user, check_type, status, type, host, host_alias, host_address, service, output) values (\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\') on duplicate key update command=\'%s\',dest=\'%s\',from_user=\'%s\'',
		$start, $datetime, $id, $short_cmd, $dest, $from, $check_type, $status, $notification_type, $host, $host_alias, $host_address, $service, $output, $cmd, $dest, $from);
    	
	updateDB($query);

	return("$id;$start;1;$param");

}

sub deleteFromActive
{
	my ($id) = @_;

	my $query = 'delete from tmp_active';
    $query .= " where notify_id=$id" if $id;

	updateDB($query);
}



# check whether a result came from an acknowledgeable method
sub notificationAcknowledgable
{
    my ($id) = @_;

    my $query = 'select nm.ack_able as ack_able from notification_logs as l left join
                    notification_methods as nm on l.last_method=nm.id
                    where l.unique_id=\''.$id.'\'';

    my %dbResult = queryDB($query);

    my $ackable = $dbResult{0}->{ack_able};

    return 1 if (defined($ackable) && ($ackable>0));
    debug("notification not ackable");
    return 0;
}

sub getNextMethod
{

    # get params
    my ( $notify_id ) = @_;
    my $query;
    my $next_id;
    my $command;

    # get next escalation method
    $query =
      sprintf(
'select id, command from notification_methods where id = (select m.on_fail from notification_methods m left join notification_logs as l on l.last_method=m.id where l.unique_id=\'%s\')',
	$notify_id);
    my %dbResult = queryDB($query);

    ($next_id, $command) = ($dbResult{0}->{id}, $dbResult{0}->{command});
    return (0, '/bin/true') if (!defined($next_id) or $next_id == 0);

    $query = sprintf('update notification_logs set last_method=\'%s\' where unique_id=\'%s\'', $next_id, $notify_id);
    updateDB($query);

    return ($next_id, $command);

}

sub getRetryCounter
{

    # get params
    my ( $notify_id ) = @_;
    my $query;
    my $counter;

    $query =
      sprintf(
'select counter from notification_logs where unique_id = \'%s\'',
	$notify_id);
    my %dbResult = queryDB($query);

    $counter = $dbResult{0}->{counter};
    return 0 if (!defined($counter));

    return $counter;

}

sub requeueNotification
{
	# get params
	my ( $id ) = @_;
	my $query;
	my %dbResult;
	my $counter = 1;
	my $start = time();

	# log the retry
	updateLog($id, ' failed. Retrying. ');

	# increment counter
	$query = sprintf('update notification_logs set counter=counter+1 where unique_id=\'%s\'', $id);
	updateDB($query);

	$query = sprintf('select counter from notification_logs where unique_id=\'%s\'', $id);
    	%dbResult = queryDB($query);

	$counter = $dbResult{0}->{counter}
		if ( defined( $dbResult{0}->{counter} ) );

	# don't check timeperiods for retries -> a contact may be alerted outside the timeperiod
	# retrieve the original data.
	# from log: user, method,id,check_type,status,host,service,
	#
	# not from log:cmd, dest,from,datetime,notification type,host_alias,host_address,output
	# requeue the command

	# see tmp_active
	$query = sprintf('select * from tmp_active where notify_id=\'%s\'', $id);
    	%dbResult = queryDB($query);

	my $cmd = $dbResult{0}->{command};
	my $dest = $dbResult{0}->{dest};
	my $from_user = $dbResult{0}->{from_user};
	my $check_type = $dbResult{0}->{check_type};
	my $status = $dbResult{0}->{status};
	my $type = $dbResult{0}->{type};
	my $host = $dbResult{0}->{host};
	my $host_alias = $dbResult{0}->{host_alias};
	my $host_address = $dbResult{0}->{host_address};
	my $service = $dbResult{0}->{service};
	my $time_string = $dbResult{0}->{time_string};
	my $output = $dbResult{0}->{output};

	my $longcmd = $conf->{command}->{$cmd};

	my $param = sprintf(
"\"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\"",
	    $from_user, $dest, $check_type,
	    $time_string, $status, $type,
	    $host, $host_alias, $host_address,
	    $output
	);
	$param .= " \"$service\"" if ( $check_type eq 's' );
	
	$queue{$cmd}->enqueue("$id;$start;$counter;$param");
}

sub getNextMethodCmd
{

    # get params
    my ( $notify_id, $method_id ) = @_;
    my %dbResult;
    my %dbResult2;
    my $query;


	$query = sprintf('select distinct n.counter, m.contact_field, m.method, n.user, n.incident_id, n.notification_rule, m.id as last_method, m.command, c.email, m.from, t.check_type, t.status, t.type, t.host, t.host_alias, t.host_address, t.service, t.output, n.timestamp from tmp_active as t left join notification_logs as n on n.unique_id=t.notify_id left join contacts as c on c.username=n.user, notification_methods as m where n.unique_id=t.notify_id and t.notify_id=\'%s\' and m.id=\'%s\'', $notify_id, $method_id);
    	
    %dbResult = queryDB( $query );
    
    $query = sprintf('select %s from contacts where username=\'%s\'', $dbResult{0}{contact_field}, $dbResult{0}{user});
    %dbResult2 = queryDB( $query );

    # call prepareNotification and return result
    #
    

    my $cline = prepareNotification($dbResult{0}{user}, $dbResult{0}{method}, $dbResult{0}{command},
	    $dbResult2{0}{$dbResult{0}{contact_field}}, $dbResult{0}{from}, $notify_id, $dbResult{0}{timestamp},
	    $dbResult{0}{check_type}, $dbResult{0}{status}, $dbResult{0}{type}, $dbResult{0}{host},
	    $dbResult{0}{host_alias}, $dbResult{0}{host_address}, $dbResult{0}{service}, $dbResult{0}{output});

    return $cline;

}

sub getMethods
{

    my $query = undef;
    my @dbResult;

    $query =
	'select command from notification_methods group by command';
    @dbResult = queryDB( $query, 1 );

    return (@dbResult);

}

sub clearNotificationCounter
{

    my ( $host, $svc ) = @_;

    my $query = 'delete from notification_stati
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

# clear the counter given an unique_id
sub deleteFromStati
{
    my ($id) = @_;

    my $query = 'select host,service from notification_logs
                    where unique_id=\''.$id.'\'';

    my %dbResult = queryDB($query);

    # TODO: check that host alerts work!
    clearNotificationCounter($dbResult{0}->{host}, $dbResult{0}->{service});

}

sub updateMaxNotificationCounter
{

	# TODO this function does nothing useful
    my ( $dbResult_arr, $notificationCounter ) = @_;

    # apply filter
    foreach my $row (@$dbResult_arr)
    {
        next
          if ( !defined( $row->{notify_after_tries} )
            || $row->{notify_after_tries} eq '' );
        my @notify_after_tries =
          getArrayOfNums( $row->{notify_after_tries}, $notificationCounter );
        my $max = getMaxFromArray( \@notify_after_tries );
        $max_notificationCounter = $max if ( $max_notificationCounter < $max );
    }

}




##############################################################################
# MISC FUNCTIONS
##############################################################################
sub unique_id
{
    # we don't use MySQL UUID() to generate IDs
    # because this won't work in offline mode
    return (time().int( rand(99999) ));
}


sub getUnixTime
{

    my ($datetime) = @_;

    my ( $date, $time ) = split( ' ', $datetime );
    my ( $year, $mon, $day ) = split( '-', $date );
    my ( $hour, $min, $sec ) = split( ':', $time );

    return mktime( $sec, $min, $hour, $day, $mon - 1, $year - 1900 );

}

sub hmsToSecs
{
	my ($time) = @_;
	my @arr = split(":", $time);
	return (($arr[0]*3600)+($arr[1]*60)+($arr[2]));
}

# give this function a reference to
# an array of hashes
#
# e.g.
# {
#  'start' => '2008-12-20 00:00:00',
#  'end' => '2008-12-28 24:00:00',
# };
#
sub datetimeInPeriod
{

	my ($periods, $date) = @_;

	my $checktime = getUnixTime( $date );

	foreach my $period (@$periods)
	{
		if ($checktime >= getUnixTime($period->{'start'}) and 
			$checktime <= getUnixTime($period->{'end'}))
		{
			return 1;
		}
	}
	return 0;
}

# give this function a reference to
# an array of hashes
#
# e.g.
# {
#  'starttime' => '00:00:00',
#  'endtime' => '24:00:00',
#  'days' => '127'
# };
#
# N.B. dow is 0-6 (sun - sat),
#  and days is a binary map
sub timeInPeriod
{

	my ($periods, $dayofweek, $hms) = @_;

	if ($dayofweek == 7) { $dayofweek = 0; }

	foreach my $period (@$periods)
	{
		next if (!( $period->{'days'} & (2**($dayofweek)) ));

		my $checktime = hmsToSecs($hms);
		
		if ($checktime >= hmsToSecs($period->{'starttime'}) and 
			$checktime <= hmsToSecs($period->{'endtime'}))
		{
			return 1;
		}
	}
	return 0;
}

sub incrementNotificationCounter
{

    my ( $status, $host, $service, $check_type ) = @_;
    my $notificationCounter =
        getNotificationCounter( $host, $service);

    if ( defined($notificationCounter) )
    {
        $query = 'update notification_stati set counter=counter+1,
            check_result=\'' . $status . '\'
            where host=\'' . $host . '\' and ' . 'service=\'' . $service . '\'';
    } else
    {
        $notificationCounter = 0;
        $query =
            'insert into notification_stati (host,service,check_type,check_result,counter,pid)
            values (' . "'$host','$service','$check_type','$status','1','0')";
    }

    updateDB($query);
    return ( $notificationCounter + 1 );

}

sub resetNotificationCounter
{

    my ( $host, $service ) = @_;

    $query = 'update notification_stati set counter=1,
        where host=\'' . $host . '\' and ' . 'service=\'' . $service . '\'';

    updateDB($query);
    return ( 1 );

}


sub createLog
{

    # get parameter values
    my (
        $counter, $cur_id, $incident_id, $rule, $check_type_str, $status, $host,
        $service, $method, $mid, $user,       $result
    ) = @_;

    if ( $cur_id eq '' )
    {
        $cur_id = unique_id();
    }

    # create timestamp
    my ( $sec, $min, $hour, $day, $mon, $year ) =
      (localtime)[ 0, 1, 2, 3, 4, 5 ];
    $year += 1900;
    $mon++;
    my $timestamp = sprintf( "%d-%02d-%02d %02d:%02d:%02d",
        $year, $mon, $day, $hour, $min, $sec );

    # get delimiter
    my $delimiter = '';
    if ( defined( $conf->{'log'}->{delimiter} ) )
    {
        $delimiter = $conf->{'log'}->{delimiter};
    }

    # check for verbosity of logging and populate result string if necessary
    if ( !defined( $conf->{'log'}->{pluginOutput} ) )
    {
        $result = '';
    }

    my $query = sprintf(
'insert into notification_logs (unique_id, incident_id, notification_rule, timestamp,counter,check_type,check_result,host,service,method,last_method,user,result)
			values (\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\')',
        $cur_id,
	$incident_id,
	$rule,
        $timestamp,
        $counter,
        $check_type_str,
        $status,
        $host,
        $service,
        $method,
	$mid,
        $user,
        $result
    );

    updateDB($query);

}

# add a string to a log entry identified by a unique id
sub updateLog
{
    my ( $id, $result ) = @_;

    my $query =
      sprintf(
'update notification_logs set result=concat(result, \'%s\') where unique_id=\'%s\'',
        $result, $id );
    updateDB($query);
}

sub pushUnique
{
    my ( $array_ref, $to_push ) = @_;
    push( @$array_ref, $to_push ) if ( !grep( /^$to_push$/, @$array_ref ) );
    return @$array_ref;
}

# return true if we are beyond the last notification
sub counterExceededMax
{
    my ($ids, $counter) = @_;

    my $query = 'select notify_after_tries from notifications where id in ('.join(',',@$ids).')';

	my @dbResult = queryDB($query, '1');

    my $maxval = 0;

	foreach my $tries (@dbResult)
	{
        my @tryArr = sort {$b <=> $a} (getArrayOfNums($tries));
		$maxval = $tryArr[0] if ($tryArr[0] > $maxval);
	}
    return 0 if ($maxval > $counter);

    debug('notification counter rollover');
    return 1;
}

# vim: ts=4 sw=4 expandtab
# EOF
