#!/usr/bin/perl

# COPYRIGHT:
#
# This software is Copyright (c) 2007-2009 NETWAYS GmbH, Christian Doebler
#                 some parts (c) 2009      NETWAYS GmbH, William Preston
#                                <support@netways.de>
#                 some parts (c) 2011                    Rune "TheFlyingCorpse" Darrud
#                                <theflyingcorpse@gmail.com>
#
# (Except where explicitly superseded by other copyright notices)
#
#
# LICENSE:GPL2
# see noma_daemon.pl in parent directory for full details.
# Please do not distribute without the above file!

use threads;
use Thread::Queue;
use FindBin;
use lib "$FindBin::Bin";
use database;
# use DBI;
use Data::Dumper;

use DateTime;
use DateTime::TimeZone;
# new requirement since 1.0.7!
use Date::Calc qw( Day_of_Week Delta_Days Date_to_Time
                   Nth_Weekday_of_Month_Year
                   Date_to_Text_Long English_Ordinal
                   Day_of_Week_to_Text Month_to_Text
                   Today Today_and_Now Add_Delta_Days);
use DateTime::Format::Strptime;

# return a true or false if within timerange of said notification rule if its in timerange etc...
sub notificationInTimeFrame
{
        # arguements passed to function.
        my ($notification_id) = @_;

        # Create a bunch of variables to be filled.
        my (@today,$current_dow,$current_dow_en,$dt_validFrom,$dt_validTo,$dt_timeFrom,$dt_timeTo,$notify_status,@notify_date,$day_today,$time_today_start,$time_today_stop,$time_today_invert,$tf_timezone);

        # Fill in the static info for days of week.
        my $dt_Now = DateTime->now();
        my $notify_day_all=64;
        my $notify_day_first=1;
        my $notify_day_second=2;
        my $notify_day_third=4;
        my $notify_day_fourth=8;
        my $notify_day_fifth=16;
        my $notify_day_last=32;

        # Get todays date and weekday name.
        my @today_short=Today();
        @today = Today();
        $current_dow = Day_of_Week(@today);
        $current_dow_en = lc(Day_of_Week_to_Text($current_dow));
        # Fill variables with todays english weekdayname.
        $time_today_start = 'time_' . $current_dow_en . '_start';
        $time_today_stop = 'time_' . $current_dow_en . '_stop';
        $time_today_invert = 'time_' . $current_dow_en . '_invert';
	$day_today = 'day_'.$current_dow_en;

        # query
        my $query = 'SELECT time_frames.id, time_frames_to_notifications.time_frame_id, time_frames_to_notifications.notification_id, timezones.id, time_frames.dt_validFrom, time_frames.dt_validTo, timezones.timezone, time_frames.day_'.$current_dow_en.', time_frames.time_'.$current_dow_en.'_start, time_frames.time_'.$current_dow_en.'_stop, time_frames.time_'.$current_dow_en.'_invert FROM time_frames,time_frames_to_notifications,timezones WHERE time_frames.timezone_id = timezones.id AND time_frames.id = time_frames_to_notifications.time_frame_id AND time_frames_to_notifications.notification_id=\''.$notification_id.'\'';

        # Query DB, no need to log query.
        my %dbResult = queryDB($query);

	debug('dbResult: '.Dumper(\%dbResult));

        # Get the results!
        $dt_validFrom = $dbResult{0}->{dt_validFrom};
        $dt_validTo = $dbResult{0}->{dt_validTo};
        $tf_timezone = $dbResult{0}->{timezone};
        $day_today = $dbResult{0}->{$day_today};
        $time_today_start = $dbResult{0}->{$time_today_start};
        $time_today_stop = $dbResult{0}->{$time_today_stop};
        $time_today_invert = $dbResult{0}->{$time_today_invert};

        # Convert to dt objects with proper timezone!
        my $dt = new DateTime::Format::Strptime(
                                                pattern     => $conf->{notifier}->{pattern}, #expected format of datetime, 'Y-M-D H:M:S', from MySQL.
                                                locale      => $conf->{notifier}->{locale}, #to get the valid days of week in english, like friday or sunday.
                                                time_zone   => $tf_timezone, #from database
                                                );

        # Fill in the missing information
        $time_today_start = $today[0].'-'.$today[1].'-'.$today[2].' '.$time_today_start;
        $time_today_stop = $today[0].'-'.$today[1].'-'.$today[2].' '.$time_today_stop;

        # Convert to a DateTime objects.
        $dt_validFrom = $dt->parse_datetime( $dt_validFrom );
        $dt_validTo = $dt->parse_datetime( $dt_validTo );
        $time_today_start = $dt->parse_datetime( $dt_timeFrom );
        $time_today_stop = $dt->parse_datetime( $dt_timeTo );

	print"PRE-1\n";

        # IF $now is after $validFrom and before $validTo
        if ($dt_validFrom lt $dt_Now and $dt_validTo gt $dt_Now)
        {
                # EXPAND $day_today to figure out what days of the month its active, see http://search.cpan.org/dist/Date-Calc/lib/Date/Calc.pod snippet 6
		print"PRE-2\n";
                if ($day_today & $notify_day_all){
			print"PRE-3\n";
                        # Check if its inside or outside a valid timerange.
                        $notify_status = TimeFrameInTime($time_today_start,$time_today_stop, $time_today_invert, $dt_Now);
                                if ($notify_status eq 1){
                                        return 1;
                                }
                                 
				} else {
                        if ($day_today & $notify_day_first){
                                # Calculate 1st occurence of todays weekday of month.
                                @notify_date = TimeFrameDayNthWeekday(1);
                                if (@notify_date eq @today_short){
                                        # Check if its inside or outside a valid timerange.
                                        $notify_status = TimeFrameInTime($time_today_start,$time_today_stop, $time_today_invert, $dt_Now);
                                        if ($notify_status eq 1)
                                        {
                                                return 1;
                                        }
                                }
                        }
                        if ($day_today & $notify_day_second){
                                # Calculate 2nd occurence of todays weekday of month.
                                @notify_date = TimeFrameDayNthWeekday(2);
                                if (@notify_date eq @today_short){
                                        # Check if its inside or outside a valid timerange.
                                        $notify_status = TimeFrameInTime($time_today_start,$time_today_stop, $time_today_invert, $dt_Now);
                                        if ($notify_status eq 1)
                                        {
                                                return 1;
                                        }
                                }
                        }
                        if ($day_today & $notify_day_third){
                                # Calculate 3rd occurence of todays weekday of month.
                                @notify_date = TimeFrameDayNthWeekday(3);
                                if (@notify_date eq @today_short){
                                        # Check if its inside or outside a valid timerange.
                                        $notify_status = TimeFrameInTime($time_today_start,$time_today_stop, $time_today_invert, $dt_Now);
                                        if ($notify_status eq 1)
                                        {
                                                return 1;
                                        }
                                }
                        }
                        if ($day_today & $notify_day_fourth){
                                # Calculate 4th occurence of todays weekday of month.
                                @notify_date = TimeFrameDayNthWeekday(4);
                                if (@notify_date eq @today_short){
                                        # Check if its inside or outside a valid timerange.
                                        $notify_status = TimeFrameInTime($time_today_start,$time_today_stop, $time_today_invert, $dt_Now);
                                        if ($notify_status eq 1)
                                        {
                                                return 1;
                                        }
                                }
                        }
                        if ($day_today & $notify_day_fifth){
                                # Calculate 5th occurence of todays weekday of month.
                                @notify_date = TimeFrameDayNthWeekday(5);
                                if (@notify_date eq @today_short){
                                        # Check if its inside or outside a valid timerange.
                                        $notify_status = TimeFrameInTime($time_today_start,$time_today_stop, $time_today_invert, $dt_Now);
                                        if ($notify_status eq 1)
                                        {
                                                return 1;
                                        }
                                }
                        }
                        # Last selected weekday of month.
                        if ($day_today & $notify_day_last){
			print"PRE-32\n";
                                # Calculate last occurence of todays weekday of month.
                                @notify_date = TimeFrameDayNthWeekday(6);
                                if (@notify_date eq @today_short){
				print"PRE-32-today\n";
                                        # Check if its inside or outside a valid timerange.
                                        $notify_status = TimeFrameInTime($time_today_start,$time_today_stop, $time_today_invert, $dt_Now);
                                        if ($notify_status eq 1)
                                        {
						print"PRE-32-today-VALID\n";
                                                return 1;
                                        }
                                }
                        }
                }
        }
        # ELSIF NOW IS LESS THAN $validFrom
        elsif ($dt_Now lt $dt_validFrom)
        {
                debug(" Notify ID $notification_id time_frame has yet to be within timeframe");
                return 0;
        }
        # ELSIF NOW IS GREATER THAN $validTo
        elsif ($dt_Now gt $dt_validTo)
        {
                debug(" Notify ID $notification_id time_frame has expired");
                return 0;
        }
        # ELSE
        else
        {
                debug(" This shouldnt happen, invalid data for the time in Notify ID $notification_id");
        }

}

