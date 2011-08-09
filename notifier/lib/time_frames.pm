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

# Use the supplied notification id to find the matching timeframe.
sub notificationInTimeFrame
{
        # arguements passed to function.
        my ($notification_id) = @_;

	# query
	my $query = 'SELECT notifications.timeframe_id FROM notifications WHERE notifications.id=\''.$notification_id.'\'';

        my %dbResult = queryDB($query);

	my $timeframe_id = $dbResult{0}->{timeframe_id};
	
	my $result = objectInTimeFrame($timeframe_id,'notifications');

	return $result;
}

# Use the supplied contact_id to find the matching timeframe.
sub contactInTimeFrame
{
        # arguements passed to function.
        my ($contact_id) = @_;

        # query
        my $query = 'SELECT contacts.timeframe_id FROM contacts WHERE contacts.id=\''.$contact_id.'\'';

        my %dbResult = queryDB($query);

        my $timeframe_id = $dbResult{0}->{timeframe_id};

        my $result = objectInTimeFrame($timeframe_id,'contacts');

        return $result;
}

# Use the supplied contactgroup_id to find the matching timeframe.
sub contactgroupInTimeFrame
{
        # arguements passed to function.
        my ($contactgroup_id) = @_;

        # query
        my $query = 'SELECT contactgroups.timeframe_id FROM contactgroups WHERE contactgroups.id=\''.$contactgroup_id.'\'';

        my %dbResult = queryDB($query);

        my $timeframe_id = $dbResult{0}->{timeframe_id};

        my $result = objectInTimeFrame($timeframe_id,'contactgroups');

        return $result;
}

