#!/usr/bin/perl

use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../notifier/lib";
use contacts;



sub debug()
{
	my ($str, $val) = (@_);
	print "$str\n";
}



my $output;


my %testinput = {
          '0' => {
                   'hosts_include' => '*',
                   'servicegroups_include' => '*',
                   'services_exclude' => '',
                   'hostgroups_exclude' => '',
                   'servicegroups_exclude' => '',
                   'recipients_include' => '',
                   'recipients_exclude' => '',
                   'id' => 1,
                   'hostgroups_include' => '*',
                   'services_include' => '*',
                   'hosts_exclude' => ''
                 }
        };

plan tests => 1;
$output = generateNotificationList('NOTIFICATION', 'test', '', '', '', '', %testinput);
like ($output, '/Version/', 'generateNotificationList');

