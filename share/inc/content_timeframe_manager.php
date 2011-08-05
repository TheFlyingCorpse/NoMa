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

	global $p, $timeframes, $message;

	// security
	if ($timeframes['admin_only'] && !isAdmin()) return null;
	
	// get timeframe to edit
	$timeframe = ((isset($p['timeframe'])) ? $p['timeframe'] : null);
	if (empty($timeframe)) $timeframe = null;

	$templateContent = new nwTemplate(TEMPLATE_TIMEFRAME_MANAGER);


	// assign statics
	$templateContent->assign('TIMEFRAME_OVERVIEW_LINK', TIMEFRAME_OVERVIEW_LINK);
	$templateContent->assign('TIMEFRAME_HEADING', TIMEFRAME_HEADING);
	$templateContent->assign('TIMEFRAME_HEADING_EDIT', TIMEFRAME_HEADING_EDIT);
	$templateContent->assign('TIMEFRAME_HEADING_SELECT', TIMEFRAME_HEADING_SELECT);
	$templateContent->assign('TIMEFRAME_EDIT_FRAMES', TIMEFRAME_EDIT_FRAMES);
	$templateContent->assign('TIMEFRAME_EDIT_BUTTON', TIMEFRAME_EDIT_BUTTON);
        $templateContent->assign('TIMEFRAME_TIMEFRAME', TIMEFRAME_TIMEFRAME);

	// add message
	if (!empty($message)) $templateContent->assign('MESSAGE', $message);


	// assign timeframe id
	$id = $timeframe;
	$templateContent->assign('ID', $id);


	// assign select fields for timeframes
	$timeframes = getTimeFrames();
	$templateContent->assign('TIMEFRAME_EDIT_SELECT', htmlSelect('timeframe', $timeframes, $id,  'onchange="document.timeframe_form.edit.click();"', array('', TIMEFRAME_SELECT_FRAME_NEW)));

	// add form content
	if (!empty($id)) {
		$timeframeData = getTimeFrameById($id);

		// Edit + translations
		$templateSubContent = new nwTemplate(TEMPLATE_TIMEFRAME_MANAGER_EDIT);
		$templateSubContent->assign('TIMEFRAME_HEADING_EDIT', TIMEFRAME_HEADING_EDIT);
		$templateSubContent->assign('TIMEFRAME_EDIT_NAME', TIMEFRAME_EDIT_NAME);
		$templateSubContent->assign('TIMEFRAME_EDIT_USERS', TIMEFRAME_EDIT_USERS);
		$templateSubContent->assign('TIMEFRAME_SUBMIT_CHANGES_BUTTON', TIMEFRAME_SUBMIT_CHANGES_BUTTON);
		$templateSubContent->assign('TIMEFRAME_FRAME_VALID_FROM', TIMEFRAME_FRAME_VALID_FROM);
		$templateSubContent->assign('TIMEFRAME_FRAME_VALID_TO', TIMEFRAME_FRAME_VALID_TO);
		$templateSubContent->assign('TIMEFRAME_TIME_FROM', TIMEFRAME_TIME_FROM);
		$templateSubContent->assign('TIMEFRAME_FRAME', TIMEFRAME_FRAME);
		$templateSubContent->assign('TIMEFRAME_TIME_TO', TIMEFRAME_TIME_TO);
		$templateSubContent->assign('TIMEFRAME_TIME_INVERT', TIMEFRAME_TIME_INVERT);
		$templateSubContent->assign('TIMEFRAME_DAYS_ALL', TIMEFRAME_DAYS_ALL);
		$templateSubContent->assign('TIMEFRAME_DAYS_1ST', TIMEFRAME_DAYS_1ST);
		$templateSubContent->assign('TIMEFRAME_DAYS_2ND', TIMEFRAME_DAYS_2ND);
		$templateSubContent->assign('TIMEFRAME_DAYS_3RD', TIMEFRAME_DAYS_3RD);
		$templateSubContent->assign('TIMEFRAME_DAYS_4TH', TIMEFRAME_DAYS_4TH);
		$templateSubContent->assign('TIMEFRAME_DAYS_5TH', TIMEFRAME_DAYS_5TH);
		$templateSubContent->assign('TIMEFRAME_DAYS_LAST', TIMEFRAME_DAYS_LAST);
		$templateSubContent->assign('TIMEFRAME_DAYS_OF_WEEK', TIMEFRAME_DAYS_OF_WEEK);
		$templateSubContent->assign('TIMEFRAME_DAY_MONDAY', TIMEFRAME_DAY_MONDAY);
		$templateSubContent->assign('TIMEFRAME_DAY_TUESDAY', TIMEFRAME_DAY_TUESDAY);
		$templateSubContent->assign('TIMEFRAME_DAY_WEDNESDAY', TIMEFRAME_DAY_WEDNESDAY);
		$templateSubContent->assign('TIMEFRAME_DAY_THURSDAY', TIMEFRAME_DAY_THURSDAY);
		$templateSubContent->assign('TIMEFRAME_DAY_FRIDAY', TIMEFRAME_DAY_FRIDAY);
		$templateSubContent->assign('TIMEFRAME_DAY_SATURDAY', TIMEFRAME_DAY_SATURDAY);
		$templateSubContent->assign('TIMEFRAME_DAY_SUNDAY', TIMEFRAME_DAY_SUNDAY);

		// From DB
                $templateSubContent->assign('ID', $timeframeData['id']);
                $templateSubContent->assign('TIMEFRAME_NAME', $timeframeData['timeframe_name']);
                $templateSubContent->assign('TIME_VALID_DATETIME_FROM', $timeframeData['dt_validFrom']);
                $templateSubContent->assign('TIME_VALID_DATETIME_TO', $timeframeData['dt_validTo']);
                $templateSubContent->assign('TIME_MONDAY_TIME_FROM', $timeframeData['time_monday_start']);
                $templateSubContent->assign('TIME_TUESDAY_TIME_FROM', $timeframeData['time_tuesday_start']);
                $templateSubContent->assign('TIME_WEDNESDAY_TIME_FROM', $timeframeData['time_wednesday_start']);
                $templateSubContent->assign('TIME_THURSDAY_TIME_FROM', $timeframeData['time_thursday_start']);
                $templateSubContent->assign('TIME_FRIDAY_TIME_FROM', $timeframeData['time_friday_start']);
                $templateSubContent->assign('TIME_SATURDAY_TIME_FROM', $timeframeData['time_saturday_start']);
                $templateSubContent->assign('TIME_SUNDAY_TIME_FROM', $timeframeData['time_sunday_start']);
                $templateSubContent->assign('TIME_MONDAY_TIME_TO', $timeframeData['time_monday_stop']);
                $templateSubContent->assign('TIME_TUESDAY_TIME_TO', $timeframeData['time_tuesday_stop']);
                $templateSubContent->assign('TIME_WEDNESDAY_TIME_TO', $timeframeData['time_wednesday_stop']);
                $templateSubContent->assign('TIME_THURSDAY_TIME_TO', $timeframeData['time_thursday_stop']);
                $templateSubContent->assign('TIME_FRIDAY_TIME_TO', $timeframeData['time_friday_stop']);
                $templateSubContent->assign('TIME_SATURDAY_TIME_TO', $timeframeData['time_saturday_stop']);
                $templateSubContent->assign('TIME_SUNDAY_TIME_TO', $timeframeData['time_sunday_stop']);
                $templateSubContent->assign('CHECKED_TIME_MONDAY_TIME_INVERT', ($timeframeData['time_monday_invert']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_TIME_TUESDAY_TIME_INVERT', ($timeframeData['time_tuesday_invert']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_TIME_WEDNESDAY_TIME_INVERT', ($timeframeData['time_wednesday_invert']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_TIME_THURSDAY_TIME_INVERT', ($timeframeData['time_thursday_invert']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_TIME_FRIDAY_TIME_INVERT', ($timeframeData['time_friday_invert']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_TIME_SATURDAY_TIME_INVERT', ($timeframeData['time_saturday_invert']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_TIME_SUNDAY_TIME_INVERT', ($timeframeData['time_sunday_invert']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_MONDAY_ALL', ($timeframeData['day_monday_all']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_MONDAY_1ST', ($timeframeData['day_monday_1st']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_MONDAY_2ND', ($timeframeData['day_monday_2nd']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_MONDAY_3RD', ($timeframeData['day_monday_3rd']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_MONDAY_4TH', ($timeframeData['day_monday_4th']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_MONDAY_5TH', ($timeframeData['day_monday_5th']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_MONDAY_LAST', ($timeframeData['day_monday_last']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_TUESDAY_ALL', ($timeframeData['day_tuesday_all']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_TUESDAY_1ST', ($timeframeData['day_tuesday_1st']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_TUESDAY_2ND', ($timeframeData['day_tuesday_2nd']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_TUESDAY_3RD', ($timeframeData['day_tuesday_3rd']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_TUESDAY_4TH', ($timeframeData['day_tuesday_4th']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_TUESDAY_5TH', ($timeframeData['day_tuesday_5th']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_TUESDAY_LAST', ($timeframeData['day_tuesday_last']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_WEDNESDAY_ALL', ($timeframeData['day_wednesday_all']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_WEDNESDAY_1ST', ($timeframeData['day_wednesday_1st']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_WEDNESDAY_2ND', ($timeframeData['day_wednesday_2nd']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_WEDNESDAY_3RD', ($timeframeData['day_wednesday_3rd']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_WEDNESDAY_4TH', ($timeframeData['day_wednesday_4th']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_WEDNESDAY_5TH', ($timeframeData['day_wednesday_5th']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_WEDNESDAY_LAST', ($timeframeData['day_wednesday_last']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_THURSDAY_ALL', ($timeframeData['day_thursday_all']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_THURSDAY_1ST', ($timeframeData['day_thursday_1st']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_THURSDAY_2ND', ($timeframeData['day_thursday_2nd']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_THURSDAY_3RD', ($timeframeData['day_thursday_3rd']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_THURSDAY_4TH', ($timeframeData['day_thursday_4th']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_THURSDAY_5TH', ($timeframeData['day_thursday_5th']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_THURSDAY_LAST', ($timeframeData['day_thursday_last']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_FRIDAY_ALL', ($timeframeData['day_friday_all']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_FRIDAY_1ST', ($timeframeData['day_friday_1st']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_FRIDAY_2ND', ($timeframeData['day_friday_2nd']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_FRIDAY_3RD', ($timeframeData['day_friday_3rd']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_FRIDAY_4TH', ($timeframeData['day_friday_4th']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_FRIDAY_5TH', ($timeframeData['day_friday_5th']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_FRIDAY_LAST', ($timeframeData['day_friday_last']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_SATURDAY_ALL', ($timeframeData['day_saturday_all']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_SATURDAY_1ST', ($timeframeData['day_saturday_1st']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_SATURDAY_2ND', ($timeframeData['day_saturday_2nd']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_SATURDAY_3RD', ($timeframeData['day_saturday_3rd']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_SATURDAY_4TH', ($timeframeData['day_saturday_4th']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_SATURDAY_5TH', ($timeframeData['day_saturday_5th']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_SATURDAY_LAST', ($timeframeData['day_saturday_last']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_SUNDAY_ALL', ($timeframeData['day_sunday_all']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_SUNDAY_1ST', ($timeframeData['day_sunday_1st']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_SUNDAY_2ND', ($timeframeData['day_sunday_2nd']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_SUNDAY_3RD', ($timeframeData['day_sunday_3rd']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_SUNDAY_4TH', ($timeframeData['day_sunday_4th']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_SUNDAY_5TH', ($timeframeData['day_sunday_5th']==1)?' checked="checked" ':'');
                $templateSubContent->assign('CHECKED_DAY_SUNDAY_LAST', ($timeframeData['day_sunday_last']==1)?' checked="checked" ':'');

		// Delete button + translations.
		$templateSubContentDelete = new nwTemplate(TEMPLATE_TIMEFRAME_MANAGER_DELETE);
		$templateSubContentDelete->assign('TIMEFRAME_DELETE_BUTTON', TIMEFRAME_DELETE_BUTTON);
		$templateSubContentDelete->assign('TIMEFRAME_CONFIRM_DEL', TIMEFRAME_CONFIRM_DEL);
		$templateContent->assign('TIMEFRAME_DELETE_BUTTON', $templateSubContentDelete->getHTML());
	} else {
		$templateSubContent = new nwTemplate(TEMPLATE_TIMEFRAME_MANAGER_ADD);
		$templateSubContent->assign('TIMEFRAME_HEADING_ADD', TIMEFRAME_HEADING_ADD);
		$templateSubContent->assign('TIMEFRAME_ADD_BUTTON', TIMEFRAME_ADD_BUTTON);

		$templateSubContent->assign('TIMEFRAME_ADD_FRAME', TIMEFRAME_ADD_FRAME);
                $templateSubContent->assign('TIMEFRAME_FRAME_VALID_FROM', TIMEFRAME_FRAME_VALID_FROM);
                $templateSubContent->assign('TIMEFRAME_FRAME_VALID_TO', TIMEFRAME_FRAME_VALID_TO);
                $templateSubContent->assign('TIMEFRAME_TIME_FROM', TIMEFRAME_TIME_FROM);
                $templateSubContent->assign('TIMEFRAME_FRAME', TIMEFRAME_FRAME);
                $templateSubContent->assign('TIMEFRAME_TIME_TO', TIMEFRAME_TIME_TO);
                $templateSubContent->assign('TIMEFRAME_TIME_INVERT', TIMEFRAME_TIME_INVERT);
                $templateSubContent->assign('TIMEFRAME_DAYS_ALL', TIMEFRAME_DAYS_ALL);
                $templateSubContent->assign('TIMEFRAME_DAYS_1ST', TIMEFRAME_DAYS_1ST);
                $templateSubContent->assign('TIMEFRAME_DAYS_2ND', TIMEFRAME_DAYS_2ND);
                $templateSubContent->assign('TIMEFRAME_DAYS_3RD', TIMEFRAME_DAYS_3RD);
                $templateSubContent->assign('TIMEFRAME_DAYS_4TH', TIMEFRAME_DAYS_4TH);
                $templateSubContent->assign('TIMEFRAME_DAYS_5TH', TIMEFRAME_DAYS_5TH);
                $templateSubContent->assign('TIMEFRAME_DAYS_LAST', TIMEFRAME_DAYS_LAST);
                $templateSubContent->assign('TIMEFRAME_DAYS_OF_WEEK', TIMEFRAME_DAYS_OF_WEEK);
                $templateSubContent->assign('TIMEFRAME_DAY_MONDAY', TIMEFRAME_DAY_MONDAY);
                $templateSubContent->assign('TIMEFRAME_DAY_TUESDAY', TIMEFRAME_DAY_TUESDAY);
                $templateSubContent->assign('TIMEFRAME_DAY_WEDNESDAY', TIMEFRAME_DAY_WEDNESDAY);
                $templateSubContent->assign('TIMEFRAME_DAY_THURSDAY', TIMEFRAME_DAY_THURSDAY);
                $templateSubContent->assign('TIMEFRAME_DAY_FRIDAY', TIMEFRAME_DAY_FRIDAY);
                $templateSubContent->assign('TIMEFRAME_DAY_SATURDAY', TIMEFRAME_DAY_SATURDAY);
                $templateSubContent->assign('TIMEFRAME_DAY_SUNDAY', TIMEFRAME_DAY_SUNDAY);


	}

	$templateContent->assign('TIMEFRAME_MAIN_CONTENT', $templateSubContent->getHTML());

	return $templateContent->getHTML();

}


?>
