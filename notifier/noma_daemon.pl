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

This script uses a configuration file

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
use bundler;
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
use Storable;

# use Proc::ProcessTable;
use DBI;

our $processStart = time();
our %suppressionHash;
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
my $version           = undef;	# command option
my $help              = undef;	# command option

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
my $additional_run          = 0;
my $whoami     = 'notifier';

our $conf  = conf();
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
        open (PID, ">$pidfile") or die "Can't create PIDfile $pidfile";
        print PID "$$\n";
        close(PID);
    }
	setsid();
	close(STDIN);
	close(STDOUT);
	close(STDERR);
}

# TODO: read escalations in and push into Queue???
# deleteFromEscalations();



##############################################################################
# THREAD CREATION
##############################################################################

# create queues for replies from notifier plugins, commands, and escalations
my $msgq = Thread::Queue->new;
my $cmdq = Thread::Queue->new;
my $escq = Thread::Queue->new;
my $dbquery = Thread::Queue->new;
my $dbreply = Thread::Queue->new;

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

if (0==1)
{
	$thread{'bundlerThread'} =
   threads->new(\&spawnBundlerThread, \%queue, $conf->{notifier});
}

my $cmd;
my $msg;

##############################################################################
# GLOBAL LOOP
##############################################################################
do
{

    if ( $cmd = $cmdq->dequeue_nb )
    {
        {
            debug( 'processing command ' . $cmd );
#             my ( $operation,
#                 $host,         $incident_id, $host_alias,
#                 $host_address, $service,     $check_type,
#                 $status,       $datetime,    $notification_type,
#                 $output
#             ) = parseCommand($cmd);
            my %cmdh = parseCommand($cmd);
            next if ( !defined $host );
           
            debug(debugHash(%cmdh));
#                 "host = $host, incident_id = $incident_id, host_alias = $host_alias, host_address = $host_address, service = $service, check_type = $check_type, status = $status, datetime = $datetime, notification_type = $notification_type, output = $output"

            # hosts and services in lower case
            $cmdh{host} = lc($cmdh{host});
            $cmdh{service} = lc($cmdh{service}) if ( $cmdh{check_type} eq 's' );
##############################################################################
            # GENERATE LIST OF CONTACTS TO NOTIFY
##############################################################################

            # TODO DB not reachable? - add cacheing code
            #





            # generate query and get list of possible users to notify
            my $query =
            'select id,hosts_include,hosts_exclude,hostgroups_include,hostgroups_exclude,services_include,services_exclude from notifications';
            if ( $cmdh{check_type} eq 'h' )
            {
                $query .= ' where ' . $stati_host{$cmdh{status}} . '=\'1\'';
            } else
            {
                $query .= ' where ' . $stati_service{$cmdh{status}} . '=\'1\'';
            }

            # only active rules!
            $query .= ' and active=\'1\'';
            my %dbResult = queryDB($query);

            # filter out unneeded users by using exclude lists
            my @ids_all =
            generateNotificationList( $cmdh{check_type}, $cmdh{host},  $cmdh{service}, $cmdh{hostgroups},
                %dbResult );
            debug( 'Rule IDs collected (unfiltered): ' . join( '|', @ids_all ) );


            unless ($cmdh{status} eq 'OK' || $cmdh{status} eq 'UP')
            {
                if (scalar(@ids_all) < 1)
		{
			# deleteFromCommands($cmdh{external_id});
			next;
		}
            }

            # We need to split the rules into 2 types
            # those that escalate internally - and normal rules
            #

            my @ids =();
            my @contactsArr = ();

            # first handle normal rules
            debug("now handling normal rules");
            ############ NORMAL RULES ####################

            # only consider "real" alerts
            if ($cmdh{operation} eq 'notification')
            {
                @ids = getUnhandledRules(\@ids_all);
                debug( 'Unhandled(normal) rule IDs (unfiltered): ' . join( '|', @ids ) );


                $notificationCounter = getNotificationCounter($cmdh{host}, $cmdh{service});
                debug("Counter from notification_stati for $cmdh{host} / $cmdh{service} is $notificationCounter");

                if ($notificationCounter > 0)
                {
                    # notification already active
                    debug('-> already active');

                    ## TODO: escalation handled internally - ignore it here

                    if ($cmdh{status} eq 'OK' || $cmdh{status} eq 'UP')
                    {
                        # clear counter
                        #
                        debug('  -> Clearing counter');
                        clearNotificationCounter($cmdh{host}, $cmdh{service});
                        clearEscalationCounter($cmdh{host}, $cmdh{service});
                        deleteFromActiveByName($cmdh{host}, $cmdh{service});
                    }
                    else
                    {
                        # increment counter
                        debug('  -> Incrementing counter');
                        $notificationCounter =
                            incrementNotificationCounter( $cmdh{status}, $cmdh{host}, $cmdh{service},$cmdh{check_type});
                    }
                } else {
                    # notification returned 0
                    if ($cmdh{status} eq 'OK' || $cmdh{status} eq 'UP')
                    {
                        debug('Received recovery for a problem we never saw - will try to match against notification no. 1');
                        $notificationCounter = 1;
                    }
                    else
                    {
                        debug('-> setting to active');
                        $notificationCounter =
                            incrementNotificationCounter( $cmdh{status}, $cmdh{host}, $cmdh{service},$cmdh{check_type});
                    }
                }
                # no matches!?
                my $idCount = @ids;
                if ( $idCount < 1 )
                {
                    debug('No rule matches!');
                    # TODO: clear stati??
                }
                else
                {
                    debug($idCount.' rules matched');

                    # do we need to rollover the counter?
                    # the various rules may rollover at different times, so handle them individually
                    foreach my $ruleid (@ids)
                    {
                        my @id_arr;
                        push @id_arr, $ruleid;
                        # - this is a local check
                        if (counterExceededMax(\@id_arr, $notificationCounter))
                        {
                            debug('No more alerts possible, rolling over the counter');
                            $notificationCounter = resetNotificationCounter($cmdh{host}, $cmdh{service});
                        }

                        # get contact data
                        @contactsArr = (@contactsArr, getContacts(\@id_arr, $notificationCounter, $cmdh{status}, $cmdh{external_id}));
                    }
                }
            }
            # now handle escalation rules
            debug("now handling internal escalation rules");
            ############ ESCALATION RULES ####################

            @ids = getHandledRules(\@ids_all);
            debug( 'Handled by NoMa(internal escalation) rule IDs (unfiltered): ' . join( '|', @ids ) );

            # the various rules may be at different stages, so handle them individually
            foreach my $esc_rule (@ids)
            {
                my @esc_arr;
                push @esc_arr, $esc_rule;
                debug("looking at rule $esc_rule");
                $notificationCounter = getEscalationCounter($cmdh{host}, $cmdh{service}, $esc_rule);

                if ($notificationCounter > 0)
                {
                    # notification already active
                    debug("rule $esc_rule is currently escalating");
                    incrementEscalationCounter($cmdh{host}, $cmdh{service}, $esc_rule);
                    $notificationCounter += 1;

                    # is this a faked alert? otherwise ignore it!
                    if ($cmdh{operation} eq 'escalation')
                    {
                        debug("rule $esc_rule is faked - checking for overflow");
                        # $notificationCounter = resetEscalationCounter($cmdh{host}, $cmdh{service}, $esc_rule)
                        my $oflo = counterExceededMax(\@esc_arr, $notificationCounter);
                        $notificationCounter = $oflo
                            if ($oflo > 0);

                        @contactsArr = (@contactsArr, getContacts(\@esc_arr, $notificationCounter, $cmdh{status}, $cmdh{external_id}));
                    }

                }
                elsif ($cmdh{status} ne 'OK' and $cmdh{status} ne 'UP')
                {
                    debug("creating a new escalation for rule $esc_rule");
                    # create status entry
                    createEscalationCounter($esc_rule, %cmdh);
#                         $incident_id,  $host,        $host_alias,
#                         $host_address, $service,     $check_type,
#                         $status,       $datetime,    $notification_type,
#                         $output
#                     );
                    debug("adding contacts to array");
                    @contactsArr = (@contactsArr, getContacts(\@esc_arr, 1, $cmdh{status}, $cmdh{external_id}));
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
                    '1', $id, $cmdh{external_id}, $contact->{rule},
                    $check_type_str{$cmdh{check_type}},          $cmdh{status},
                    $cmdh{host},                $cmdh{service},
                    $method,           $contact->{mid}, $user,
                    'processing notification'
                );

                # TODO consider using timezones and converting time to user configurable format e.g. 
                # M/D/YY for USA
                # DD/MM/YYYY or DD.MM.YYYY for most of the World
                # until this is implemented we just use what we were given
		        # TODO do not queue here -> this is the job of the bundler thread
                #$queue{$cmd}->enqueue(prepareNotification($user, $method, $cmd, $dest, $from, $id, $datetime, $check_type, $status,
                #        $notification_type, $host, $host_alias, $host_address, $service, $output));
                if (suppressionIsActive($cmd, $conf->{$cmd}->{suppression}))
                {
                    updateLog($id, ' was suppressed');
                } else {
# TODO: pass hashes?
                    prepareNotification($cmdh{external_id}, $user, $method, $cmd, $dest, $from, $id, $cmdh{stime}, $cmdh{check_type}, $cmdh{status},
                        $cmdh{notification_type}, $cmdh{host}, $cmdh{host_alias}, $cmdh{host_address}, $cmdh{hostgroups}, $cmdh{service}, $cmdh{output}, $contact->{rule});
                }

            }

        }
    }



    # check for notification results
    RESULTSLOOP: if ( $msg = $msgq->dequeue_nb )
    {{
        # id= unique ID (per notification)
        my ( $id, $retval, @retstr ) = split( ';', $msg );
# TODO: Storable::thaw
        my $retstr = join( ';', @retstr );

        debug(
            "received message from notifier: id=$id, retval=$retval, retstr=$retstr"
        );

        # retrieve details from DB

        # check if this was a bundled alert, and split it, pushing the individual results back onto the queue

        if (is_a_bundle($id))
        {
            debug("Bundled reply received");
            foreach my $item (unbundle($id))
            {
                # delete the bundle from tmp active
                # remove the bundle id
                # push back onto queue
                $msgq->enqueue("$item;$retval;$retstr");
            }

            deleteFromActive($id);
            deleteFromCommands($id);
        }
        else
        {
            # check whether sending was successful
            if ( $retval != 0 )
            {

                # sending was NOT successful

                # foreach id;

                if (getRetryCounter($id) < $conf->{notifier}->{maxAttempts})
                {
                    # requeue notification and increment counter
            debug("requeueing notification $id");
                    requeueNotification($id);
                }
                else
                {
                    # retrieve the contact data

                    # try to get next method (method escalation)
                    my ($nextMethod, $nextMethodName, $nextMethodCmd, $nextFrom, $nextTo) = getNextMethod($id);

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

                        deleteFromActive($id);
                        # deleteFromCommands($id);

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
                        # $queue{$nextMethodName}->enqueue(getNextMethodCmd($id, $nextMethod));
                        # alter method for $id
                        # TODO: really try next method -> code here is wrong? last_method referenced in log....
                        $query = 'update tmp_active set method=\''.$nextMethodName.'\', notify_cmd=\''.$nextMethodCmd.'\', progress=\'0\', from_user=\''.$nextFrom.'\', dest=\''.$nextTo.'\', retries=\'0\' where notify_id=\''.$id.'\'';
                        updateDB($query);

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
                # but first retrieve the incident_id which created this notification
                my $incident_id = getIncidentIDfromNotificationID($id);
                deleteFromActive($id);
                # deleteFromCommands($id);

                 # if the method is flagged as ACKable then additionally remove it from the status
                 # table (i.e. Voicealert)
                 if (notificationAcknowledgable($id))
                 {
                     # feedback acknowledgement to nagios
                     sendAckToPipe($incident_id);
                     deleteFromStati($id);
                     deleteFromEscalations($incident_id);
                 }
    #             else
    #             {
    #                 # pass to escalator
    #                 debug("The ACK flag is not set for this method: internally escalating $id");
    #                 escalate($id);
    #             }
            }
        }

    }}

    # check for bundling / send commands
    # do this in the main loop to avoid any race conditions

    sendNotifications(\%queue, $conf->{notifier});

    # here we check if there are any events that we need to escalate ->
    # i.e anything in the escalation_stati table
    # We requeue the notifications in the future
    escalate($cmdq, $conf->{escalator});


    # remove any orphans from the tmp_command table
    deleteOrphanCommands();
    # sleep for a bit
    select( undef, undef, undef, 0.025 );
    # sleep 1;

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
    my %cmdh;
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
        (
            $cmdh{operation},             $cmdh{external_id},           $cmdh{host},
            $cmdh{host_alias},        $cmdh{host_address}, $cmdh{hostgroups}, $cmdh{service},
            $cmdh{check_type},        $cmdh{status},       $cmdh{stime},
            $cmdh{notification_type}, $cmdh{output}
        ) = split( ';', $cmd,12);

        if ( $cmdh{external_id} eq '' or $cmdh{external_id} < 1 ) { $cmdh{external_id} = unique_id(); }

        $cmdh{operation} = lc($cmdh{operation});

        if ( ($cmdh{stime} =~ /\D/) or ($cmdh{stime} < 1000000000))
        {
            debug("Invalid date $cmdh{stime} for notification - using time()");
            $cmdh{stime} = time();
        }

    if ( $cmd =~ /^notification;/i)
    {
      $sql = sprintf('insert into tmp_commands (operation, external_id, host, host_alias, host_address, hostgroups, service, check_type, status, stime, notification_type, output) values (\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\')',
            $cmdh{operation},             $cmdh{external_id},           $cmdh{host},
            $cmdh{host_alias},        $cmdh{host_address}, $cmdh{hostgroups}, $cmdh{service},
            $cmdh{check_type},        $cmdh{status},       $cmdh{stime},
            $cmdh{notification_type}, $cmdh{output});
	  updateDB($sql);
    }
        return %cmdh;
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

    if ( $cmd =~ /^suppress;([^;]*);*(.*)/i )
    {

        $suppressionHash{$1} = time();
        createLog('1', unique_id(), unique_id(), 0, '(internal)','OK','localhost','NoMa','(none)', '0',$2, "All $1 alerts have been suppressed by $2");
	deleteAllFromActive();
	deleteAllFromEscalations();
	deleteAllFromCommands();
    }

    return undef;

}


# ignores internally escalated rules
sub getNotificationCounter
{
    my ($host, $svc, $flag) = @_;
    my $counter;

    $counter = 0 unless defined($flag);

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
	my ($incident_id, $user, $method, $short_cmd, $dest, $from, $id,
	$datetime, $check_type, $status,
	$notification_type, $host, $host_alias, $host_address, $hostgroups, $service, $output, $rule, $nodelay) = @_;

	# start of the notification
	my $start = time();

	my $cmd = $conf->{command}->{$short_cmd};
	# error if script is missing
    my $error = undef;
	unless ( -x $cmd )
	{
	    $error .= ' Missing or unexecutable script: ' . $cmd;
	}

	# error if something is missing
	unless ( defined($cmd) )
	{
	    $error .= ' Missing command for notification belonging to: ' . $user;
	}
	unless ( defined($dest) )
	{
	    $error .= ' Missing destination for notification belonging to: ' . $user;
	}

    if (defined($error))
    {
        debug($error);
        updateLog($id, $error);
        return 0;
    }

	# default 'from'
	unless ( defined($from) )
	{
	    my $from = '';
	}

	# create parameter (FROM DESTINATION CHECK-TYPE DATETIME STATUS NOTIFICATION-TYPE HOST-NAME HOST-ALIAS HOST-IP OUTPUT [SERVICE])
	# my $param = sprintf(
#"\"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" \"%s\"",
#	    $from,  $dest,    $check_type,
#	    $datetime, $status,     $notification_type,
#	    $host,     $host_alias, $host_address,
#	    $output
#	);
#	$param .= " \"$service\"" if ( $check_type eq 's' );
#
#	debug("$whoami: BEFORE call - $method  $param");

    # if there is a configured delay, add it to the start time
    my $delay = $conf->{notifier}->{delay};
    $delay = 0 unless (defined($delay) and not defined($nodelay));


	# insert the command into our active notification list
	my $query = sprintf('insert into tmp_active (user, method, notify_cmd, time_string, notify_id, dest, from_user, rule, command_id, stime) (select \'%s\',\'%s\',\'%s\', \'%s\',\'%s\',\'%s\', \'%s\', \'%s\', id,(stime+\'%s\') from tmp_commands where external_id = \'%s\')',
		$user, $method, $short_cmd, $datetime, $id, $dest, $from, $rule, $delay, $incident_id);
    	
	updateDB($query);

	# return("$id;$start;1;$param");
	return 1;

}

sub deleteFromActive
{
    my ($id) = @_;

    return if (!$id);
    my $query = "delete from tmp_active where notify_id=$id";

    updateDB($query);
}

sub deleteAllFromActive
{
    my $query = "delete from tmp_active";
    updateDB($query);
}

sub deleteAllFromEscalations
{
    my $query = "delete from escalation_stati";
    updateDB($query);
}

sub deleteFromActiveByName
{
    my ($host, $service) = @_;

    my $query = 'select a.notify_id as notify_id from tmp_active as a left join notification_logs as l on a.notify_id=l.unique_id where l.host=\''.$host.'\' and l.service=\''.$service.'\'';
    my %dbResult = queryDB($query);
    foreach my $index (keys %dbResult)
    {
        deleteFromActive($dbResult{$index}{notify_id});
    }

}

sub deleteFromCommands
{
    my ($id) = @_;
    my $query;
    my %dbResult;

    return if (!$id);

    $query = 'select count(a.notify_id) as count from tmp_active as a left join notification_logs as l on a.notify_id=l.unique_id where l.incident_id=(select incident_id from notification_logs where unique_id='.$id.')';
    %dbResult = queryDB($query);

    if(!($dbResult{0}->{count}>0))
    {
      $query = "delete from tmp_commands where external_id in (select incident_id from notification_logs where unique_id=$id)";
    }

    updateDB($query);
}



sub deleteAllFromCommands
{
    my $query = "delete from tmp_commands";
    updateDB($query);
}

sub deleteOrphanCommands
{
    my $query = "delete from tmp_commands where external_id not in (select distinct incident_id from notification_logs right join tmp_active on notification_logs.unique_id=tmp_active.notify_id union select distinct incident_id from escalation_stati)";
    updateDB($query, 1);
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

sub sendAckToPipe
{
    my ($id) = @_;

    my $file = $conf->{notifier}->{ackPipe};
    return unless (defined($file) and $file ne '');
    my $ackstr;
    my $host;
    my $svc;
    my $contact;

    my $query = "select host,service,user from notification_logs where incident_id=$id";
    my %dbResult = queryDB($query);

    $host = $dbResult{0}->{host};
    $svc = $dbResult{0}->{service};
    $contact = $dbResult{0}->{user};
    if ($svc eq '')
    {
        $ackstr = "[".time()."] ACKNOWLEDGE_HOST_PROBLEM;$host;1;1;0;NoMa;Acknowledged by $contact\n";
    } else {
        $ackstr = "[".time()."] ACKNOWLEDGE_SVC_PROBLEM;$host;$svc;1;1;0;NoMa;Acknowledged by $contact\n";
    }

    if (!sysopen(PIPE, $file, O_WRONLY | O_APPEND | O_NONBLOCK))
    {
	debug("Failed to open Ack Pipe $file");
	return;
    }

    debug("Writing $ackstr to $file");
    syswrite(PIPE,$ackstr);
}

sub getNextMethod
{

    # get params
    my ( $notify_id ) = @_;
    my $query;
    my $next_id;
    my $method;
    my $command;
    my $from;
    my $tofield;
    my $to;

    # get next escalation method
    $query =
      sprintf(
'select id, method, command, notification_methods.from as fromuser, contact_field from notification_methods where id = (select m.on_fail from notification_methods m left join notification_logs as l on l.last_method=m.id where l.unique_id=\'%s\')',
	$notify_id);
    my %dbResult = queryDB($query);

    ($next_id, $method, $command, $from, $tofield) = ($dbResult{0}->{id}, $dbResult{0}->{method}, $dbResult{0}->{command}, $dbResult{0}->{fromuser}, $dbResult{0}->{contact_field});
    return (0, '/bin/true') if (!defined($next_id) or $next_id == 0);

    $query = sprintf('select %s from contacts as c, notification_logs as l where c.username=l.user and l.unique_id=\'%s\'', $tofield, $notify_id);
    %dbResult = queryDB($query);
    $to = $dbResult{0}->{$tofield};

    $query = sprintf('update notification_logs set last_method=\'%s\' where unique_id=\'%s\'', $next_id, $notify_id);
    updateDB($query);

    return ($next_id, $method, $command, $from, $to);

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

# return unique_id for a notification_id
sub getIncidentIDfromNotificationID
{
    my ($id) = @_;

    my $query = 'select c.external_id as id from tmp_commands as c inner join tmp_active as t on c.id=t.command_id
                    where t.notify_id=\''.$id.'\'';

    my %dbResult = queryDB($query);
    return $dbResult{0}->{id};

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
        getNotificationCounter($host, $service, 1);

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

    $query = 'update notification_stati set counter=1
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

    my $query = 'select notify_after_tries from notifications where id in ('.join(',',@$ids).') and rollover=1';
    $query .= ' union select e.notify_after_tries from escalations_contacts as e';
    $query .= ' left join notifications as n on e.notification_id=n.id where notification_id in ('.join(',',@$ids).') and rollover=1';

	my @dbResult = queryDB($query, '1');

    my $maxval = 0;

	foreach my $tries (@dbResult)
	{
        my $max = getMaxValue($tries->{notify_after_tries});
		$maxval = $max if ($max > $maxval);
	}
    return 0 if ($maxval >= $counter);
    return 0 if ($maxval == 0);
    my $retval = $counter % $maxval;
    $retval = $maxval if($retval == 0);

    debug("notification counter rollover: $counter exceeds $maxval -> continuing at $retval");
    return $retval;
}

# vim: ts=4 sw=4 expandtab
# EOF
