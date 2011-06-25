#!/usr/bin/perl -w

# COPYRIGHT:
#
# This software is Copyright (c) 2010 NETWAYS GmbH, Birger Schmidt
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
# usage: sendSMSfinder.pl <EMAIL-FROM> <EMAIL-TO> <CHECK-TYPE> <DATETIME> <STATUS> <NOTIFICATION-TYPE> <HOST-NAME> <HOST-ALIAS> <HOST-IP> <INCIDENT ID> <AUTHOR> <COMMENT>  <OUTPUT> [SERVICE]
#
#


use strict;
use Digest::MD5 qw(md5_hex);
use Data::Dumper;
use FindBin;
use lib "$FindBin::Bin";
my $scriptPath = $FindBin::Bin;
my $whoami = $FindBin::Script;
use noma_conf;
my $conf = conf();
my $debug = $conf->{debug}->{sms};



# check number of command-line parameters
my $numArgs = $#ARGV + 1;
if ($numArgs != 13 && $numArgs != 14)
{
	print "wrong number of parameters ($numArgs)\n";
	exit 1;
}

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
my $comment = $ARGV[11];
my $output = $ARGV[12];
my $service = '';
my $datetime = localtime($datetimes);
$service = $ARGV[13] if ($numArgs == 14);


my $message = '';
if ($check_type eq 'h') {
	$message .= $conf->{sendsms}->{message}->{host};
} elsif ($check_type eq 's') {
	$message .= $conf->{sendsms}->{message}->{service};
} else {
	debugLog("don't know if we handle a host or a service.\n");
	exit 1;
}
$message =~ s/(\$\w+)/$1/gee;

#debugLog("$to\t$host\t$service\t$check_type\t$status\n");
my $ret_str;

my ($server, $user, $pass) = selectAppliance($conf->{sendsms}->{server}, $conf->{sendsms}->{user}, $conf->{sendsms}->{pass}, $conf->{sendsms}->{check_command});
my $scriptParams = "-H $server -u $user -p $pass --noma -n $to -m '$message'";

my $scriptName = 'sendsms.pl';

debugLog("commandline: $scriptPath/$scriptName $scriptParams");
$ret_str = `$scriptPath/$scriptName $scriptParams`;


my $ret_val = $?;
$ret_val /= 256 if ($ret_val != 0);

debugLog("$to\t$host\t$service\t$check_type\t$status\t$ret_str\t$ret_val");

print $ret_str;
exit($ret_val);


sub debugLog
{
	my ($debugStr) = @_;

	if (defined($debug)) {
		open (DEBUGLOG, ">> $debug");
		print DEBUGLOG "$whoami: $debugStr\n";
		#print "$whoami: $debugStr\n";
		close (DEBUGLOG);
	}
}

sub selectAppliance
{
	my ($servers, $users, $passs, $check_command) = @_;

	my $server = '';
	my $user = '';
	my $pass = '';

	if (ref($servers) eq 'ARRAY'){
		#It's an array reference...
		#you can read it with $item->[1]
		#or dereference it uisng @newarray = @{$item}
		
		# select one of the appliances - maybe one that works fine
		# ...
		for (my $i = 0; $i <= (scalar(@{$servers})-1); $i++) {
			$server = $servers->[$i];
			$user = $users->[$i];
			$pass = $passs->[$i];

			$check_command =~ s/(\$\w+)/$1/gee;
			#debugLog("check_command: ".$check_command);
			system($check_command);
			if ($? == -1) {
    				debugLog("failed to execute: $!\n");
			}
			elsif ($? & 127) {
    				debugLog(sprintf "check '%s' died with signal %d, %s coredump\n",
    				$check_command, ($? & 127),  ($? & 128) ? 'with' : 'without');
			}
			elsif ($? != 0) {
    				debugLog(sprintf "check '%s' exited with value %d\n", $check_command, $? >> 8);
			}
			else {
    				debugLog("server $server seems to work fine - use it.");
				last;
			} 
		}

	} else {
		#not an array in any way... just take it as it is
		$server = $servers;
		$user = $users;
		$pass = $passs;
	}

	return ($server, $user, $pass);
}
