#!/usr/bin/perl

my $behaviour = "ack";
my $wait = 3;
my %ERRORS=('OK'=>0,'WARNING'=>1,'CRITICAL'=>2,'UNKNOWN'=>3,'DEPENDENT'=>4);

use IO::Socket;
use Getopt::Long qw(:config bundling no_ignore_case);;
use Pod::Usage;

(my $scriptname = $0) =~ s#.*/##;
my $warning = 40;
my $critical = 20;
my $tout = 120;
my $number = undef;
my $verbose = undef;
my $asterisk = "localhost";
my $port = "5038";
my $starface = undef;

my $user = undef;
my $pass = undef;
my $context = undef;
my $exten = "s";
my $channel = undef;
my $call_timeout = 30;
my $suffix = "";
my $caller = undef;
my $contact = "Asterisk";
my $comment = "";
my $callid = int(rand(10**9));
my $msg = undef;
our $sock = undef;




# check the command line options
Getopt::Long::Configure('bundling');
GetOptions('help|?' => \$help,
           'V|version' => \$version,
           't|timeout=i' => \$tout,
           'n|number=s' => \$number,
           'v|verbose' => \$verbose,
           'starface' => \$starface,
           'context=s' => \$context,
           'user=s' => \$user,
           'pass=s' => \$pass,
           'p|port=s' => \$port,
           'asterisk=s' => \$asterisk,
           'h|host=s' => \$host,
           's|service=s' => \$service,
           'c|contact=s' => \$contact,
           'message=s' => \$msg,
           'comment=s' => \$comment,
           'C|channel=s' => \$channel,
           'caller=s' => \$caller,
           'suffix=s' => \$suffix,
           'callid=s' => \$callid,
           'calltimeout=i' => \$call_timeout,
           'e|exten=s' => \$exten,
           'w|warn|warning=i' => \$warning,
           # 'c|crit|critical=i' => \$critical); # c option removed for backwards compatibility
           'crit|critical=i' => \$critical);


$|=1;

my $socket = new IO::Socket::INET (
    PeerAddr => 'localhost',
    PeerPort => '12345',
    Type => SOCK_STREAM,
);

die "Unable to open connection: $!\n" unless defined $socket;
$socket->autoflush(1);
print $socket "=> Host: $host, Service: $service Message: $msg Comment: $comment Ext: $contact";

while($behaviour = <$socket>) {
    chomp($behaviour);
    if($behaviour eq "I") {
        nagexit('CRITICAL', "Timeout in notification script");
    } else {
        if ($behaviour eq "A") {
            nagexit('OK', "Call was acknowledged by end user");
        } else {
            nagexit ('WARNING', "Call successfully queued, but no acknowledgement received");
        }
    }
}


sub nagexit($$) {
        my $errlevel = shift;
        my $string = shift;

        print "$errlevel: $string\n";
        exit $ERRORS{$errlevel};
}
