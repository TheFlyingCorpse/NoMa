#!/usr/bin/perl -w

# COPYRIGHT:
#  
# This software is Copyright (c) 2007 NETWAYS GmbH, Michael Streb
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


#
# usage: sendSMS.pl <EMAIL-FROM> <EMAIL-TO> <CHECK-TYPE> <DATETIME> <STATUS> <NOTIFICATION-TYPE> <HOST-NAME> <HOST-ALIAS> <HOST-IP> <INCIDENT ID> <AUTHOR> <COMMENT>  <OUTPUT> [SERVICE]
#
#


use strict;
use CGI;
use Net::Growl;
use FindBin;
use lib "$FindBin::Bin";
use noma_conf;
my $conf = conf();


# check number of command-line parameters
my $numArgs = $#ARGV + 1;
exit 1 if ($numArgs != 13 && $numArgs != 14);


my $application = $conf->{growl}->{application_name};
my $password = $conf->{growl}->{password};
my $subject = '';
my $priority = 0;
my $sticky = 0;
# get parameters
my $from = $ARGV[0];
my $to = $ARGV[1];
my $check_type = $ARGV[2];
my $datetimes = $ARGV[3];
my $status = $ARGV[4];
my $notification_type = $ARGV[5];
my $host = $ARGV[6];
my $host_alias = $ARGV[7];
my $host_address = $ARGV[8];
my $incident_id = $ARGV[9];
my $authors = $ARGV[10];
my $comments = $ARGV[11];
my $output = $ARGV[12];
my $service = '';
my $datetime = localtime($datetimes);
$service = $ARGV[13] if ($numArgs == 14);


my $message = '';

#if ($check_type eq 'h') {
#	$message .= "NoMa: ID $incident_id - Host $host is $status! $datetime";
#} elsif ($check_type eq 's') {
#	$message .= "NoMa: ID $incident_id - $host - $service is $status! $datetime";
#} else {
#	exit 1;
#}

if ($check_type eq 'h')
{
    if (($authors ne '') or ($comments ne ''))
    {
        $subject = $conf->{growl}->{subject_host} if (defined( $conf->{growl}->{subject_host}));
        $message = $conf->{growl}->{ackmessage}->{host} if (defined( $conf->{growl}->{ackmessage}->{host}));
    } else {
        $subject = $conf->{growl}->{subject_host} if (defined( $conf->{growl}->{subject_host}));
        $message = $conf->{growl}->{message}->{host} if (defined( $conf->{growl}->{message}->{host}));
    }

} else {
    if (($authors ne '') or ($comments ne ''))
    {
        $subject = $conf->{growl}->{subject_service} if (defined( $conf->{growl}->{subject_service}));
        $message = $conf->{growl}->{ackmessage}->{service} if (defined( $conf->{growl}->{ackmessage}->{service}));
    } else {
        $subject = $conf->{growl}->{subject_service} if (defined( $conf->{growl}->{subject_service}));
        $message = $conf->{growl}->{message}->{service}  if (defined( $conf->{growl}->{message}->{service}));
    }
}


# Replace read message with the content of variables.
$message =~ s/(\$\w+)/$1/gee;
$subject =~ s/(\$\w+)/$1/gee;

# Find and set priority based on notification_type and status
if (($notification_type eq 'PROBLEM' and $status eq 'DOWN') or ($notification_type eq 'PROBLEM' and $status eq 'UNKNOWN') or ($notification_type eq 'PROBLEM' and $status eq 'CRITICAL') or ($notification_type eq 'FLAPPINGSTART') or ($notification_type eq 'CUSTOM') or ($notification_type ne 'ACKNOWLEDGEMENT'))
{
    $priority = 2;
    $sticky = 1;
}
if (($notification_type eq 'PROBLEM' and $status eq 'WARNING') or ($notification_type eq 'PROBLEM' and $status eq 'UNREACHABLE'))
{
    $priority = 1;
    $sticky = 0;
}
if (($notification_type eq 'RECOVERY') or ($notification_type eq 'FLAPPINGSTOP') or ($notification_type eq 'DOWNTIMESTART') or ($notification_type eq 'DOWNTIMEEND'))
{
    $priority = 0;
    $sticky = 0;
}
if (($notification_type eq 'FLAPPINGDISABLED') or ($notification_type eq 'DOWNTIMECANCELLED'))
{
    $priority = -2;
    $sticky = 0;
}

#
# Main program
#
 
# Set up the Socket
my %addr = (
  PeerAddr => $to,
  PeerPort => Net::Growl::GROWL_UDP_PORT,
  Proto    => 'udp',
);
 
my $s = IO::Socket::INET->new ( %addr ) || die "Could not create socket: $!\n";
 
# Register the application
my $p = Net::Growl::RegistrationPacket->new(
  application => $application,
  password    => $password,
);
 
$p->addNotification();
 
print $s $p->payload();
 
# Send a notification
$p = Net::Growl::NotificationPacket->new(
  application => $application,
  title       => $subject,
  description => $message,
  priority    => $priority,
  sticky      => $sticky,
  password    => $password,
);
 
print $s $p->payload();
 
close($s);

exit 0;
