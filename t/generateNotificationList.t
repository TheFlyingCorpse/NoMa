#!/usr/bin/perl

use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../notifier/lib";


# test the generateNotificationList() function
#
# it should supply an array of IDs that match the notification

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
		checktype => 's',
		recipients => '',
		host => 'testhost',
		svc => 'PING',
		hg => '',
		sg => '',
		dbresult => {
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
                 },
          '1' => {
                   'hosts_include' => '*',
                   'servicegroups_include' => '*',
                   'services_exclude' => 'PING2',
                   'hostgroups_exclude' => '',
                   'servicegroups_exclude' => '',
                   'recipients_include' => '',
                   'recipients_exclude' => '',
                   'id' => 5,
                   'hostgroups_include' => '*',
                   'services_include' => '*',
                   'hosts_exclude' => ''
                 }
        },
		solloutput => [ '1', '5' ]
	}
);

plan tests => ($#testdata + 1)*2;

foreach my $test (@testdata)
{
	my %dbresult = %{$test->{dbresult}};
	my @solloutput = @{$test->{solloutput}};
	@output = generateNotificationList($test->{checktype}, $test->{recipients}, $test->{host}, $test->{svc}, $test->{hg}, $test->{sg}, %dbresult);

	isa_ok(\@output, 'ARRAY', 'ids');
	is_deeply (\@output, \@solloutput, 'IDs:'.join(',', @solloutput));
}
