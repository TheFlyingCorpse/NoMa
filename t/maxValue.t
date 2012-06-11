#!/usr/bin/perl

use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../notifier/lib";



use contacts;


sub debug
{
	my ($str, $val) = (@_);
	print "$str\n";
}


my @output;

my @testdata = (

    {
        'input'   => '1-4,7-8,12',
        'solloutput' => [ '12' ]
    },
    {
        'input'   => '1,2',
        'solloutput' => [ '2' ]
    }
);

plan tests => ($#testdata + 1);

foreach my $test (@testdata)
{
	my @solloutput = @{$test->{solloutput}};
	@output = getMaxValue($test->{input});

	# @output = sort @output;

	is_deeply (\@output, \@solloutput, 'For range '.$test->{input}.' expected:'.join(',', @solloutput));
}
