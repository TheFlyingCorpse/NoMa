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
 * getContent - main function for this module
 *
 * @param		none
 * @return		HTML content
 */
function getContent () {

	global $authentication_type, $message;

	//init
	$timeframeData = array();
	$userHolidays = array();


	$templateContent = new nwTemplate(TEMPLATE_TIMEFRAME_MANAGER);

	// assign labels
	$templateContent->assign('TIMEFRAME_OVERVIEW_LINK', TIMEFRAME_OVERVIEW_LINK);
	$templateContent->assign('TIMEFRAME_HEADING_NAME', TIMEFRAME_HEADING_NAME);
	$templateContent->assign('TIMEFRAME_HEADING_CONTACT', TIMEFRAME_HEADING_CONTACT);
	$templateContent->assign('TIMEFRAME_HEADING_TIME', TIMEFRAME_HEADING_TIME);
	$templateContent->assign('TIMEFRAME_HEADING_ADMIN', TIMEFRAME_HEADING_ADMIN);
	$templateContent->assign('TIMEFRAME_NAME', TIMEFRAME_NAME);
        $templateContent->assign('TIMEFRAME_FRAME_VALID_FROM', TIMEFRAME_FRAME_VALID_FROM);
        $templateContent->assign('TIMEFRAME_FRAME_VALID_TO', TIMEFRAME_FRAME_VALID_TO);
        $templateContent->assign('TIMEFRAME_TIME_FROM', TIMEFRAME_TIME_FROM);
        $templateContent->assign('TIMEFRAME_TIME_TO', TIMEFRAME_TIME_TO);
        $templateContent->assign('TIMEFRAME_TIME_INVERT', TIMEFRAME_TIME_INVERT);
	$templateContent->assign('TIMEFRAME_DAYS_ALL', TIMEFRAME_DAYS_ALL);
	$templateContent->assign('TIMEFRAME_DAYS_1ST', TIMEFRAME_DAYS_1ST);
	$templateContent->assign('TIMEFRAME_DAYS_2ND', TIMEFRAME_DAYS_2ND);
	$templateContent->assign('TIMEFRAME_DAYS_3RD', TIMEFRAME_DAYS_3RD);
	$templateContent->assign('TIMEFRAME_DAYS_4TH', TIMEFRAME_DAYS_4TH);
        $templateContent->assign('TIMEFRAME_DAYS_5TH', TIMEFRAME_DAYS_5TH);
	$templateContent->assign('TIMEFRAME_DAYS_LAST', TIMEFRAME_DAYS_LAST);
        $templateContent->assign('TIMEFRAME_DAYS_OF_WEEK', TIMEFRAME_DAYS_OF_WEEK);
        $templateContent->assign('TIMEFRAME_DAY_MONDAY', TIMEFRAME_DAY_MONDAY);
        $templateContent->assign('TIMEFRAME_DAY_TUESDAY', TIMEFRAME_DAY_TUESDAY);
        $templateContent->assign('TIMEFRAME_DAY_WEDNESDAY', TIMEFRAME_DAY_WEDNESDAY);
        $templateContent->assign('TIMEFRAME_DAY_THURSDAY', TIMEFRAME_DAY_THURSDAY);
        $templateContent->assign('TIMEFRAME_DAY_FRIDAY', TIMEFRAME_DAY_FRIDAY);
        $templateContent->assign('TIMEFRAME_DAY_SATURDAY', TIMEFRAME_DAY_SATURDAY);
        $templateContent->assign('TIMEFRAME_DAY_SUNDAY', TIMEFRAME_DAY_SUNDAY);
	$templateContent->assign('TIMEFRAME_TIMEZONE', TIMEFRAME_TIMEZONE);


	// assign messages
	if (!empty($message)) $templateContent->assign('MESSAGE', $message);


	if (empty($id)) {
		$templateContent->assign('HEADING', TIMEFRAME_ADD_EDIT);
	} else {
		$templateContent->assign('HEADING', TIMEFRAME_EDIT);
	}


	// check whether user is admin
	$admin = false;
	if (!empty($_SESSION['user']) || !$authentication_type) {
		if (!empty($_SESSION['user'])) {
			$dbResult = queryDB('select admin from contacts where username=\'' . prepareDBValue($_SESSION['user']) . '\'');
			if ($dbResult[0]['admin'] == '1') $admin = true;
		} else {
			$admin = true;
		}
	}


	$timeframeData = array();


	// query timeframe data
	$timeframe = null;
	$postTimeframe = ((isset($_POST['timeframe'])) ? $_POST['timeframe'] : null);
	if ($postTimeframe && $admin) {
		$user = prepareDBValue($postTimeframe);
	} else {
		if (!$admin) $timeframe = prepareDBValue($_SESSION['timeframe']);
	}


	// add admin content
	if ($admin) {

		$templateSubContent = new nwTemplate(TEMPLATE_TIMEFRAME_MANAGER_ADMIN);
		$templateSubContent->assign('TIMEFRAME_HEADING_ADMIN', TIMEFRAME_HEADING_ADMIN);
		$templateSubContent->assign('TIMEFRAME_FRAMES', TIMEFRAME_FRAMES);
		$templateSubContent->assign('TIMEFRAME_NEW_FRAME', TIMEFRAME_NEW_FRAME);
		$templateSubContent->assign('TIMEFRAME_ADMIN', TIMEFRAME_ADMIN);
		$templateSubContent->assign('TIMEFRAME_SELECT', htmlSelect('timeframe', getTimeFrames(), $postTimeframe, 'onchange="document.timeframe_form.edit.click();"', array('', TIMEFRAME_SELECT_FRAME_NEW)));
		$templateSubContent->assign('TIMEFRAME_EDIT_BUTTON', TIMEFRAME_EDIT_BUTTON);

		// check whether a timeframe has been selected
		if (!empty($postTimeframe)) {

			// get timeframe from database
			$dbResult = queryDB('select * from timeframes where timeframe_name=\'' . prepareDBValue($postTimeframe) . '\' limit 1');
			$timeframeData = $dbResult[0];

		}
	}




	// fill template w/ found data
	if (count($timeframeData)) {
		// get user's holidays from database
		//$userHolidays = queryDB('select * from holidays where contact_id=\'' . $timeframeData['id'] . '\' order by start asc');
		$templateContent->assign('ID', $timeframeData['id']);
		$templateContent->assign('TIMEFRAME_NAME', $timeframeData['timeframe_name']);
                $templateContent->assign('TIME_VALID_DATETIME_FROM', $timeframeData['dt_validFrom']);
                $templateContent->assign('TIME_VALID_DATETIME_TO', $timeframeData['dt_validTo']);
                $templateContent->assign('TIME_MONDAY_TIME_FROM', $timeframeData['time_monday_start']);
                $templateContent->assign('TIME_TUESDAY_TIME_FROM', $timeframeData['time_tuesday_start']);
                $templateContent->assign('TIME_WEDNESDAY_TIME_FROM', $timeframeData['time_wednesday_start']);
                $templateContent->assign('TIME_THURSDAY_TIME_FROM', $timeframeData['time_thursday_start']);
                $templateContent->assign('TIME_FRIDAY_TIME_FROM', $timeframeData['time_friday_start']);
                $templateContent->assign('TIME_SATURDAY_TIME_FROM', $timeframeData['time_saturday_start']);
                $templateContent->assign('TIME_SUNDAY_TIME_FROM', $timeframeData['time_sunday_start']);
                $templateContent->assign('TIME_MONDAY_TIME_TO', $timeframeData['time_monday_stop']);
                $templateContent->assign('TIME_TUESDAY_TIME_TO', $timeframeData['time_tuesday_stop']);
                $templateContent->assign('TIME_WEDNESDAY_TIME_TO', $timeframeData['time_wednesday_stop']);
                $templateContent->assign('TIME_THURSDAY_TIME_TO', $timeframeData['time_thursday_stop']);
                $templateContent->assign('TIME_FRIDAY_TIME_TO', $timeframeData['time_friday_stop']);
                $templateContent->assign('TIME_SATURDAY_TIME_TO', $timeframeData['time_saturday_stop']);
                $templateContent->assign('TIME_SUNDAY_TIME_TO', $timeframeData['time_sunday_stop']);
                $templateContent->assign('CHECKED_TIME_MONDAY_TIME_INVERT', ($timeframeData['time_monday_invert']==1)?' checked="checked" ':'');
                $templateContent->assign('CHECKED_TIME_TUESDAY_TIME_INVERT', ($timeframeData['time_tuesday_invert']==1)?' checked="checked" ':'');
                $templateContent->assign('CHECKED_TIME_WEDNESDAY_TIME_INVERT', ($timeframeData['time_wednesday_invert']==1)?' checked="checked" ':'');
                $templateContent->assign('CHECKED_TIME_THRUSDAY_TIME_INVERT', ($timeframeData['time_thursday_invert']==1)?' checked="checked" ':'');
                $templateContent->assign('CHECKED_TIME_FRIDAY_TIME_INVERT', ($timeframeData['time_friday_invert']==1)?' checked="checked" ':'');
                $templateContent->assign('CHECKED_TIME_SATURDAY_TIME_INVERT', ($timeframeData['time_saturday_invert']==1)?' checked="checked" ':'');
                $templateContent->assign('CHECKED_TIME_SUNDAY_TIME_INVERT', ($timeframeData['time_sunday_invert']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_MONDAY_ALL', ($timeframeData['day_monday_all']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_MONDAY_1ST', ($timeframeData['day_monday_1st']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_MONDAY_2ND', ($timeframeData['day_monday_2nd']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_MONDAY_3RD', ($timeframeData['day_monday_3rd']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_MONDAY_4TH', ($timeframeData['day_monday_4th']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_MONDAY_5TH', ($timeframeData['day_monday_5th']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_MONDAY_LAST', ($timeframeData['day_monday_last']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_TUESDAY_ALL', ($timeframeData['day_tuesday_all']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_TUESDAY_1ST', ($timeframeData['day_tuesday_1st']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_TUESDAY_2ND', ($timeframeData['day_tuesday_2nd']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_TUESDAY_3RD', ($timeframeData['day_tuesday_3rd']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_TUESDAY_4TH', ($timeframeData['day_tuesday_4th']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_TUESDAY_5TH', ($timeframeData['day_tuesday_5th']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_TUESDAY_LAST', ($timeframeData['day_tuesday_last']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_WEDNESDAY_ALL', ($timeframeData['day_wednesday_all']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_WEDNESDAY_1ST', ($timeframeData['day_wednesday_1st']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_WEDNESDAY_2ND', ($timeframeData['day_wednesday_2nd']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_WEDNESDAY_3RD', ($timeframeData['day_wednesday_3rd']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_WEDNESDAY_4TH', ($timeframeData['day_wednesday_4th']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_WEDNESDAY_5TH', ($timeframeData['day_wednesday_5th']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_WEDNESDAY_LAST', ($timeframeData['day_wednesday_last']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_THURSDAY_ALL', ($timeframeData['day_thursday_all']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_THURSDAY_1ST', ($timeframeData['day_thursday_1st']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_THURSDAY_2ND', ($timeframeData['day_thursday_2nd']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_THURSDAY_3RD', ($timeframeData['day_thursday_3rd']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_THURSDAY_4TH', ($timeframeData['day_thursday_4th']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_THURSDAY_5TH', ($timeframeData['day_thursday_5th']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_THURSDAY_LAST', ($timeframeData['day_thursday_last']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_FRIDAY_ALL', ($timeframeData['day_friday_all']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_FRIDAY_1ST', ($timeframeData['day_friday_1st']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_FRIDAY_2ND', ($timeframeData['day_friday_2nd']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_FRIDAY_3RD', ($timeframeData['day_friday_3rd']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_FRIDAY_4TH', ($timeframeData['day_friday_4th']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_FRIDAY_5TH', ($timeframeData['day_friday_5th']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_FRIDAY_LAST', ($timeframeData['day_friday_last']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_SATURDAY_ALL', ($timeframeData['day_saturday_all']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_SATURDAY_1ST', ($timeframeData['day_saturday_1st']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_SATURDAY_2ND', ($timeframeData['day_saturday_2nd']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_SATURDAY_3RD', ($timeframeData['day_saturday_3rd']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_SATURDAY_4TH', ($timeframeData['day_saturday_4th']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_SATURDAY_5TH', ($timeframeData['day_saturday_5th']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_SATURDAY_LAST', ($timeframeData['day_saturday_last']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_SUNDAY_ALL', ($timeframeData['day_sunday_all']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_SUNDAY_1ST', ($timeframeData['day_sunday_1st']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_SUNDAY_2ND', ($timeframeData['day_sunday_2nd']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_SUNDAY_3RD', ($timeframeData['day_sunday_3rd']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_SUNDAY_4TH', ($timeframeData['day_sunday_4th']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_SUNDAY_5TH', ($timeframeData['day_sunday_5th']==1)?' checked="checked" ':'');
		$templateContent->assign('CHECKED_DAY_SUNDAY_LAST', ($timeframeData['day_sunday_last']==1)?' checked="checked" ':'');

        if ($admin) {
            // display delete button
            $templateSubContentDelete = new nwTemplate(TEMPLATE_TIMEFRAME_MANAGER_ADMIN_DELETE);
            $templateSubContentDelete->assign('TIMEFRAME_DEL_BUTTON', TIMEFRAME_DEL_BUTTON);
            $templateSubContentDelete->assign('TIMEFRAME_CONFIRM_DEL', TIMEFRAME_CONFIRM_DEL);
            $templateSubContent->assign('TIMEFRAME_DEL_BUTTON', $templateSubContentDelete->getHTML());
        }
	}


	// assign admin content	
	if ($admin) $templateContent->assign('ADMIN_CONTENT', $templateSubContent->getHTML());


	if (!isset($timeframeData['timezone_id'])) $timeframeData['timezone_id'] = null;
	$templateContent->assign('TIMEZONE_SELECT', htmlSelect('timezone', getTimeZone(), $timeframeData['timezone_id']));	

/*
	// add user's holiday data
	$content = null;
	foreach ($userHolidays as $row) {
		$templateSubContent = new nwTemplate(TEMPLATE_CONTACT_MANAGER_HOLIDAYS_ROW);
		$templateSubContent->assign('TIMEFRAME_HOLIDAYS_DELETE', TIMEFRAME_HOLIDAYS_DELETE);
		$templateSubContent->assign('ID', $row['id']);
		$templateSubContent->assign('START', $row['start']);
		$templateSubContent->assign('END', $row['end']);
		$content .= $templateSubContent->getHTML();
	}
	$templateContent->assign('HOLIDAYS', $content);
*/

	if (empty($user)) {
		$templateContent->assign('TIMEFRAME_SUBMIT', TIMEFRAME_SUBMIT_ADD);
	} else {
		$templateContent->assign('TIMEFRAME_SUBMIT', TIMEFRAME_SUBMIT_UPDATE);
	}



	return $templateContent->getHTML();

}

?>
