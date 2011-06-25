#!/usr/bin/perl -w

# COPYRIGHT:
#  
# This software is Copyright (c) 2007 NETWAYS GmbH, Christian Doebler 
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
# usage: sendEmail.pl <EMAIL-FROM> <EMAIL-TO> <CHECK-TYPE> <DATETIME> <STATUS> <NOTIFICATION-TYPE> <HOST-NAME> <HOST-ALIAS> <HOST-IP> <INCIDENT ID> <AUTHOR> <COMMENT>  <OUTPUT> [SERVICE]
#
#

# TODO: URLize $service
# TODO: Localize Date/Time Field


use strict;
use CGI;
#use Email::Valid;
use FindBin;
use lib "$FindBin::Bin";
use noma_conf;
my $conf = conf();


# check number of command-line parameters
my $numArgs = $#ARGV + 1;
exit 1 if ($numArgs != 13 && $numArgs != 14);


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
my $filename = '';
my $file = '';
my $sendmail = "/usr/sbin/sendmail -t";
my $subject = 'Subject: NoMa Alert';
my $message = "$host/$service is $status\n$output\n";
my $datetime = scalar(localtime($datetimes));

$service = $ARGV[13] if ($numArgs == 14);


# check email format
#exit 1 unless (Email::Valid->address($from));
#exit 1 unless (Email::Valid->address($to));

$from = "From: " . $from;
$to = "To: " . $to;


if ($check_type eq 'h')
{
    $subject = 'Subject: '.$conf->{sendemail}->{message}->{host}->{subject} if (defined( $conf->{sendemail}->{message}->{host}->{subject}));
    if (($authors ne '') or ($comment ne ''))
    {
        $message = $conf->{sendemail}->{message}->{host}->{ackmessage} if (defined( $conf->{sendemail}->{message}->{host}->{ackmessage}));
    } else {
        $message = $conf->{sendemail}->{message}->{host}->{message} if (defined( $conf->{sendemail}->{message}->{host}->{message}));
    }
    $filename = $conf->{sendemail}->{message}->{host}->{filename} if (defined( $conf->{sendemail}->{message}->{host}->{filename}));

} else {
    $subject = 'Subject: '.$conf->{sendemail}->{message}->{service}->{subject} if (defined( $conf->{sendemail}->{message}->{service}->{subject}));
    if (($authors ne '') or ($comment ne ''))
    {
	$message = $conf->{sendemail}->{message}->{service}->{ackmessage} if (defined( $conf->{sendemail}->{message}->{service}->{ackmessage}));
    } else {
	$message = $conf->{sendemail}->{message}->{service}->{message} if (defined( $conf->{sendemail}->{message}->{service}->{message}));
    }
    $filename = $conf->{sendemail}->{message}->{service}->{filename} if (defined( $conf->{sendemail}->{message}->{service}->{filename}));
}

if ($filename ne "")
{
    # this is a file to be included in the text - N.B. it is up to the user to ensure the encoding agrees with the rest of the message
    # expand $service / $host etc.
    $filename =~ s/(\$\w+)/$1/gee;
    $filename =~ s/[^\w\.\/]/_/g;
    # print "got filename $filename\n";
    if (-e $filename)
    {
        # read into $file
        my $lt = $/;
        undef $/;
        if(open(FILE, "< $filename"))
        {
            $file = <FILE>;
            close FILE;
        }
        $/ = $lt;
    }
}

$sendmail = $conf->{sendemail}->{sendmail} if (defined($conf->{sendemail}->{sendmail}));

$subject =~ s/(\$\w+)/$1/gee;
$message =~ s/(\$\w+)/$1/gee;

open(SENDMAIL, "|$sendmail") or exit 1;
print SENDMAIL $subject . "\n";
print SENDMAIL $from . "\n";
print SENDMAIL $to . "\n";
print SENDMAIL "Content-type: text/plain; charset=utf-8\n";
print SENDMAIL "Content-Transfer-Encoding: 8bit\n";
print SENDMAIL "\n";
print SENDMAIL $message . "\n";
close(SENDMAIL);

exit 0;
