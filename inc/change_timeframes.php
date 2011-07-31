<?php

# COPYRIGHT:
#  
# This software is Copyright (c) 2007-2008 NETWAYS GmbH, Christian Doebler 
#                                <support@netways.de>
# 
# (Except where explicitly superseded by other copyright notices)
# 
# 
# LICENSE:
# 
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from http://www.fsf.org.
# 
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 or visit their web page on the internet at
# http://www.fsf.org.
# 
# 
# CONTRIBUTION SUBMISSION POLICY:
# 
# (The following paragraph is not intended to limit the rights granted
# to you to modify and distribute this software under the terms of
# the GNU General Public License and is only of importance to you if
# you choose to contribute your changes and enhancements to the
# community by submitting them to NETWAYS GmbH.)
# 
# By intentionally submitting any modifications, corrections or
# derivatives to this work, or any other work intended for use with
# this Software, to NETWAYS GmbH, you confirm that
# you are the copyright holder for those contributions and you grant
# NETWAYS GmbH a nonexclusive, worldwide, irrevocable,
# royalty-free, perpetual, license to use, copy, create derivative
# works based on those contributions, and sublicense and distribute
# those contributions and any derivatives thereof.
#
# Nagios and the Nagios logo are registered trademarks of Ethan Galstad.


/**
 * addTimeframe - adds a new timeframe
 *
 * @param		array		$p		posted data for new contact
 * @return		string				message
 */
