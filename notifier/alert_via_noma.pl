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

alert_via_noma.pl  -  NETWAYS Notification Manager - notification plugin

=head1 SYNOPSIS

             -H|--host=<host name>
             -S|--service=<service description>
             -c|--check-type=<check type (h|s)>
             -s|--status=<check status>
             -t|--datetime=<date time>
             -a|--host-alias=<host alias>
             -i|--host-address=<host ip>
             -o|--output=<host- or serviceoutput>
             -n|--notification-type=<notification type>
             [-p|--pipe]
             [-u|--unique-id=<unique notification ID>]
             [-h|--help] [-V|--version]


=head1 OPTIONS

=over

=item -H|--host=<name-or-ip>

Name of the affected host

=item -S|--service=<name-or-ip>

Name of the affected service

=item -c|--check-type=<check type (h|s)>

Type of check: h for host, s for service

=item -s|--status=<status>

Numeric status of check. (= check result)

=item -t|--datetime=<date time>

Date and time (string) when check took place.

=item -a|--host-alias=<host alias>

Host alias.

=item -i|--host-address=<host ip>

Host's IP address.

=item -o|--output=<host- or serviceoutput>

Host- or Serviceoutput

=item -n|--notification-type=<notification type>

Notification type.

=item -p|--pipe

Use a local FIFO instead of a network connection

=item -u|--unique-id

Specify the ID of this event (optional)

=item -V|--version

Print version an exit.

=item -h|--help

Print help message and exit.

=back

=head1 DESCRIPTION

Can be integrated into nagios with the following

For services;
  command_line    /path_to_noma/alert_via_noma.pl -c s -s "$SERVICESTATE$" -H "$HOSTNAME$" -S "$SERVICEDESC$" -o "$SERVICEOUTPUT$" -n "$NOTIFICATIONTYPE$" -a "$HOSTALIAS$" -i "$HOSTADDRESS$" -t "$SHORTDATETIME$"

For hosts;
  command_line    /path_to_noma/alert_via_noma.pl -c h -s "$HOSTSTATE$" -H "$HOSTNAME$" -n "$NOTIFICATIONTYPE$" -i "$HOSTADDRESS$" -o "$HOSTOUTPUT$" -t "$SHORTDATETIME$"


=cut

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use POSIX;
use Digest::MD5 qw(md5_hex);
use FindBin;
use lib "$FindBin::Bin";
use noma_conf;

use Data::Dumper;
use threads;
use Thread::Queue;
use IO::Select;
use Fcntl qw(O_RDWR);
use IO::Socket;

my $versionStr = 'current (1.0.3)';

my %check_type_str = (
    'h' => 'Host',
    's' => 'Service',
    ''  => '',
);

my $host                = '';
my $host_alias          = '';
my $host_address        = '';
my $service             = '(host notification)';
my $check_type          = '';
my $status              = '';
my $datetime            = '';
my $output              = '';
my $notification_type   = '';
my $verbose             = undef;
my $version             = undef;
my $help                = undef;
my $id                  = undef;
my $usefifo		= 0;

my $query               = '';
my $notificationCounter = 0;
my $notifierPID         = 0;
my $notifierUser        = 'nagios';
my $notifierBin         = 'noma_notifier.pl';
my $now                 = 0;

my $reloop_delay        = 1;
my $acknowledged        = 0;
my $loop_until_ack      = 0;
my $sleep               = 0;
my $keep_on_looping     = 1;
my $pipe                = undef;
my $saddr               = undef;
my $sport               = undef;

my $log_count           = 0;
my @triesPerID;
my $max_notificationCounter = 0;
my $additional_run          = 0;

#my $debug = undef;
my $debug = 1;

#my $debug_queries = undef;
my $debug_queries = 1;
my $do_not_send   = undef;

my $debug_file = undef;		# '/usr/local/nagios/var/noma_debug.log';
#my $debug_file = './noma_debug.log';
my $paramlog   = undef;             # '/usr/local/nagios/var/noma_args_log.txt';
my $whoami     = 'notifier';
my $cmd;


