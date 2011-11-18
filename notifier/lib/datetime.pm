#!/usr/bin/perl

# COPYRIGHT:
#
# This software is Copyright (c) 2007-2009 NETWAYS GmbH, Christian Doebler
#                 some parts (c) 2009      NETWAYS GmbH, William Preston
#                                <support@netways.de>
#
# (Except where explicitly superseded by other copyright notices)
#
#
# LICENSE:GPL2
# see noma_daemon.pl in parent directory for full details.
# Please do not distribute without the above file!

use POSIX;

sub getUnixTime
{

    my ($datetime) = @_;

    my ( $date, $time ) = split( ' ', $datetime );
    my ( $year, $mon, $day ) = split( '-', $date );
    my ( $hour, $min, $sec ) = split( ':', $time );

    return mktime( $sec, $min, $hour, $day, $mon - 1, $year - 1900 );

}

sub hmsToSecs
{
	my ($time) = @_;
	my @arr = split(":", $time);
	return (($arr[0]*3600)+($arr[1]*60)+($arr[2]));
}

# give this function a reference to
# an array of hashes
#
# e.g.
# {
#  'holiday_start' => '2008-12-20 00:00:00',
#  'holiday_end' => '2008-12-28 24:00:00',
# };
#
sub datetimeInPeriod
{

	my ($periods, $date) = @_;

	my $checktime = getUnixTime( $date );

	foreach my $period (@$periods)
	{
		if ($checktime >= getUnixTime($period->{'holiday_start'}) and 
			$checktime <= getUnixTime($period->{'holiday_end'}))
		{
			return 1;
		}
	}
	return 0;
}

# give this function a reference to
# an array of hashes
#
# e.g.
# {
#  'starttime' => '00:00:00',
#  'endtime' => '24:00:00',
#  'days' => '127'
# };
#
# N.B. dow is 0-6 (sun - sat),
#  and days is a binary map
sub timeInPeriod
{

	my ($periods, $dayofweek, $hms) = @_;

	if ($dayofweek == 7) { $dayofweek = 0; }

	foreach my $period (@$periods)
	{
		next if (!( $period->{'days'} & (2**($dayofweek)) ));

		my $checktime = hmsToSecs($hms);
		
		if ($checktime >= hmsToSecs($period->{'starttime'}) and 
			$checktime <= hmsToSecs($period->{'endtime'}))
		{
			return 1;
		}
	}
	return 0;
}

1;
