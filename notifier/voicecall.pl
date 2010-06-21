#!/usr/bin/perl -w
# vim:expandtab:ts=8
# $Id: version 1.0$

=pod

=head1 COPYRIGHT

 
This software is Copyright (c) 2008-2009 NETWAYS GmbH, William Preston
                               <support@netways.de>

(Except where explicitly superseded by other copyright notices)

=head1 LICENSE

This work is made available to you under the terms of Version 2 of
the GNU General Public License. A copy of that license should have
been provided with this software, but in any event can be snarfed
from http://www.fsf.org.

This work is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
02110-1301 or visit their web page on the internet at
http://www.fsf.org.


CONTRIBUTION SUBMISSION POLICY:

(The following paragraph is not intended to limit the rights granted
to you to modify and distribute this software under the terms of
the GNU General Public License and is only of importance to you if
you choose to contribute your changes and enhancements to the
community by submitting them to NETWAYS GmbH.)

By intentionally submitting any modifications, corrections or
derivatives to this work, or any other work intended for use with
this Software, to NETWAYS GmbH, you confirm that
you are the copyright holder for those contributions and you grant
NETWAYS GmbH a nonexclusive, worldwide, irrevocable,
royalty-free, perpetual, license to use, copy, create derivative
works based on those contributions, and sublicense and distribute
those contributions and any derivatives thereof.

Nagios and the Nagios logo are registered trademarks of Ethan Galstad.

=head1 NAME

voicecall.pl

=head1 SYNOPSIS

Originates a call using the asterisk manager interface

=head1 OPTIONS

=over

=item   B<--number>

Number to call

=item   B<--context>

asterisk context (default nagios)

=item   B<--channel>

asterisk channel (default mISDN/g:extern)

=item   B<--suffix>

optional asterisk channel suffix (default blank)

=item   B<--callid>

optional asterisk call ID (default random)

=item   B<--user>

user for the asterisk manager interface (default nagios)

=item   B<--pass>

password for the asterisk manager interface (default nagios)

=item   B<--port>

port for the asterisk manager interface (default 5038)

=item   B<--asterisk>

the address of the asterisk server (default localhost)

=item   B<--host>

the name of the host from nagios used for acknowledgements

=item   B<--service>

the name of the service from nagios used for acknowledgements (default blank)

=item   B<--contact>

the name of the contact from nagios used for acknowledgements (default blank)

=item   B<--timeout>

how long to wait for the connection (default 30)

=item   B<--verbose>

verbose messages to stderr

=back

=head1 DESCRIPTION

This script is used to originate an outgoing call with asterisk using the
management interface (TCP/5038).  The message should be piped to stdin.  
It requires a valid user to be configured for the manager...

In order to work a user need to be configured in /etc/asterisk/manager.conf
e.g.

=begin text

[nagios]
secret = nagios
read = call,user
write = call

=end text

The user events also need to be configured in the dialplan to return
the status to this script.

=begin text

[nagios]
;
; We start with what to do when a call first comes in.
;
exten => s,1,NoOp
exten => s,n,Wait(1)
exten => s,n,Answer()
exten => s,n,Playback(nagios/welcome)
exten => s,n,Set(LOOP=12345)            ; loop up to 5 times
; exten => s,n(loop),flite(${MSG})            ; flite uses the festival light engine
exten => s,n(loop),Swift(${MSG})                ; swift uses the cepstral engine
exten => s,n,Set(TIMEOUT(response)=4)   ; timeout if no keypress after 4 seconds
exten => s,n,Background(nagios/acknowledge)
exten => s,n,Set(LOOP=${LOOP:1})
exten => s,n,Wait(4)
exten => s,n,GotoIf($["${LOOP}x" != "x"]?loop)  ; loop

exten => s,n,hangup

exten => h,1,NoOp
exten => h,n,UserEvent(HUP-${ID})
exten => h,n,hangup

exten => t,1,Goto(s,loop)
exten => i,1,Background(invalid)
exten => i,n,Goto(s,loop)


exten => 1,1,NoOp
exten => 1,n,AGI(acknowledge.agi|${HOST}|${SVC}|${CONTACT})     ; send the acknowledgement to nagios
exten => 1,n,UserEvent(ACK-${ID})
exten => 1,n,Playback(nagios/confirmed)
exten => 1,n,Hangup

exten => 4,1,NoOp
exten => 4,n,UserEvent(end)

=end text

=head1 HISTORY

v1.4 added timeouts
v1.3 Extended documentation
v1.2 Feedback via User Events
v1.1 bugfixes
v1.0 initial release


=cut

use Getopt::Long qw(:config bundling no_ignore_case);;
use Pod::Usage;
use IO::Socket;
use lib '/usr/local/nagios/libexec/';
use lib '/usr/lib/nagios/plugins/';
use utils qw(%ERRORS &print_revision);



sub nagexit($$);
sub connect_am($$$$);
sub send_am($@);

(my $scriptname = $0) =~ s#.*/##;
my $warning = 40;
my $critical = 20;
my $tout = 120;
my $number = undef;
my $verbose = undef;
my $asterisk = "localhost";
my $port = "5038";
my $user = "nagios";
my $pass = "nagios";
my $context = "nagios";
my $channel = "mISDN/g:extern";
my $suffix = "";
my $contact = "Asterisk";
my $callid = int(rand(10**9));
my $msg = "";
our $sock = undef;

