#!/usr/bin/perl -w

# COPYRIGHT:
#  
# This software is Copyright (c) 2010 NETWAYS GmbH
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
# usage: sendToNagios.pl <FROM> <TO> <CHECK-TYPE> <DATETIME> <STATUS> <NOTIFICATION-TYPE> <HOST-NAME> <HOST-ALIAS> <HOST-IP> <OUTPUT> [SERVICE]
#
#

use strict;
use FindBin;
use lib "$FindBin::Bin";
use noma_conf;
my $conf = conf();


# check number of command-line parameters
my $numArgs = $#ARGV + 1;
exit 1 if ($numArgs != 10 && $numArgs != 11);

my %statush = (
	'OK'		=> 0,
	'WARNING'	=> 1,
	'CRITICAL'	=> 2,
	'UNKNOWN'	=> 3,
	'UP'		=> 0,
	'DOWN'		=> 1,
	'UNREACHABLE'	=> 2);

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
my $output = $ARGV[9];
my $service = '';
my $filename = '';
my $file = '';
my $nagiospipe = "/usr/local/nagios/var/rw/nagios.cmd";
my $command;

$service = $ARGV[10] if ($numArgs == 11);

# Hardcode here
# $host = "myhost";
# $service = "my service"


if ($check_type eq 'h')
{
	$command = "PROCESS_HOST_CHECK_RESULT;$host;".$statush{$status}.";$output";
} else {
	$command = "PROCESS_SERVICE_CHECK_RESULT;$host;$service;".$statush{$status}.";$output";
}


$nagiospipe = $conf->{nagios}->{pipe} if (defined($conf->{nagios}->{pipe}));


open(NAGIOS, ">$nagiospipe") or exit 1;
print NAGIOS "[".time()."] $command\n";
close(NAGIOS);

exit 0;