sub TimeFrameDayNthWeekday
{
        # Input, the Nth weekday.
        my ($input) = @_;

        my @today = Today_and_Now(); # Expecting Y M D H M S
        my $current_dow = Day_of_Week($today[0],$today[1],$today[2]); # Y M D
        my @nth_day;

        # Calculate LAST Nth weekday of the month.
        if ($input eq '6'){
                @nth_day = Nth_Weekday_of_Month_Year($today[0],$today[1],$current_dow,5);
                if (scalar(@nth_day)) {
                        #5 of given weekday this month.(if a value, then 5th weekday exists)
                } else {
                        # Only 4 of given weekdays this month.
                        @nth_day = Nth_Weekday_of_Month_Year($today[0],$today[1],$current_dow,4);  # try
                }
                # Give back the last Nth date of todays weekday, ie 5th Friday of July 2011; '2011 7 30'.
        } else {
                @nth_day = Nth_Weekday_of_Month_Year($today[0],$today[1],$current_dow,$input);
        }
        return @nth_day;
}

sub TimeFrameInTime
{
        # Input, time_from, time_to, time_inverted
        my ($time_from, $time_to, $time_inverted, $time_now) = @_;
	debug('TimeFrameInTime input, time_from: '.$time_from.' time_to: '.$time_to.' time_inverted '.$time_inverted.' time now: '.$time_now);
        # If it is inverted, look outside the timerange rather than within.
        if ($time_inverted eq '1')
        {
                if ($time_from >= $time_now and $time_now >= $time_to){
                        return 1;
                } else {
                        # Inside range.
                }
        } else {
                if ($time_from <= $time_now and $time_now <= $time_to){
                        return 1;
                } else {
                        # Outside range.
                }
        }
        return 0; # Not in bounds of time.
}


1;