function addTimeframe ($p) {

	global $authentication_type;

	// security check
	if (!checkTimeframesMod()) return TIMEFRAME_ADD_UPDATE_ERROR_INSUFF_RIGHTS;

	// prepare data
	$timeframe_name = prepareDBValue($p['timeframe_name']);
        $time_monday_invert = (($p['day_monday_time_invert'][0] == 'on') ? '1' : '0');
        $time_tuesday_invert = (($p['day_tuesday_time_invert'][0] == 'on') ? '1' : '0');
        $time_wednesday_invert = (($p['day_wednesday_time_invert'][0] == 'on') ? '1' : '0');
        $time_thursday_invert = (($p['day_thursday_time_invert'][0] == 'on') ? '1' : '0');
        $time_friday_invert = (($p['day_friday_time_invert'][0] == 'on') ? '1' : '0');
        $time_saturday_invert = (($p['day_saturday_time_invert'][0] == 'on') ? '1' : '0');
        $time_sunday_invert = (($p['day_sunday_time_invert'][0] == 'on') ? '1' : '0');
        $day_monday_all = (($p['day_monday_all'][0] == 'on') ? '1' : '0');
        $day_monday_1st = (($p['day_monday_1st'][0] == 'on') ? '1' : '0');
        $day_monday_2nd = (($p['day_monday_2nd'][0] == 'on') ? '1' : '0');
        $day_monday_3rd = (($p['day_monday_3rd'][0] == 'on') ? '1' : '0');
        $day_monday_4th = (($p['day_monday_4th'][0] == 'on') ? '1' : '0');
        $day_monday_5th = (($p['day_monday_5th'][0] == 'on') ? '1' : '0');
        $day_monday_last = (($p['day_monday_last'][0] == 'on') ? '1' : '0');
        $day_tuesday_all = (($p['day_tuesday_all'][0] == 'on') ? '1' : '0');
        $day_tuesday_1st = (($p['day_tuesday_1st'][0] == 'on') ? '1' : '0');
        $day_tuesday_2nd = (($p['day_tuesday_2nd'][0] == 'on') ? '1' : '0');
        $day_tuesday_3rd = (($p['day_tuesday_3rd'][0] == 'on') ? '1' : '0');
        $day_tuesday_4th = (($p['day_tuesday_4th'][0] == 'on') ? '1' : '0');
        $day_tuesday_5th = (($p['day_tuesday_5th'][0] == 'on') ? '1' : '0');
        $day_tuesday_last = (($p['day_tuesday_last'][0] == 'on') ? '1' : '0');
        $day_wednesday_all = (($p['day_wednesday_all'][0] == 'on') ? '1' : '0');
        $day_wednesday_1st = (($p['day_wednesday_1st'][0] == 'on') ? '1' : '0');
        $day_wednesday_2nd = (($p['day_wednesday_2nd'][0] == 'on') ? '1' : '0');
        $day_wednesday_3rd = (($p['day_wednesday_3rd'][0] == 'on') ? '1' : '0');
        $day_wednesday_4th = (($p['day_wednesday_4th'][0] == 'on') ? '1' : '0');
        $day_wednesday_5th = (($p['day_wednesday_5th'][0] == 'on') ? '1' : '0');
        $day_wednesday_last = (($p['day_wednesday_last'][0] == 'on') ? '1' : '0');
        $day_thursday_all = (($p['day_thursday_all'][0] == 'on') ? '1' : '0');
        $day_thursday_1st = (($p['day_thursday_1st'][0] == 'on') ? '1' : '0');
        $day_thursday_2nd = (($p['day_thursday_2nd'][0] == 'on') ? '1' : '0');
        $day_thursday_3rd = (($p['day_thursday_3rd'][0] == 'on') ? '1' : '0');
        $day_thursday_4th = (($p['day_thursday_4th'][0] == 'on') ? '1' : '0');
        $day_thursday_5th = (($p['day_thursday_5th'][0] == 'on') ? '1' : '0');
        $day_thursday_last = (($p['day_thursday_last'][0] == 'on') ? '1' : '0');
        $day_friday_all = (($p['day_friday_all'][0] == 'on') ? '1' : '0');
        $day_friday_1st = (($p['day_friday_1st'][0] == 'on') ? '1' : '0');
        $day_friday_2nd = (($p['day_friday_2nd'][0] == 'on') ? '1' : '0');
        $day_friday_3rd = (($p['day_friday_3rd'][0] == 'on') ? '1' : '0');
        $day_friday_4th = (($p['day_friday_4th'][0] == 'on') ? '1' : '0');
        $day_friday_5th = (($p['day_friday_5th'][0] == 'on') ? '1' : '0');
        $day_friday_last = (($p['day_friday_last'][0] == 'on') ? '1' : '0');
        $day_saturday_all = (($p['day_saturday_all'][0] == 'on') ? '1' : '0');
        $day_saturday_1st = (($p['day_saturday_1st'][0] == 'on') ? '1' : '0');
        $day_saturday_2nd = (($p['day_saturday_2nd'][0] == 'on') ? '1' : '0');
        $day_saturday_3rd = (($p['day_saturday_3rd'][0] == 'on') ? '1' : '0');
        $day_saturday_4th = (($p['day_saturday_4th'][0] == 'on') ? '1' : '0');
        $day_saturday_5th = (($p['day_saturday_5th'][0] == 'on') ? '1' : '0');
        $day_saturday_last = (($p['day_saturday_last'][0] == 'on') ? '1' : '0');
        $day_sunday_all = (($p['day_sunday_all'][0] == 'on') ? '1' : '0');
        $day_sunday_1st = (($p['day_sunday_1st'][0] == 'on') ? '1' : '0');
        $day_sunday_2nd = (($p['day_sunday_2nd'][0] == 'on') ? '1' : '0');
        $day_sunday_3rd = (($p['day_sunday_3rd'][0] == 'on') ? '1' : '0');
        $day_sunday_4th = (($p['day_sunday_4th'][0] == 'on') ? '1' : '0');
        $day_sunday_5th = (($p['day_sunday_5th'][0] == 'on') ? '1' : '0');
        $day_sunday_last = (($p['day_sunday_last'][0] == 'on') ? '1' : '0');
	$timezone_id = prepareDBValue($p['timezone_id']);

	// check whether timeframe already exists
	$query = sprintf(
		'select id from timeframes where timeframe_name=\'%s\' and time_monday_invert=\'%s\' and time_tuesday_invert=\'%s\' and time_wednesday_invert=\'%s\' and time_thursday_invert=\'%s\' and time_friday_invert=\'%s\' and time_saturday_invert=\'%s\' and time_sunday_invert=\'%s\' and day_monday_1st=\'%s\' and day_monday_2nd=\'%s\' and day_monday_3rd=\'%s\' and day_monday_4th=\'%s\' and day_monday_5th=\'%s\' and day_monday_last=\'%s\' and day_tuesday_1st=\'%s\' and day_tuesday_2nd=\'%s\' and day_tuesday_3rd=\'%s\' and day_tuesday_4th=\'%s\' and day_tuesday_5th=\'%s\' and day_tuesday_last=\'%s\' and day_wednesday_1st=\'%s\' and day_wednesday_2nd=\'%s\' and day_wednesday_3rd=\'%s\' and day_wednesday_4th=\'%s\' and day_wednesday_5th=\'%s\' and day_wednesday_last=\'%s\' and day_thursday_1st=\'%s\' and day_thursday_2nd=\'%s\' and day_thursday_3rd=\'%s\' and day_thursday_4th=\'%s\' and day_thursday_5th=\'%s\' and day_thursday_last=\'%s\' and day_friday_1st=\'%s\' and day_friday_2nd=\'%s\' and day_friday_3rd=\'%s\' and day_friday_4th=\'%s\' and day_friday_5th=\'%s\' and day_friday_last=\'%s\' and day_saturday_1st=\'%s\' and day_saturday_2nd=\'%s\' and day_saturday_3rd=\'%s\' and day_saturday_4th=\'%s\' and day_saturday_5th=\'%s\' and day_saturday_last=\'%s\' and day_sunday_all=\'%s\' and day_sunday_1st=\'%s\' and day_sunday_2nd=\'%s\' and day_sunday_3rd=\'%s\' and day_sunday_4th=\'%s\' and day_sunday_5th=\'%s\' and day_sunday_last=\'%s\' and timezone_id=\'%s\'',
                $timeframe_name,
                $time_monday_invert,
                $time_tuesday_invert,
                $time_wednesday_invert,
                $time_thursday_invert,
                $time_friday_invert,
                $time_saturday_invert,
                $time_sunday_invert,
		$day_monday_all,
		$day_monday_1st,
		$day_monday_2nd,
		$day_monday_3rd,
		$day_monday_4th,
		$day_monday_5th,
		$day_monday_last,
		$day_tuesday_all,
		$day_tuesday_1st,
		$day_tuesday_2nd,
		$day_tuesday_3rd,
		$day_tuesday_4th,
		$day_tuesday_5th,
		$day_tuesday_last,
		$day_wednesday_all,
		$day_wednesday_1st,
		$day_wednesday_2nd,
		$day_wednesday_3rd,
		$day_wednesday_4th,
		$day_wednesday_5th,
		$day_wednesday_last,
		$day_thursday_all,
		$day_thursday_1st,
		$day_thursday_2nd,
		$day_thursday_3rd,
		$day_thursday_4th,
		$day_thursday_5th,
		$day_thursday_last,
		$day_friday_all,
		$day_friday_1st,
		$day_friday_2nd,
		$day_friday_3rd,
		$day_friday_4th,
		$day_friday_5th,
		$day_friday_last,
		$day_saturday_all,
		$day_saturday_1st,
		$day_saturday_2nd,
		$day_saturday_3rd,
		$day_saturday_4th,
		$day_saturday_5th,
		$day_saturday_last,
		$day_sunday_all,
                $day_sunday_1st,
                $day_sunday_2nd,
                $day_sunday_3rd,
                $day_sunday_4th,
                $day_sunday_5th,
                $day_sunday_last,
		$timezone_id
	);
	$dbResult = queryDB($query);
	if (!empty($dbResult[0]['id'])) return TIMEFRAME_ADD_USER_EXISTS;


	// add timeframe
	$query = sprintf(
		'insert into timeframes (timeframe_name,time_monday_invert,time_tuesday_invert,time_wednesday_invert,time_thursday_invert,time_friday_invert,time_saturday_invert,time_sunday_invert,day_monday_all,day_monday_1st,day_monday_2nd,day_monday_3rd,day_monday_4th,day_monday_5th,day_monday_last,day_tuesday_all,day_tuesday_1st,day_tuesday_2nd,day_tuesday_3rd,day_tuesday_4th,day_tuesday_5th,day_tuesday_last,day_wednesday_all,day_wednesday_1st,day_wednesday_2nd,day_wednesday_3rd,day_wednesday_4th,day_wednesday_5th,day_wednesday_last,day_thursday_all,day_thursday_1st,day_thursday_2nd,day_thursday_3rd,day_thursday_4th,day_thursday_5th,day_thursday_last,day_friday_all,day_friday_1st,day_friday_2nd,day_friday_3rd,day_friday_4th,day_friday_5th,day_friday_last,day_saturday_all,day_saturday_1st,day_saturday_2nd,day_saturday_3rd,day_saturday_4th,day_saturday_5th,day_saturday_last,day_sunday_all,day_sunday_1st,day_sunday_2nd,day_sunday_3rd,day_sunday_4th,day_sunday_5th,day_sunday_last,timezone_id)
			values (\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\'',
                $timeframe_name,
                $time_monday_invert,
                $time_tuesday_invert,
                $time_wednesday_invert,
                $time_thursday_invert,
                $time_friday_invert,
                $time_saturday_invert,
                $time_sunday_invert,
                $day_monday_all,
                $day_monday_1st,
                $day_monday_2nd,
                $day_monday_3rd,
                $day_monday_4th,
                $day_monday_5th,
                $day_monday_last,
                $day_tuesday_all,
                $day_tuesday_1st,
                $day_tuesday_2nd,
                $day_tuesday_3rd,
                $day_tuesday_4th,
                $day_tuesday_5th,
                $day_tuesday_last,
                $day_wednesday_all,
                $day_wednesday_1st,
                $day_wednesday_2nd,
                $day_wednesday_3rd,
                $day_wednesday_4th,
                $day_wednesday_5th,
                $day_wednesday_last,
                $day_thursday_all,
                $day_thursday_1st,
                $day_thursday_2nd,
                $day_thursday_3rd,
                $day_thursday_4th,
                $day_thursday_5th,
                $day_thursday_last,
                $day_friday_all,
                $day_friday_1st,
                $day_friday_2nd,
                $day_friday_3rd,
                $day_friday_4th,
                $day_friday_5th,
                $day_friday_last,
                $day_saturday_all,
                $day_saturday_1st,
                $day_saturday_2nd,
                $day_saturday_3rd,
                $day_saturday_4th,
                $day_saturday_5th,
                $day_saturday_last,
                $day_sunday_all,
                $day_sunday_1st,
                $day_sunday_2nd,
                $day_sunday_3rd,
                $day_sunday_4th,
                $day_sunday_5th,
                $day_sunday_last,
                $timezone_id
	);
	queryDB($query);


	// get timframe's ID
	$query = sprintf(
                'select id from timeframes where timeframe_name=\'%s\' and time_monday_invert=\'%s\' and time_tuesday_invert=\'%s\' and time_wednesday_invert=\'%s\' and time_thursday_invert=\'%s\' and time_friday_invert=\'%s\' and time_saturday_invert=\'%s\' and time_sunday_invert=\'%s\' and day_monday_1st=\'%s\' and day_monday_2nd=\'%s\' and day_monday_3rd=\'%s\' and day_monday_4th=\'%s\' and day_monday_5th=\'%s\' and day_monday_last=\'%s\' and day_tuesday_1st=\'%s\' and day_tuesday_2nd=\'%s\' and day_tuesday_3rd=\'%s\' and day_tuesday_4th=\'%s\' and day_tuesday_5th=\'%s\' and day_tuesday_last=\'%s\' and day_wednesday_1st=\'%s\' and day_wednesday_2nd=\'%s\' and day_wednesday_3rd=\'%s\' and day_wednesday_4th=\'%s\' and day_wednesday_5th=\'%s\' and day_wednesday_last=\'%s\' and day_thursday_1st=\'%s\' and day_thursday_2nd=\'%s\' and day_thursday_3rd=\'%s\' and day_thursday_4th=\'%s\' and day_thursday_5th=\'%s\' and day_thursday_last=\'%s\' and day_friday_1st=\'%s\' and day_friday_2nd=\'%s\' and day_friday_3rd=\'%s\' and day_friday_4th=\'%s\' and day_friday_5th=\'%s\' and day_friday_last=\'%s\' and day_saturday_1st=\'%s\' and day_saturday_2nd=\'%s\' and day_saturday_3rd=\'%s\' and day_saturday_4th=\'%s\' and day_saturday_5th=\'%s\' and day_saturday_last=\'%s\' and day_sunday_all=\'%s\' and day_sunday_1st=\'%s\' and day_sunday_2nd=\'%s\' and day_sundaY_3rd=\'%s\' and day_sunday_4th=\'%s\' and day_sunday_5th=\'%s\' and day_sunday_last=\'%s\' and timezone_id=\'%s\'',
                $timeframe_name,
                $time_monday_invert,
                $time_tuesday_invert,
                $time_wednesday_invert,
                $time_thursday_invert,
                $time_friday_invert,
                $time_saturday_invert,
                $time_sunday_invert,
		$day_monday_all,
		$day_monday_1st,
		$day_monday_2nd,
		$day_monday_3rd,
		$day_monday_4th,
		$day_monday_5th,
		$day_monday_last,
		$day_tuesday_all,
		$day_tuesday_1st,
		$day_tuesday_2nd,
		$day_tuesday_3rd,
		$day_tuesday_4th,
		$day_tuesday_5th,
		$day_tuesday_last,
		$day_wednesday_all,
		$day_wednesday_1st,
		$day_wednesday_2nd,
		$day_wednesday_3rd,
		$day_wednesday_4th,
		$day_wednesday_5th,
		$day_wednesday_last,
		$day_thursday_all,
		$day_thursday_1st,
		$day_thursday_2nd,
		$day_thursday_3rd,
		$day_thursday_4th,
		$day_thursday_5th,
		$day_thursday_last,
		$day_friday_all,
		$day_friday_1st,
		$day_friday_2nd,
		$day_friday_3rd,
		$day_friday_4th,
		$day_friday_5th,
		$day_friday_last,
		$day_saturday_all,
		$day_saturday_1st,
		$day_saturday_2nd,
		$day_saturday_3rd,
		$day_saturday_4th,
		$day_saturday_5th,
		$day_saturday_last,
                $day_sunday_all,
                $day_sunday_1st,
                $day_sunday_2nd,
                $day_sunday_3rd,
                $day_sunday_4th,
                $day_sunday_5th,
                $day_sunday_last,
                $timezone_id
	);
	$dbResult = queryDB($query);
	if (!empty($dbResult[0]['id'])) return TIMEFRAME_ADD_ADDED_BUT_NOT_IN_DB;



	// add holidays
	//if (!empty($p['holiday_start']) && !empty($p['holiday_end'])) {
	//	addHolidays($dbResult[0]['id'], $p['holiday_start'], $p['holiday_end']);
	//}


	return TIMEFRAME_ADDED;

}




/**
 * updateTimeframe - updates an existing timeframe
 *
 * @param		array		$p		posted data for contact update
 * @return		string				message
 */
function updateTimeframe ($p) {

	global $authentication_type;

	// prepare data
	$id = prepareDBValue($p['id']);
	if (!$id) return TIMEFRAME_ADD_UPDATE_ERROR_INSUFF_RIGHTS;

	// security check
	if (!checkTimeframesMod($p['id'])) return TIMEFRAME_ADD_UPDATE_ERROR_INSUFF_RIGHTS;

	// prepare data
        $timeframe_name = prepareDBValue($p['timeframe_name']);
        $time_monday_invert = (($p['day_monday_time_invert'][0] == 'on') ? '1' : '0');
        $time_tuesday_invert = (($p['day_tuesday_time_invert'][0] == 'on') ? '1' : '0');
        $time_wednesday_invert = (($p['day_wednesday_time_invert'][0] == 'on') ? '1' : '0');
        $time_thursday_invert = (($p['day_thursday_time_invert'][0] == 'on') ? '1' : '0');
        $time_friday_invert = (($p['day_friday_time_invert'][0] == 'on') ? '1' : '0');
        $time_saturday_invert = (($p['day_saturday_time_invert'][0] == 'on') ? '1' : '0');
        $time_sunday_invert = (($p['day_sunday_time_invert'][0] == 'on') ? '1' : '0');
        $day_monday_all = (($p['day_monday_all'][0] == 'on') ? '1' : '0');
        $day_monday_1st = (($p['day_monday_1st'][0] == 'on') ? '1' : '0');
        $day_monday_2nd = (($p['day_monday_2nd'][0] == 'on') ? '1' : '0');
        $day_monday_3rd = (($p['day_monday_3rd'][0] == 'on') ? '1' : '0');
        $day_monday_4th = (($p['day_monday_4th'][0] == 'on') ? '1' : '0');
        $day_monday_5th = (($p['day_monday_5th'][0] == 'on') ? '1' : '0');
        $day_monday_last = (($p['day_monday_last'][0] == 'on') ? '1' : '0');
        $day_tuesday_all = (($p['day_tuesday_all'][0] == 'on') ? '1' : '0');
        $day_tuesday_1st = (($p['day_tuesday_1st'][0] == 'on') ? '1' : '0');
        $day_tuesday_2nd = (($p['day_tuesday_2nd'][0] == 'on') ? '1' : '0');
        $day_tuesday_3rd = (($p['day_tuesday_3rd'][0] == 'on') ? '1' : '0');
        $day_tuesday_4th = (($p['day_tuesday_4th'][0] == 'on') ? '1' : '0');
        $day_tuesday_5th = (($p['day_tuesday_5th'][0] == 'on') ? '1' : '0');
        $day_tuesday_last = (($p['day_tuesday_last'][0] == 'on') ? '1' : '0');
        $day_wednesday_all = (($p['day_wednesday_all'][0] == 'on') ? '1' : '0');
        $day_wednesday_1st = (($p['day_wednesday_1st'][0] == 'on') ? '1' : '0');
        $day_wednesday_2nd = (($p['day_wednesday_2nd'][0] == 'on') ? '1' : '0');
        $day_wednesday_3rd = (($p['day_wednesday_3rd'][0] == 'on') ? '1' : '0');
        $day_wednesday_4th = (($p['day_wednesday_4th'][0] == 'on') ? '1' : '0');
        $day_wednesday_5th = (($p['day_wednesday_5th'][0] == 'on') ? '1' : '0');
        $day_wednesday_last = (($p['day_wednesday_last'][0] == 'on') ? '1' : '0');
        $day_thursday_all = (($p['day_thursday_all'][0] == 'on') ? '1' : '0');
        $day_thursday_1st = (($p['day_thursday_1st'][0] == 'on') ? '1' : '0');
        $day_thursday_2nd = (($p['day_thursday_2nd'][0] == 'on') ? '1' : '0');
        $day_thursday_3rd = (($p['day_thursday_3rd'][0] == 'on') ? '1' : '0');
        $day_thursday_4th = (($p['day_thursday_4th'][0] == 'on') ? '1' : '0');
        $day_thursday_5th = (($p['day_thursday_5th'][0] == 'on') ? '1' : '0');
        $day_thursday_last = (($p['day_thursday_last'][0] == 'on') ? '1' : '0');
        $day_friday_all = (($p['day_friday_all'][0] == 'on') ? '1' : '0');
        $day_friday_1st = (($p['day_friday_1st'][0] == 'on') ? '1' : '0');
        $day_friday_2nd = (($p['day_friday_2nd'][0] == 'on') ? '1' : '0');
        $day_friday_3rd = (($p['day_friday_3rd'][0] == 'on') ? '1' : '0');
        $day_friday_4th = (($p['day_friday_4th'][0] == 'on') ? '1' : '0');
        $day_friday_5th = (($p['day_friday_5th'][0] == 'on') ? '1' : '0');
        $day_friday_last = (($p['day_friday_last'][0] == 'on') ? '1' : '0');
        $day_saturday_all = (($p['day_saturday_all'][0] == 'on') ? '1' : '0');
        $day_saturday_1st = (($p['day_saturday_1st'][0] == 'on') ? '1' : '0');
        $day_saturday_2nd = (($p['day_saturday_2nd'][0] == 'on') ? '1' : '0');
        $day_saturday_3rd = (($p['day_saturday_3rd'][0] == 'on') ? '1' : '0');
        $day_saturday_4th = (($p['day_saturday_4th'][0] == 'on') ? '1' : '0');
        $day_saturday_5th = (($p['day_saturday_5th'][0] == 'on') ? '1' : '0');
        $day_saturday_last = (($p['day_saturday_last'][0] == 'on') ? '1' : '0');
        $day_sunday_all = (($p['day_sunday_all'][0] == 'on') ? '1' : '0');
        $day_sunday_1st = (($p['day_sunday_1st'][0] == 'on') ? '1' : '0');
        $day_sunday_2nd = (($p['day_sunday_2nd'][0] == 'on') ? '1' : '0');
        $day_sunday_3rd = (($p['day_sunday_3rd'][0] == 'on') ? '1' : '0');
        $day_sunday_4th = (($p['day_sunday_4th'][0] == 'on') ? '1' : '0');
        $day_sunday_5th = (($p['day_sunday_5th'][0] == 'on') ? '1' : '0');
        $day_sunday_last = (($p['day_sunday_last'][0] == 'on') ? '1' : '0');
        $timezone_id = prepareDBValue($p['timezone']);

	// update timeframe
	$query = sprintf(
                'update timeframes (timeframe_name=\'%s\', time_monday_invert=\'%s\', time_tuesday_invert=\'%s\', time_wednesday_invert=\'%s\', time_thursday_invert=\'%s\', time_friday_invert=\'%s\', time_saturday_invert=\'%s\', time_sunday_invert=\'%s\', day_sunday_all=\'%s\', day_monday_1st=\'%s\', day_monday_2nd=\'%s\' ,day_monday_3rd=\'%s\' ,day_monday_4th=\'%s\' ,day_monday_5th=\'%s\' ,day_monday_last=\'%s\' ,day_tuesday_1st=\'%s\' ,day_tuesday_2nd=\'%s\' ,day_tuesday_3rd=\'%s\' ,day_tuesday_4th=\'%s\' ,day_tuesday_5th=\'%s\' ,day_tuesday_last=\'%s\' ,day_wednesday_1st=\'%s\' ,day_wednesday_2nd=\'%s\' ,day_wednesday_3rd=\'%s\' ,day_wednesday_4th=\'%s\' ,day_wednesday_5th=\'%s\' ,day_wednesday_last=\'%s\' ,day_thursday_1st=\'%s\' ,day_thursday_2nd=\'%s\' ,day_thursday_3rd=\'%s\' ,day_thursday_4th=\'%s\' ,day_thursday_5th=\'%s\' ,day_thursday_last=\'%s\' ,day_friday_1st=\'%s\' ,day_friday_2nd=\'%s\' ,day_friday_3rd=\'%s\' ,day_friday_4th=\'%s\' ,day_friday_5th=\'%s\' ,day_friday_last=\'%s\' ,day_saturday_1st=\'%s\' ,day_saturday_2nd=\'%s\' ,day_saturday_3rd=\'%s\' ,day_saturday_4th=\'%s\' ,day_saturday_5th=\'%s\' ,day_saturday_last=\'%s\', day_sunday_1st=\'%s\', day_sunday_2nd=\'%s\', day_sunday_3rd=\'%s\', day_sunday_4th=\'%s\', day_sunday_5th=\'%s\', day_sunday_last=\'%s\', timezone_id=\'%s\' where id=\'%s\')
                        values (\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\'',
                $timeframe_name,
                $time_monday_invert,
                $time_tuesday_invert,
                $time_wednesday_invert,
                $time_thursday_invert,
                $time_friday_invert,
                $time_saturday_invert,
                $time_sunday_invert,
		$day_monday_all,
		$day_monday_1st,
		$day_monday_2nd,
		$day_monday_3rd,
		$day_monday_4th,
		$day_monday_5th,
		$day_monday_last,
		$day_tuesday_all,
		$day_tuesday_1st,
		$day_tuesday_2nd,
		$day_tuesday_3rd,
		$day_tuesday_4th,
		$day_tuesday_5th,
		$day_tuesday_last,
		$day_wednesday_all,
		$day_wednesday_1st,
		$day_wednesday_2nd,
		$day_wednesday_3rd,
		$day_wednesday_4th,
		$day_wednesday_5th,
		$day_wednesday_last,
		$day_thursday_all,
		$day_thursday_1st,
		$day_thursday_2nd,
		$day_thursday_3rd,
		$day_thursday_4th,
		$day_thursday_5th,
		$day_thursday_last,
		$day_friday_all,
		$day_friday_1st,
		$day_friday_2nd,
		$day_friday_3rd,
		$day_friday_4th,
		$day_friday_5th,
		$day_friday_last,
		$day_saturday_all,
		$day_saturday_1st,
		$day_saturday_2nd,
		$day_saturday_3rd,
		$day_saturday_4th,
		$day_saturday_5th,
		$day_saturday_last,
                $day_sunday_all,
                $day_sunday_1st,
                $day_sunday_2nd,
                $day_sunday_3rd,
                $day_sunday_4th,
                $day_sunday_5th,
                $day_sunday_last,
                $timezone_id,
		$id
        );
	queryDB($query);


	// delete holidays
	//if (isset($p['del_holiday']) && is_array($p['del_holiday'])) {

	//	$query = 'delete from holidays where (';
	//	$sep = null;
	//	foreach ($p['del_holiday'] as $key => $value) {
	//		$query .= $sep . 'id=\'' . prepareDBValue($key) . '\'';
	//		if (!$sep) $sep = ' or ';
	//	}
	//	$query .= ') and contact_id=\'' . $id . '\'';
	//	queryDB($query);

	//}


	// add holidays
	//if (!empty($p['holiday_start']) && !empty($p['holiday_end'])) {
	//	addHolidays($id, $p['holiday_start'], $p['holiday_end']);
	//}


	return TIMEFRAME_UPDATED;

}




/**
 * delTimeframe - deletes a timeframe and sets all owned notifications to disabled
 *
 * @param		array		$p		posted data for contact update
 * @return							boolean value (false on error)
 */
function delTimeframe ($p) {
// TODO -> SET IT TO USE TIMEFRAME 0 AND DISABLE.
	// pre checks
	if (!isAdmin()) return false;
	if (!isset($p['user'])) return false;
	if (empty($p['user'])) return false;

	// security
	$userPrep = prepareDBValue($p['timeframe_name']);

	// get contact id
	$dbResult = queryDB('select id from timeframes where timeframe_name=\'' . $userPrep . '\'');
	if (!isset($dbResult[0]['id'])) return false;
	$userID = $dbResult[0]['id'];

	// delete all notifications assigned to the posted contact
	queryDB('delete from notifications_to_contacts where contact_id=\'' . $userID . '\'');

	// disable all notifications and change usernames of all notifications owned by this user
	queryDB('update notifications set active=\'0\', username=\'' . prepareDBValue('[' . $p['user'] . ']') . '\' where username=\'' . $userPrep . '\'');

	// finally, delete the user
	queryDB('delete from contacts where id=\'' . $userID . '\'');

	return true;

}




/**
 * checkTimeframesMod - checks whether a user may add or edit a timeframe
 *
 * @param		string		$id			user id to check (optional)
 * @return								boolean value (false on error)
 */
function checkTimeframesMod ($id = null) {

	global $authentication_type;

	if (!$authentication_type) {

			// no authentication -> no further security checks
			return true;

	} else {
 
 		// get id and admin state of logged in user
		$dbResult = queryDB('select id,admin from contacts where username=\'' . prepareDBValue($_SESSION['user']) . '\' limit 1');

		if (!count($dbResult)) {
			session_destroy();
			return false;
		}

		// if we are admin, everything is fine
		if ($dbResult[0]['admin'] == '1') return true;

		// we are not an admin... are we trying to update our own entry?
		if (empty($id)) return false;
		if ($dbResult[0]['id'] == $id) return true;

	}

	return false;

}




/**
 * addHolidays - adds holidays for a certain contact
 *
 * @param		integer			$id			contact's ID
 * @param		string			$start		start of holidays
 * @param		string			$end		end of holidays
 * @return									boolean value (false on error)
 */
/*
function addHolidays ($id, $start, $end) {

	// prepare data
	$start = prepareDBValue($start);
	$end = prepareDBValue($end);

	// check whether holidays exist
	$query =  sprintf(
		'select count(*) cnt from holidays where contact_id=\'%s\' and start=\'%s\' and end=\'%s\'',
		$id,
		$start,
		$end
	);
	$dbResult = queryDB($query);
	if ($dbResult[0]['cnt'] != '0') return false;

	// add holidays
	$query = sprintf(
		'insert into holidays (contact_id,start,end) values (\'%s\',\'%s\',\'%s\')',
		$id,
		$start,
		$end
	);
	queryDB($query);

	return true;

}
*/

?>