# Get the timeframe_id,objectType and calculate if its inside or outside.
sub objectInTimeFrame
{
	# Get the timeframe_id from parent function.
        my ($timeframe_id,$objectType) = @_;

        # Create a bunch of variables to be filled.
        my (@today,$current_dow,$current_dow_en,$dt_validFrom,$dt_validTo,$dt_timeFrom,$dt_timeTo,$notify_status,@notify_date,$day_today_all,$day_today_1st,$day_today_2nd,$day_today_3rd,$day_today_4th,$day_today_5th,$day_today_last,$time_today_start,$time_today_stop,$time_today_invert,$tf_timezone);

        # Fill in the static info for days of week.
	#my $dt_Now = DateTime->now(timezone => $conf->{notifier}->{timezone});
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
	$day_today_all = 'day_'.$current_dow_en.'_all';
        $day_today_1st = 'day_'.$current_dow_en.'_1st';
        $day_today_2nd = 'day_'.$current_dow_en.'_2nd';
        $day_today_3rd = 'day_'.$current_dow_en.'_3rd';
        $day_today_4th = 'day_'.$current_dow_en.'_4th';
        $day_today_5th = 'day_'.$current_dow_en.'_5th';
        $day_today_last = 'day_'.$current_dow_en.'_last';

        # query
	my $query = 'SELECT timeframes.id, '.$objectType.'.timezone_id, timeframes.dt_validFrom, timeframes.dt_validTo, timezones.timezone, timeframes.day_'.$current_dow_en.'_all, timeframes.day_'.$current_dow_en.'_1st, timeframes.day_'.$current_dow_en.'_2nd, timeframes.day_'.$current_dow_en.'_3rd, timeframes.day_'.$current_dow_en.'_4th, timeframes.day_'.$current_dow_en.'_5th, timeframes.day_'.$current_dow_en.'_last, timeframes.time_'.$current_dow_en.'_start, timeframes.time_'.$current_dow_en.'_stop, timeframes.time_'.$current_dow_en.'_invert FROM timeframes, timezones, '.$objectType.' WHERE '.$objectType.'.timezone_id = timezones.id AND timeframes.id=\''.$timeframe_id.'\'';

        # Query DB, no need to log query.
        my %dbResult = queryDB($query);

	debug('dbResult: '.Dumper(\%dbResult), 2);

        # Get the results!
        $dt_validFrom = $dbResult{0}->{dt_validFrom};
        $dt_validTo = $dbResult{0}->{dt_validTo};
        $tf_timezone = $dbResult{0}->{timezone};
        $day_today_all = $dbResult{0}->{$day_today_all};
        $day_today_1st = $dbResult{0}->{$day_today_1st};
        $day_today_2nd = $dbResult{0}->{$day_today_2nd};
        $day_today_3rd = $dbResult{0}->{$day_today_3rd};
        $day_today_4th = $dbResult{0}->{$day_today_4th};
        $day_today_5th = $dbResult{0}->{$day_today_5th};
        $day_today_last = $dbResult{0}->{$day_today_last};
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
	$time_today_start = $dt->parse_datetime( $time_today_start );
	$time_today_stop = $dt->parse_datetime( $time_today_stop );

	# HOLIDAY FUNCTION HERE
	if(TimeFrameOnHoliday($timeframe_id, $tf_timezone) == '1'){
		debug (' Timeframe is on holiday... ',2);
		return 0;
	}

        # IF $now is after $validFrom and before $validTo
        if ($dt_validFrom lt $dt_Now and $dt_validTo gt $dt_Now)
        {
		debug(" Timeframe ".$timeframe_id." is valid, checking if any days match...", 3);

                # EXPAND $day_today to figure out what days of the month its active, see http://search.cpan.org/dist/Date-Calc/lib/Date/Calc.pod snippet 6
                if ($day_today_all eq 1){
			debug(" Timeframe ".$timeframe_id." is checked for " . $current_dow_en ." all days... Checking if its a valid timewindow", 2);
                        # Check if its inside or outside a valid timerange.
                        $notify_status = TimeFrameInTime($time_today_start,$time_today_stop, $time_today_invert, $dt_Now);
                                if ($notify_status eq 1){
		                        debug(" Timeframe ".$timeframe_id." is valid and will return true.", 2);
                                        return 1;
                                }
                                 
		} else {
                        if ($day_today_1st eq 1){
                                # Calculate 1st occurence of todays weekday of month.
                                debug(" Timeframe ".$timeframe_id." is checked for monthly " . $current_dow_en ." 1st occurence", 2);
                                @notify_date = TimeFrameDayNthWeekday(1);
                                if (@notify_date eq @today_short){
                                        # Check if its inside or outside a valid timerange.
                                        $notify_status = TimeFrameInTime($time_today_start,$time_today_stop, $time_today_invert, $dt_Now);
                                        if ($notify_status eq 1)
                                        {
                                                debug(" Timeframe ".$timeframe_id." is valid and will return true.", 2);
                                                return 1;
                                        }
                                }
                        }
                        if ($day_today_2nd eq 1){
                                # Calculate 2nd occurence of todays weekday of month.
                                debug(" Timeframe ".$timeframe_id." is checked for monthly " . $current_dow_en ." 2nd occurence", 2);
                                @notify_date = TimeFrameDayNthWeekday(2);
                                if (@notify_date eq @today_short){
                                        # Check if its inside or outside a valid timerange.
                                        $notify_status = TimeFrameInTime($time_today_start,$time_today_stop, $time_today_invert, $dt_Now);
                                        if ($notify_status eq 1)
                                        {
						debug(" Timeframe ".$timeframe_id." is valid and will return true.", 2);
                                                return 1;
                                        }
                                }
                        }
                        if ($day_today_3rd eq 1){
                                # Calculate 3rd occurence of todays weekday of month.
                                debug(" Timeframe ".$timeframe_id." is checked for monthly " . $current_dow_en ." 3rd occurence", 2);
                                @notify_date = TimeFrameDayNthWeekday(3);
                                if (@notify_date eq @today_short){
                                        # Check if its inside or outside a valid timerange.
                                        $notify_status = TimeFrameInTime($time_today_start,$time_today_stop, $time_today_invert, $dt_Now);
                                        if ($notify_status eq 1)
                                        {
                                                debug(" Timeframe ".$timeframe_id." is valid and will return true.", 2);
                                                return 1;
                                        }
                                }
                        }
                        if ($day_today_4th eq 1){
                                # Calculate 4th occurence of todays weekday of month.
                                debug(" Timeframe ".$timeframe_id." is checked for monthly " . $current_dow_en ." 4th occurence", 2);
                                @notify_date = TimeFrameDayNthWeekday(4);
                                if (@notify_date eq @today_short){
                                        # Check if its inside or outside a valid timerange.
                                        $notify_status = TimeFrameInTime($time_today_start,$time_today_stop, $time_today_invert, $dt_Now);
                                        if ($notify_status eq 1)
                                        {
                                                debug(" Timeframe ".$timeframe_id." is valid and will return true.", 2);
                                                return 1;
                                        }
                                }
                        }
                        if ($day_today_5th eq 1){
                                # Calculate 5th occurence of todays weekday of month.
                                debug(" Timeframe ".$timeframe_id." is checked for monthly " . $current_dow_en ." 5th occurence", 2);
                                @notify_date = TimeFrameDayNthWeekday(5);
                                if (@notify_date eq @today_short){
                                        # Check if its inside or outside a valid timerange.
                                        $notify_status = TimeFrameInTime($time_today_start,$time_today_stop, $time_today_invert, $dt_Now);
                                        if ($notify_status eq 1)
                                        {
                                                debug(" Timeframe ".$timeframe_id." is valid and will return true.", 2);
                                                return 1;
                                        }
                                }
                        }
                        # Last selected weekday of month.
                        if ($day_today_last eq 1){
                                # Calculate last occurence of todays weekday of month.
                                debug(" Timeframe ".$timeframe_id." is checked for monthly " . $current_dow_en ." last occurence", 2);
                                @notify_date = TimeFrameDayNthWeekday(6);
                                if (@notify_date eq @today_short){
                                        # Check if its inside or outside a valid timerange.
                                        $notify_status = TimeFrameInTime($time_today_start,$time_today_stop, $time_today_invert, $dt_Now);
                                        if ($notify_status eq 1)
                                        {
                                                debug(" Timeframe ".$timeframe_id." is valid and will return true.", 2);
                                                return 1;
                                        }
                                }
                        }
                        debug(" Timeframe ".$timeframe_id." didnt match any monthly occuring days, have you remembered to tick off a day of month?", 2);
			return 0;
                }
        }
        # ELSIF NOW IS LESS THAN $validFrom
        elsif ($dt_Now lt $dt_validFrom)
        {
                debug(" Timeframe ".$timeframe_id." has yet to be within timeframe", 2);
                return 0;
        }
        # ELSIF NOW IS GREATER THAN $validTo
        elsif ($dt_Now gt $dt_validTo)
        {
                debug(" Timeframe ".$timeframe_id." has expired", 2);
                return 0;
        }
        # ELSE
        else
        {
                debug(" This shouldnt happen, invalid data for the time in timeframe ".$timeframe_id, 2);
		return 0;
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
	debug("Day of month: ". \@nth_day . " for " . $input . " th/nd/rd/th/th weekday", 3);
        return @nth_day;
}

sub TimeFrameInTime
{
        # Input, time_from, time_to, time_inverted
        my ($time_from, $time_to, $time_inverted, $time_now) = @_;

        # If it is inverted, look outside the timerange rather than within.
        if ($time_inverted eq '1')
        {
                if ($time_from <= $time_now and $time_now <= $time_to){
                        # Outside range
			debug(" Inverted time is FALSE inside timewindow, this is FALSE and will not notify", 3);
                } else {
			debug(" Inverted time is TRUE outside timewindow, this is TRUE and will notify if the rest apply", 3);
                        return 1;
                }
        } else {
                if ($time_from <= $time_now and $time_now <= $time_to){
                        debug(" Time is inside specified timewindow, this is TRUE and will notify if the rest apply ", 3);
                        return 1;
                } else {
                        # Outside range.
			debug(" Time is outside specified timewindow, this is FALSE and will not notify ", 3);
                }
        }
        return 0; # Not in bounds of time.
}

sub TimeFrameOnHoliday
{
	my ($timeframe_id,$timezone) = @_;

	# Fetch the TimeFrame Holidays and return 0 if in office or 1 if on holiday.
	my $query = 'SELECT tf.timeframe_name, h.id, h.holiday_name, h.holiday_start, h.holiday_end
			FROM holidays h
			LEFT JOIN timeframes tf ON h.timeframe_id = tf.id
			WHERE tf.id =\''.$timeframe_id.'\'';

	my %dbResult = queryDB($query);

	foreach my $key (keys %dbResult){
		debug(' Checking to see if holiday #'.$key.' / '.$dbResult{$key}{holiday_name}.' is active',3);
		# Convert the datetime to unix epoch for easy comparison.

	        # set timezone
	        my $tz = DateTime::TimeZone->new( name => $timezone );
	        my $dt = DateTime->now()->set_time_zone($tz);

	        # check holiday data
	        if (datetime2InPeriod($dbResult{$key}{holiday_start},$dbResult{$key}{holiday_end}, $dt->ymd." ".$dt->hms))
       		{
                	debug( 'TimeFrame '.$dbResult{$key}{timeframe_name}.' with inherited TZ (GMT+'.$dt->offset($dt).'s) is on holiday leave: '.$dbResult{$key}{holiday_name}.', dropping', 2);
			return 1;

        	} else {
			debug( 'TimeFrame '.$dbResult{$key}{timeframe_name}.' with inherited TZ (GMT+'.$dt->offset($dt).'s) is not holiday leave: '.$dbResult{$key}{holiday_name}.', proceeding', 2);
		}

	}

	#debug( 'No registered holidays for TimeFrame: '.$dbResult{$key}{timeframe_name}, 2); # NOTHING TO PRINT BECAUSE ITS EMPTY IF NONE FOUND
	
	# Not on holiday
	return 0;

}

sub datetime2InPeriod
{

        my ($datetime_start,$datetime_end, $date) = @_;

        my $checktime = getUnixTime( $date );

        if ($checktime >= getUnixTime($datetime_start) and $checktime <= getUnixTime($datetime_end)){
        	return 1;
        }
        return 0;
}

1;
