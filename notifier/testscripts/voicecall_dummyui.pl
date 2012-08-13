#!/usr/bin/perl

#for better programming
use strict;
use IO::Socket;
my $socket = new IO::Socket::INET (
    LocalHost => 'localhost',
    LocalPort => '12345',
    Proto => 'tcp',
    Listen => 1,
    Reuse => 1
);
my $txt;
die "Could not create socket: $!\n" unless $socket;
$|=1;

$socket->autoflush(1);
while (defined(my $conn = $socket->accept)) {

    $conn->autoflush(1);
    $conn->recv($txt,1024);
    #$txt = <$conn>;
    print "\n New call:  $txt" ;
    print "\n Action ? (A = acknowledge, I = Ignore, H=Hangup)";
    
    my $in  = <STDIN>;
    print $conn "$in";
    $conn->close();
}

$socket->close();