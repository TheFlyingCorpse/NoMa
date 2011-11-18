#!/usr/bin/perl

use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../notifier/lib";



use escalations;
use database;
use DBI;

my %confh = (
	'debug' => {
		'queries'	=> 0
		},
	'db'	=> {
		'type'		=> 'sqlite3',
		'sqlite3'	=> {
				'dbfile'	=> "$Bin/getNextMethod.db"
				}
	}
);

our $conf = \%confh;

sub debug
{
	my ($str, $val) = (@_);
	print "$str\n";
}


my @output;

my @testdata = (

    {
        'id'   => '2',
        'solloutput' => [ '0', '/bin/true' ]
    },
    {
        'id'   => '1',
        'solloutput' => [ '0', '/bin/true' ]
    }
);

plan tests => ($#testdata + 1)*2;

foreach my $test (@testdata)
{
	my @solloutput = @{$test->{solloutput}};
	@output = getNextMethod($test->{id});

	# @output = sort @output;

	isa_ok(\@output, 'ARRAY', 'ids');
	is_deeply (\@output, \@solloutput, $test->{name}.' expected:'.join(',', @solloutput));
}
