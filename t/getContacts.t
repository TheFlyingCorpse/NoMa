#!/usr/bin/perl

use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../notifier/lib";



use array_hash;
use debug;
use contacts;
use database;
use DBI;

my %confh = (
	'debug' => {
		'queries'	=> 0
		},
	'db'	=> {
		'type'		=> 'sqlite3',
		'sqlite3'	=> {
				'dbfile'	=> "$Bin/getContacts.db"
				}
	},
	'notifier' => {
		'locale' => 'en_GB',
		'pattern' => '%F %T',
		'timezone' => 'Europe/Berlin'
	}
);


our $conf = \%confh;


sub debug
{
	my ($str, $val) = (@_);
	# print "$str\n";
}


my @output;

my @testdata = (

    {
        'name'       => 'base test',
        'rule_array'  => [ '1' ],
        'notification_counter' => '1',
        'status'       => 'WARNING',
        'type'        => 'PROBLEM',
        'solloutput' => [ 
		{
          'ack_able' => 1,
          'timezone' => 'GMT',
          'rule' => 1,
          'mobile' => '',
          'phone' => '',
          'username' => 'nagiosadmin',
          'email' => 'nagios@localhost',
          'mid' => 3,
          'on_fail' => 0,
          'let_notifier_handle' => 0,
          'sender' => '',
          'growladdress' => '192.168.1.109',
          'method' => 'Voice',
          'notify_after_tries' => '1',
          'contact_field' => 'phone',
          'command' => 'voicecall'
		} ]
    },
    {
        'name'       => 'escalation 1',
        'rule_array'  => [ '1' ],
        'notification_counter' => '2',
        'status'       => 'WARNING',
        'type'        => 'PROBLEM',
        'solloutput' => [ 
		{
          'ack_able' => 0,
          'timezone' => 'GMT',
          'rule' => 1,
          'mobile' => '',
          'phone' => '',
          'username' => 'nagiosadmin',
          'email' => 'nagios@localhost',
          'mid' => 1,
          'on_fail' => 0,
          'let_notifier_handle' => 0,
          'sender' => 'root@localhost',
          'growladdress' => '192.168.1.109',
          'method' => 'E-Mail',
          'notify_after_tries' => '2',
          'contact_field' => 'email',
          'command' => 'sendemail'
		} ]
    },
    {
        'name'       => 'group test',
        'rule_array'  => [ '2' ],
        'notification_counter' => '1',
        'status'       => 'WARNING',
        'type'        => 'PROBLEM',
        'solloutput' => [ 
		{
          'ack_able' => 1,
          'timezone' => 'GMT',
          'rule' => 2,
          'mobile' => '',
          'phone' => '',
          'username' => 'nagiosadmin',
          'email' => 'nagios@localhost',
          'mid' => 3,
          'on_fail' => 0,
          'let_notifier_handle' => 0,
          'sender' => '',
          'growladdress' => '192.168.1.109',
          'method' => 'Voice',
          'notify_after_tries' => '1',
          'contact_field' => 'phone',
          'command' => 'voicecall'
		} ]
    },
    {
        'name'       => 'group escalation 1',
        'rule_array'  => [ '2' ],
        'notification_counter' => '2',
        'status'       => 'WARNING',
        'type'        => 'PROBLEM',
        'solloutput' => [ 
		{
          'ack_able' => 0,
          'timezone' => 'GMT',
          'rule' => 2,
          'mobile' => '',
          'phone' => '',
          'username' => 'nagiosadmin',
          'email' => 'nagios@localhost',
          'mid' => 1,
          'on_fail' => 0,
          'let_notifier_handle' => 0,
          'sender' => 'root@localhost',
          'growladdress' => '192.168.1.109',
          'method' => 'E-Mail',
          'notify_after_tries' => '2',
          'contact_field' => 'email',
          'command' => 'sendemail'
		} ]
    },
    {
        'name'       => 'counter exceeded',
        'rule_array'  => [ '1' ],
        'notification_counter' => '3',
        'status'       => 'WARNING',
        'type'        => 'PROBLEM',
        'solloutput' => [ ]
    },
    {
        'name'       => 'invalid rule',
        'rule_array'  => [ '3' ],
        'notification_counter' => '1',
        'status'       => 'WARNING',
        'type'        => 'PROBLEM',
        'solloutput' => [ ]
    }
);

plan tests => ($#testdata + 1)*2;

foreach my $test (@testdata)
{
	my %dbresult = %{$test->{dbresult}};
	my @solloutput = @{$test->{solloutput}};
	@output = getContacts($test->{rule_array}, $test->{notification_counter}, $test->{status}, $test->{type}, $test->{ext_id});

	# @output = sort @output;

	isa_ok(\@output, 'ARRAY', 'contacts');
	is_deeply (\@output, \@solloutput, $test->{name});
}