my $conf  = conf();
my $cache = $conf->{path}->{cache};


##############################################################################
# HANDLING OF COMMAND-LINE PARAMETERS
##############################################################################


Getopt::Long::Configure('bundling');
my $clps = GetOptions(

    "H|host=s"              => \$host,
    "u|unique-id=s"         => \$id,
    "a|host-alias=s"        => \$host_alias,
    "i|host-address=s"      => \$host_address,
    "S|service=s"           => \$service,
    "c|check-type=s"        => \$check_type,
    "s|status=s"            => \$status,
    "t|datetime=s"          => \$datetime,
    "n|notification-type=s" => \$notification_type,
    "o|output=s"            => \$output,
    "V|version"             => \$version,
    "p|pipe"                => \$usefifo,
    "h|help"                => \$help

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

if ( $notification_type ne 'PROBLEM' and $notification_type ne 'RECOVERY')
{
    exit 0;
}

if ( !defined $id or $id eq '' or $id < 1 )
{
    $id = unique_id();
}

$cmd = sprintf('NOTIFICATION;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s',
    $id, $host, $host_alias, $host_address, $service, $check_type, $status, $datetime, $notification_type, $output);

if ($usefifo)
{
    $pipe = $conf->{input}{pipePath};
    if (defined $pipe and $pipe ne '')
    {
        writeToPipe($cmd, $pipe);
    } else { die "Pipe not configured"; }

} else {
    $saddr = $conf->{input}{socketAddress};
    $sport = $conf->{input}{socketPort};

    if (!defined $saddr or $saddr eq '')
    {
        $saddr = "localhost";
    }


    if (defined $sport and $sport ne '')
    {
        writeToSocket($cmd, $saddr, $sport);
    } else {
        die "Socket port not configured";
    }

}

exit 0;

##############################################################################
# SUBROUTINES START HERE
##############################################################################


# open a pipe and write command
sub writeToPipe
{

    my ( $output, $pipe ) = @_;
    my $written;

    die "Pipe not available" unless -p $pipe;

    sysopen( PIPE, $pipe, O_WRONLY ) or die "Pipe not writeable";

    $written = syswrite PIPE, $output;

    close PIPE;

    return ($written == length($output));

}

sub writeToSocket
{

	my ( $output, $remote, $port) = @_;

	my $sock = new IO::Socket::INET (
		Proto   	=> 'tcp',
		PeerPort	=> $port,
		PeerAddr    => $remote
	);
	
	die "Socket not available" unless $sock;

    print $sock $output;

    close($sock);

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

sub debugArray
{
    my @array  = @_;
    my $output = '';
    for my $data (@array)
    {
        $output .= "  $data\n";
    }
    return $output;
}

sub debugHash
{
    my %hash   = @_;
    my $empty  = 1;
    my $output = '';
    while ( my ( $key, $value ) = each %hash )
    {
        $output .= "$key\n";
        while ( my ( $innerKey, $innerValue ) = each %{ $hash{$key} } )
        {
            $innerKey   = '_NULL_' if ( !defined($innerKey) );
            $innerValue = '_NULL_' if ( !defined($innerValue) );
            $output .= "     $innerKey - $innerValue\n";
        }
        $empty = 0 if ( $empty == 1 );
    }
    $output .= "EMPTY!\n" if ( $empty == 1 );
    return $output;
}

sub debug
{

    my ($msg) = @_;

    if ( defined($debug) && $debug )
    {

        $msg .= "\n";

        if ( defined($debug_file) && $debug_file ne '' )
        {

            open( DEBUGFILE, ">> $debug_file" );
            print DEBUGFILE $msg;
            close(DEBUGFILE);

        } else
        {

            print $msg;

        }

    }

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

sub msgAndExit
{

    my ( $msg, $usage ) = @_;

    print 'ERROR: ' . $msg . "\n";

    if ( defined($usage) )
    {
        if ( $usage == 2 )
        {
            pod2usage( -verbose => 1 );
        } else
        {
            pod2usage();
        }
    }

    exit(1);

}

# vim: ts=4 sw=4 expandtab
# EOF
