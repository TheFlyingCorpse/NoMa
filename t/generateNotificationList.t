#!/usr/bin/perl

use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../notifier/lib";


# test the generateNotificationList() function
#
# it should supply an array of IDs that match the notification
#
# you can generate suitable test data with debug level 3

use contacts;



sub debug()
{
	my ($str, $val) = (@_);
	# print "$str\n";
}

sub notificationInTimeFrame
{
	return 1;
}


my @output;

my @testdata = (

    {
        'name'       => 'base test',
        'checktype'  => 's',
        'recipients' => '',
        'host'       => 'testhost',
        'svc'        => 'PING',
        'hgs'        => '',
        'sgs'        => '',
        'dbresult'   => {
            '0' => {
                'hosts_include'         => '*',
                'servicegroups_include' => '*',
                'services_exclude'      => '',
                'hostgroups_exclude'    => '',
                'servicegroups_exclude' => '',
                'recipients_include'    => '',
                'recipients_exclude'    => '',
                'id'                    => 1,
                'hostgroups_include'    => '*',
                'services_include'      => '*',
                'hosts_exclude'         => ''
            },
            '1' => {
                'hosts_include'         => '*',
                'servicegroups_include' => '*',
                'services_exclude'      => 'PING2',
                'hostgroups_exclude'    => '',
                'servicegroups_exclude' => '',
                'recipients_include'    => '',
                'recipients_exclude'    => '',
                'id'                    => 5,
                'hostgroups_include'    => '*',
                'services_include'      => '*',
                'hosts_exclude'         => ''
            }
        },
        'solloutput' => [ '1', '5' ]
    },
    {
        'dbresult' => {
            '0' => {
                'hosts_include'         => '',
                'servicegroups_include' => '',
                'services_exclude'      => '',
                'hostgroups_exclude'    => '',
                'servicegroups_exclude' => '',
                'recipients_include'    => '',
                'recipients_exclude'    => '',
                'id'                    => 2,
                'hostgroups_include'    => 'oracle',
                'services_include'      => 'swap',
                'hosts_exclude'         => ''
            },
            '1' => {
                'hosts_include'         => '',
                'servicegroups_include' => '',
                'services_exclude'      => '',
                'hostgroups_exclude'    => '',
                'servicegroups_exclude' => '',
                'recipients_include'    => '',
                'recipients_exclude'    => '',
                'id'                    => 3,
                'hostgroups_include'    => 'windows',
                'services_include'      => 'swap',
                'hosts_exclude'         => ''
            }
        },
        'name'       => 'limit hostgroups',
        'checktype'  => 's',
        'svc'        => 'swap',
        'checktype'  => 's',
        'sgs'        => '',
        'hgs'        => 'oracle,unix',
        'host'       => 'testhst',
        'recipients' => 'noma',
        'solloutput' => [ '2' ]
    },
    {
        'dbresult' => {
            '0' => {
                'hosts_include'         => '',
                'servicegroups_include' => 'mysql-svcs',
                'services_exclude'      => 'mysql query*',
                'hostgroups_exclude'    => '',
                'servicegroups_exclude' => '',
                'recipients_include'    => '',
                'recipients_exclude'    => '',
                'id'                    => 1,
                'hostgroups_include'    => 'mysql',
                'services_include'      => '',
                'hosts_exclude'         => ''
            }
        },
        'name'       => 'documentation example 1',
        'checktype'  => 's',
        'svc'        => 'MySQL Service',
        'checktype'  => 's',
        'sgs'        => 'mysql-svcs',
        'hgs'        => 'mysql,linux-servers',
        'host'       => 'mysql-lnxsrv01',
        'recipients' => 'noma',
        'solloutput' => [ '1' ]
	},
    {
        'dbresult' => {
            '0' => {
                'hosts_include'         => '',
                'servicegroups_include' => 'mysql-svcs',
                'services_exclude'      => 'mysql query*',
                'hostgroups_exclude'    => '',
                'servicegroups_exclude' => '',
                'recipients_include'    => '',
                'recipients_exclude'    => '',
                'id'                    => 1,
                'hostgroups_include'    => 'mysql',
                'services_include'      => '',
                'hosts_exclude'         => ''
            }
        },
        'name'       => 'documentation example 2',
        'svc'        => 'MySQL Query Cache Hitrate',
        'checktype'  => 's',
        'sgs'        => 'mysql-svcs',
        'hgs'        => 'mysql,linux-servers',
        'host'       => 'mysql-lnxsrv02',
        'recipients' => 'noma',
        'solloutput' => [ ]
	}
);

plan tests => ($#testdata + 1)*2;

foreach my $test (@testdata)
{
	my %dbresult = %{$test->{dbresult}};
	my @solloutput = @{$test->{solloutput}};
	@output = generateNotificationList($test->{checktype}, $test->{recipients}, $test->{host}, $test->{svc}, $test->{hgs}, $test->{sgs}, %dbresult);

	@output = sort @output;

	isa_ok(\@output, 'ARRAY', 'ids');
	is_deeply (\@output, \@solloutput, $test->{name}.' expected:'.join(',', @solloutput));
}