# check the command line options
Getopt::Long::Configure('bundling');
GetOptions('help|?' => \$help,
           'V|version' => \$version,
           't|timeout=i' => \$tout,
           'n|number=s' => \$number,
           'v|verbose' => \$verbose,
           'context=s' => \$context,
           'user=s' => \$user,
           'pass=s' => \$pass,
           'p|port=s' => \$port,
           'asterisk=s' => \$asterisk,
           'h|host=s' => \$host,
           's|service=s' => \$service,
           'c|contact=s' => \$contact,
           'C|channel=s' => \$channel,
           'suffix=s' => \$suffix,
           'callid=s' => \$callid,
           'w|warn|warning=i' => \$warning,
           # 'c|crit|critical=i' => \$critical); # c option removed for backwards compatibility
           'crit|critical=i' => \$critical);

# if ($#ARGV!=0) {$help=1;} # wrong number of command line options
# pod2usage( -verbose => 99, -sections => "NAME|COPYRIGHT|SYNOPSIS|OPTIONS") if $help;
pod2usage(1) if $help;
if ($version)
{
        print_revision($scriptname, '$Revision: 1.0$') if $version;
        exit 0;
}


nagexit('CRITICAL', "No number specified") if not defined($number);
nagexit('CRITICAL', "No host specified") if not defined($host);
$service = "" if not defined($service);

my ($exitcode, $exitmsg) = ('CRITICAL', "Timeout in notification script");
$SIG{'ALRM'} = sub { nagexit($exitcode, $exitmsg) };
alarm($tout);

while (<>) {
        $msg .= $_;
}

$msg =~ s/\n//g; # remove line breaks 
$msg =~ s/([^0-9a-zA-Z \\]|\\[^n])//g; # remove unspoken characters (except for "\n")
$msg =~ s/\\n/<break \/>/g; # replaces all occurrences of the string "\n" with a sentence break


$sock = connect_am($asterisk, $port, $user, $pass) or nagexit('CRITICAL', "Connect failed");

print STDERR "connect succeeded\n" if $verbose;



send_am("Originate", ("Channel: $channel/$number$suffix", "Context: $context", "Callerid: Nagios_NoMa", "Exten: s", "Priority: 1",
                       "Variable: HOST=$host", "Variable: SVC=$service", "Variable: CONTACT=$contact", 
                       "Variable: MSG=$msg", "Variable: ID=$callid", "Timeout: 30000"));


my @reply = read_am();

($exitcode, $exitmsg) = ('CRITICAL', "Asterisk has not confirmed successful queueing of call");

foreach $reply (@reply) {
                if ($reply =~ /Success/) {
                        ($exitcode, $exitmsg) = ('WARNING', "Call successfully queued, but no acknowledgement received");
                        last;
                }
}

if ($exitcode eq 'CRITICAL') { nagexit($exitcode, $exitmsg); }
print STDERR "waiting for user event\n" if $verbose;

# wait for the user event from asterisk; we set an alarm timeout in case user events are disabled
# or the 

# reset the timeout
alarm($tout);
ACKLOOP: while ($exitcode ne 'OK')
{
        my @reply = read_am();
        foreach $reply (@reply) {
                        if ($reply =~ /^UserEvent: ACK-$callid/i) {
                                print STDERR "call acknowledged by end user\n" if $verbose;
                                ($exitcode, $exitmsg) = ('OK', "Call was acknowledged by end user");
                                last ACKLOOP;
                        }
                        if ($reply =~ /^UserEvent: HUP-$callid/i) {
                                print STDERR "call was hungup without acknowledgement\n" if $verbose;
                                ($exitcode, $exitmsg) = ('CRITICAL', "Call was not acknowledged by end user");
                                last ACKLOOP;
                        }
        }
}

# logout
print STDERR "logging off\n" if $verbose;
send_am("Logoff");

nagexit($exitcode, $exitmsg);





sub nagexit($$) {
        my $errlevel = shift;
        my $string = shift;

        print "$errlevel: $string\n";
        exit $ERRORS{$errlevel};
}

sub read_am {
        my @retval;

        while (my $reply = <$sock>) {

                # all replies are terminated with \r\n

                last if ($reply eq "\r\n");
                $reply =~ s/\r\n//; # chomp
                push(@retval, $reply) if $reply;
        }
        return @retval;
}

sub send_am($@) {
        my $action = shift;
        my @params = @_;


        $sock->send("Action: $action\r\n");
        foreach my $param (@params) {
                $sock->send("$param\r\n");
        }

        # command is complete
        $sock->send("\r\n");

        # check for "Response: Success" ??
        return 0;
}
                

sub connect_am($$$$) {
        my $host = shift;
        my $port = shift;
        my $user = shift;
        my $secret = shift;

        my $reply;

        our $sock = IO::Socket::INET->new( PeerAddr => $host, PeerPort => $port, Proto => 'tcp');

        if (!$sock) {
                # connect failed
                print "Connect to $host:$port failed\n";
                return undef;
        }

        # autoflush should be on
        
        $reply = <$sock>;
        $reply =~ s/\r\n//; # chomp

        if (defined($reply)) {
                if ($reply !~ /Asterisk Call Manager/) {
                        print "Unknown reply received.  Are you connecting to the correct port?\n";
                        return undef;
                }
        } else {
                print "No reply received";
                return undef;
        }


        send_am("Login", ("Username: $user", "Secret: $secret", "Events: user"));

        my @reply = read_am();

        
        foreach $reply (@reply) {
                if ($reply =~ /Authentication accepted/) {
                        return $sock;
                }
        };
        
        print "Login failed\n";
        return undef;

}
