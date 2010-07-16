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
	$userData = array();
	$userHolidays = array();


	$templateContent = new nwTemplate(TEMPLATE_CONTACT_MANAGER);

	// assign labels
	$templateContent->assign('CONTACTS_OVERVIEW_LINK', CONTACTS_OVERVIEW_LINK);
	$templateContent->assign('CONTACTS_HEADING_NAME', CONTACTS_HEADING_NAME);
	$templateContent->assign('CONTACTS_HEADING_CONTACT', CONTACTS_HEADING_CONTACT);
	$templateContent->assign('CONTACTS_HEADING_TIME', CONTACTS_HEADING_TIME);
	$templateContent->assign('CONTACTS_HEADING_ADMIN', CONTACTS_HEADING_ADMIN);
	$templateContent->assign('CONTACTS_FIRST_NAME', CONTACTS_FIRST_NAME);
	$templateContent->assign('CONTACTS_LAST_NAME', CONTACTS_LAST_NAME);
	$templateContent->assign('CONTACTS_USERNAME', CONTACTS_USERNAME);
	$templateContent->assign('CONTACTS_EMAIL', CONTACTS_EMAIL);
	$templateContent->assign('CONTACTS_PHONE', CONTACTS_PHONE);
	$templateContent->assign('CONTACTS_MOBILE', CONTACTS_MOBILE);
	$templateContent->assign('CONTACTS_RESTRICT_ALERTS', CONTACTS_RESTRICT_ALERTS);
	$templateContent->assign('CONTACTS_TIMEPERIOD', CONTACTS_TIMEPERIOD);
	$templateContent->assign('CONTACTS_TIMEZONE', CONTACTS_TIMEZONE);
	$templateContent->assign('CONTACTS_HEADING_HOLIDAYS', CONTACTS_HEADING_HOLIDAYS);
	$templateContent->assign('CONTACTS_HOLIDAYS_START', CONTACTS_HOLIDAYS_START);
	$templateContent->assign('CONTACTS_HOLIDAYS_END', CONTACTS_HOLIDAYS_END);


	// assign messages
	if (!empty($message)) $templateContent->assign('MESSAGE', $message);


	if (empty($id)) {
		$templateContent->assign('HEADING', CONTACTS_ADD_EDIT_USER);
	} else {
		$templateContent->assign('HEADING', CONTACTS_EDIT_USER);
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


	// add fields for user password
	if ($authentication_type == 'native') {
		$templateSubContent = new nwTemplate(TEMPLATE_CONTACT_MANAGER_PASSWORD);
		$templateSubContent->assign('CONTACTS_PASSWORD', CONTACTS_PASSWORD);
		$templateSubContent->assign('CONTACTS_PASSWORD_VERIFY', CONTACTS_PASSWORD_VERIFY);
		$templateContent->assign('PASSWORD_FIELDS', $templateSubContent->getHTML());
	}


	$userData = array();


	// query user data
	$user = null;
	$postUser = ((isset($_POST['user'])) ? $_POST['user'] : null);
	if ($postUser && $admin) {
		$user = prepareDBValue($postUser);
	} else {
		if (!$admin) $user = prepareDBValue($_SESSION['user']);
	}


	// add admin content
	if ($admin) {

		$templateSubContent = new nwTemplate(TEMPLATE_CONTACT_MANAGER_ADMIN);
		$templateSubContent->assign('CONTACTS_HEADING_ADMIN', CONTACTS_HEADING_ADMIN);
		$templateSubContent->assign('CONTACTS_USER', CONTACTS_USER);
		$templateSubContent->assign('CONTACTS_NEW_USERNAME', CONTACTS_NEW_USERNAME);
		$templateSubContent->assign('CONTACTS_ADMIN', CONTACTS_ADMIN);
		$templateSubContent->assign('USER_SELECT', htmlSelect('user', getContacts(), $postUser, 'onchange="document.contact_form.edit.click();"', array('', CONTACTS_SELECT_USER_NEW)));
		$templateSubContent->assign('CONTACTS_EDIT_BUTTON', CONTACTS_EDIT_BUTTON);

		// check whether a user has been selected
		if (!empty($postUser)) {

			// get user info from database
			$dbResult = queryDB('select * from contacts where username=\'' . prepareDBValue($postUser) . '\' limit 1');
			$userData = $dbResult[0];

		}

	} else {

		$dbResult = queryDB('select * from contacts where username=\'' . $user . '\'');
		$userData = $dbResult[0];

	}




	// fill template w/ found data
	if (count($userData)) {
		// get user's holidays from database
		$userHolidays = queryDB('select * from holidays where contact_id=\'' . $userData['id'] . '\' order by start asc');
		if ($userData['admin'] == '1' && $admin) $templateSubContent->assign('CHECKED_ADMIN', ' checked');
		$templateContent->assign('ID', $userData['id']);
		$templateContent->assign('FIRST_NAME', $userData['first_name']);
		$templateContent->assign('LAST_NAME', $userData['last_name']);
		$templateContent->assign('USERNAME', $userData['username']);
		$templateContent->assign('EMAIL', $userData['email']);
		$templateContent->assign('PHONE', $userData['phone']);
		$templateContent->assign('MOBILE', $userData['mobile']);
		$templateContent->assign('RESTRICT_ALERTS', ($userData['restrict_alerts']==1)?'checked="checked"':'');

        if ($admin) {
            // display delete button
            $templateSubContentDelete = new nwTemplate(TEMPLATE_CONTACT_MANAGER_ADMIN_DELETE);
            $templateSubContentDelete->assign('CONTACTS_DEL_BUTTON', CONTACTS_DEL_BUTTON);
            $templateSubContentDelete->assign('CONTACTS_CONFIRM_DEL', CONTACTS_CONFIRM_DEL);
            $templateSubContent->assign('CONTACTS_DEL_BUTTON', $templateSubContentDelete->getHTML());
        }
	}


	// assign admin content	
	if ($admin) $templateContent->assign('ADMIN_CONTENT', $templateSubContent->getHTML());


	if (!isset($userData['time_period_id'])) $userData['time_period_id'] = null;
	if (!isset($userData['timezone_id'])) $userData['timezone_id'] = null;
	$templateContent->assign('TIMEPERIOD_SELECT', htmlSelect('timeperiod', getTimePeriods(), $userData['time_period_id']));	
	$templateContent->assign('TIMEZONE_SELECT', htmlSelect('timezone', getTimeZone(), $userData['timezone_id']));	


	// add user's holiday data
	$content = null;
	foreach ($userHolidays as $row) {
		$templateSubContent = new nwTemplate(TEMPLATE_CONTACT_MANAGER_HOLIDAYS_ROW);
		$templateSubContent->assign('CONTACTS_HOLIDAYS_DELETE', CONTACTS_HOLIDAYS_DELETE);
		$templateSubContent->assign('ID', $row['id']);
		$templateSubContent->assign('START', $row['start']);
		$templateSubContent->assign('END', $row['end']);
		$content .= $templateSubContent->getHTML();
	}
	$templateContent->assign('HOLIDAYS', $content);


	if (empty($user)) {
		$templateContent->assign('CONTACTS_SUBMIT', CONTACTS_SUBMIT_ADD);
	} else {
		$templateContent->assign('CONTACTS_SUBMIT', CONTACTS_SUBMIT_UPDATE);
	}



	return $templateContent->getHTML();

}

?>
