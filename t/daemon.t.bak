#!/usr/bin/perl

use Test::More;
use FindBin qw($Bin);

my $output;

plan tests => 1;
$output = `$Bin/../notifier/noma_daemon.pl --version`;
like ($output, '/Version/', 'daemon is runnable');

