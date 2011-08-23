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
	$userGroups = array();
	$userNotificationsDirect = array();
	//$userNotificationsInDirect = array();
	//$userNotificationsInDirectRaw = array();
	$userEscalationsDirect = array();


	$templateContent = new nwTemplate(TEMPLATE_CONTACT_MANAGER);

	// assign labels
	$templateContent->assign('CONTACTS_OVERVIEW_LINK', CONTACTS_OVERVIEW_LINK);
	$templateContent->assign('CONTACTS_HEADING_NAME', CONTACTS_HEADING_NAME);
	$templateContent->assign('CONTACTS_HEADING_CONTACT', CONTACTS_HEADING_CONTACT);
	$templateContent->assign('CONTACTS_HEADING_TIME', CONTACTS_HEADING_TIME);
	$templateContent->assign('CONTACTS_HEADING_ADMIN', CONTACTS_HEADING_ADMIN);
	$templateContent->assign('CONTACTS_FULL_NAME', CONTACTS_FULL_NAME);
	$templateContent->assign('CONTACTS_USERNAME', CONTACTS_USERNAME);
	$templateContent->assign('CONTACTS_EMAIL', CONTACTS_EMAIL);
	$templateContent->assign('CONTACTS_PHONE', CONTACTS_PHONE);
	$templateContent->assign('CONTACTS_MOBILE', CONTACTS_MOBILE);
        $templateContent->assign('CONTACTS_GROWLADDRESS', CONTACTS_GROWLADDRESS);
        $templateContent->assign('CONTACTS_GROWLREGISTER', CONTACTS_GROWLREGISTER);
	$templateContent->assign('CONTACTS_RESTRICT_ALERTS', CONTACTS_RESTRICT_ALERTS);
	$templateContent->assign('CONTACTS_TIMEFRAME', CONTACTS_TIMEFRAME);
	$templateContent->assign('CONTACTS_TIMEZONE', CONTACTS_TIMEZONE);
	$templateContent->assign('CONTACTS_HEADING_HOLIDAYS', CONTACTS_HEADING_HOLIDAYS);
        $templateContent->assign('CONTACTS_HOLIDAY_ADD_NEW', CONTACTS_HOLIDAY_ADD_NEW);
        $templateContent->assign('CONTACTS_HOLIDAY_DESC_NAME', CONTACTS_HOLIDAY_DESC_NAME);
        $templateContent->assign('CONTACTS_HOLIDAY_DESC_START', CONTACTS_HOLIDAY_DESC_START);
        $templateContent->assign('CONTACTS_HOLIDAY_DESC_END', CONTACTS_HOLIDAY_DESC_END);
        $templateContent->assign('CONTACTS_HEADING_HOLIDAYS', CONTACTS_HEADING_HOLIDAYS);
        $templateContent->assign('CONTACTS_HEADING_MEMBERSHIPS', CONTACTS_HEADING_MEMBERSHIPS);
        $templateContent->assign('LINKED_OBJECTS', LINKED_OBJECTS);

	// assign messages
	if (!empty($message)) $templateContent->assign('MESSAGE', $message);


	if (empty($id)) {
		$templateContent->assign('HEADING', CONTACTS_ADD_EDIT_USER);
	        if (!isset($userData['timeframe_id'])) $userData['timeframe_id'] = null;
        	if (!isset($userData['timezone_id'])) $userData['timezone_id'] = null;
	       	$templateContent->assign('TIMEFRAME_SELECT', htmlSelect('timeframe', getTimeFrames(), $userData['timeframe_id']));
	        $templateContent->assign('TIMEZONE_SELECT', htmlSelect('timezone', getTimeZone(), $userData['timezone_id']));
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
		$userHolidays = queryDB('select * from holidays where contact_id=\'' . $userData['id'] . '\' order by holiday_start asc');
		$userGroups = queryDB('SELECT distinct cg.id,cg.name,cg.name_short,cg.view_only,tf.timeframe_name FROM contactgroups as cg, contactgroups_to_contacts as cgc, timeframes as tf WHERE cgc.contactgroup_id=cg.id and cg.timeframe_id=tf.id and cgc.contact_id=\'' . $userData['id'] . '\'');
		$userNotificationsDirect = queryDB('SELECT distinct n.notification_name, n.active, n.notify_after_tries, tf.timeframe_name 
FROM notifications as n, notifications_to_contacts as nc, timeframes as tf WHERE n.timeframe_id=tf.id AND n.id=nc.notification_id AND nc.contact_id=\'' . $userData['id'] . '\'');
                $userEscalationsDirect = queryDB('SELECT distinct n.notification_name, n.active, ec.notify_after_tries
FROM notifications as n, escalations_contacts as ec, escalations_contacts_to_contacts as ecc WHERE ec.id=ecc.escalation_contacts_id AND n.id=ec.notification_id AND ecc.contacts_id=\'' . $userData['id'] . '\'');
		if ($userData['admin'] == '1' && $admin) $templateSubContent->assign('CHECKED_ADMIN', ' checked');
		$templateContent->assign('ID', $userData['id']);
		$templateContent->assign('FULL_NAME', $userData['full_name']);
		$templateContent->assign('USERNAME', $userData['username']);
		$templateContent->assign('EMAIL', $userData['email']);
		$templateContent->assign('PHONE', $userData['phone']);
		$templateContent->assign('MOBILE', $userData['mobile']);
                $templateContent->assign('GROWLADDRESS', $userData['growladdress']);
		$templateContent->assign('RESTRICT_ALERTS', ($userData['restrict_alerts']==1)?'checked="checked"':'');
       		if (!isset($userData['timeframe_id'])) $userData['timeframe_id'] = null;
       		if (!isset($userData['timezone_id'])) $userData['timezone_id'] = null;
       		$templateContent->assign('TIMEFRAME_SELECT', htmlSelect('timeframe', getTimeFrames(), $userData['timeframe_id']));
	        $templateContent->assign('TIMEZONE_SELECT', htmlSelect('timezone', getTimeZone(), $userData['timezone_id']));


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


	// add user's holiday data
	$content = null;
        foreach ($userHolidays as $row) {
                $templateSubContent = new nwTemplate(TEMPLATE_CONTACT_MANAGER_HOLIDAYS_ROW);
                $templateSubContent->assign('CONTACTS_HOLIDAYS_DELETE', CONTACTS_HOLIDAYS_DELETE);
                $templateSubContent->assign('ID', $row['id']);
                $templateSubContent->assign('CONTACTS_HOLIDAY_NAME', $row['holiday_name']);
                $templateSubContent->assign('CONTACTS_HOLIDAY_START', $row['holiday_start']);
                $templateSubContent->assign('CONTACTS_HOLIDAY_END', $row['holiday_end']);
                $templateSubContent->assign('CONTACTS_HOLIDAY_DESC_SHORT_START', CONTACTS_HOLIDAY_DESC_SHORT_START);
                $templateSubContent->assign('CONTACTS_HOLIDAY_DESC_SHORT_END', CONTACTS_HOLIDAY_DESC_SHORT_END);
                $content .= $templateSubContent->getHTML();
        }
        $templateContent->assign('HOLIDAYS', $content);

        // add user's assigned contactgroups
	$content = null;
	$titlerow = 0;
	foreach ($userGroups as $row) {
		// Title row needed for table?
		if ($titlerow == 0) {
	                $templateSubContent = new nwTemplate(TEMPLATE_CONTACT_MANAGER_GROUPS_TITLEROW);
		        $templateSubContent->assign('CONTACTS_HEADING_CONTACTGROUP_MEMBERSHIPS', CONTACTS_HEADING_CONTACTGROUP_MEMBERSHIPS);
        	        $templateSubContent->assign('CONTACTS_TITLE_GROUP_NAME', CONTACTS_TITLE_GROUP_NAME);
                	$templateSubContent->assign('CONTACTS_TITLE_GROUP_NAME_SHORT', CONTACTS_TITLE_GROUP_NAME_SHORT);
                        $templateSubContent->assign('CONTACTS_TITLE_GROUP_VIEW_ONLY', CONTACTS_TITLE_GROUP_VIEW_ONLY);
	                $templateSubContent->assign('CONTACTS_TITLE_TIMEFRAME_NAME', CONTACTS_TITLE_TIMEFRAME_NAME);
        	        $content .= $templateSubContent->getHTML();
			$titlerow = 1; // Title has been added, continue.
		}
		$templateSubContent = new nwTemplate(TEMPLATE_CONTACT_MANAGER_GROUPS_ROW);
                $templateSubContent->assign('CONTACTS_GROUP_NAME', $row['name']);
                $templateSubContent->assign('CONTACTS_GROUP_NAME_SHORT', $row['name_short']);
                $templateSubContent->assign('CONTACTS_GROUP_VIEW_ONLY', ($row['view_only']==1? GENERIC_YES : GENERIC_NO));
		$templateSubContent->assign('CONTACTS_TIMEFRAME_NAME', $row['timeframe_name']);
		$content .= $templateSubContent->getHTML();
	}
	$templateContent->assign('CONTACTGROUPS', $content);

	// add user's assigned notifications
        $content = null;
        $titlerow = 0;
        foreach ($userNotificationsDirect as $row) {
                // Title row needed for table?
                if ($titlerow == 0) {
                        $templateSubContent = new nwTemplate(TEMPLATE_CONTACT_MANAGER_NOTIFICATIONS_TITLEROW);
		        $templateSubContent->assign('CONTACTS_HEADING_NOTIFICATION_MEMBERSHIPS', CONTACTS_HEADING_NOTIFICATION_MEMBERSHIPS);
                        $templateSubContent->assign('CONTACTS_TITLE_NOTIFICATION_NAME', CONTACTS_TITLE_NOTIFICATION_NAME);
                        $templateSubContent->assign('CONTACTS_TITLE_NOTIFICATION_ACTIVE', CONTACTS_TITLE_NOTIFICATION_ACTIVE);
                        $templateSubContent->assign('CONTACTS_TITLE_NOTIFICATION_NOTIFY_AFTER_TRIES', CONTACTS_TITLE_NOTIFICATION_NOTIFY_AFTER_TRIES);
                        $templateSubContent->assign('CONTACTS_TITLE_TIMEFRAME_NAME', CONTACTS_TITLE_TIMEFRAME_NAME);
                        $content .= $templateSubContent->getHTML();
                        $titlerow = 1; // Title has been added, continue.
                }
                $templateSubContent = new nwTemplate(TEMPLATE_CONTACT_MANAGER_NOTIFICATIONS_ROW);
                $templateSubContent->assign('CONTACTS_NOTIFICATION_NAME', $row['notification_name']);
                $templateSubContent->assign('CONTACTS_NOTIFICATION_ACTIVE', ($row['active']==1? GENERIC_YES : GENERIC_NO));
                $templateSubContent->assign('CONTACTS_NOTIFICATION_NOTIFY_AFTER_TRIES', $row['notify_after_tries']);
                $templateSubContent->assign('CONTACTS_TIMEFRAME_NAME', $row['timeframe_name']);
                $content .= $templateSubContent->getHTML();
        }
        $templateContent->assign('NOTIFICATIONS', $content);

        // add user's assigned notification escalations.
        $content = null;
        $titlerow = 0;
        foreach ($userEscalationsDirect as $row) {
                // Title row needed for table?
                if ($titlerow == 0) {
                        $templateSubContent = new nwTemplate(TEMPLATE_CONTACT_MANAGER_ESCALATIONS_TITLEROW);
                        $templateSubContent->assign('CONTACTS_HEADING_ESCALATION_MEMBERSHIPS', CONTACTS_HEADING_ESCALATION_MEMBERSHIPS);
                        $templateSubContent->assign('CONTACTS_TITLE_NOTIFICATION_NAME', CONTACTS_TITLE_NOTIFICATION_NAME);
                        $templateSubContent->assign('CONTACTS_TITLE_NOTIFICATION_ACTIVE', CONTACTS_TITLE_NOTIFICATION_ACTIVE);
                        $templateSubContent->assign('CONTACTS_TITLE_ESCALATION_NOTIFY_AFTER_TRIES', CONTACTS_TITLE_ESCALATION_NOTIFY_AFTER_TRIES);
                        $content .= $templateSubContent->getHTML();
                        $titlerow = 1; // Title has been added, continue.
                }
                $templateSubContent = new nwTemplate(TEMPLATE_CONTACT_MANAGER_ESCALATIONS_ROW);
                $templateSubContent->assign('CONTACTS_NOTIFICATION_NAME', $row['notification_name']);
                $templateSubContent->assign('CONTACTS_NOTIFICATION_ACTIVE', ($row['active']==1? GENERIC_YES : GENERIC_NO));
                $templateSubContent->assign('CONTACTS_ESCALATION_NOTIFY_AFTER_TRIES', $row['notify_after_tries']);
                $content .= $templateSubContent->getHTML();
        }
        $templateContent->assign('ESCALATIONS', $content);

/*
        // add user's assigned notificiations inherited through groups
        $content = null;
	$contactgroups = array();
        $titlerow = 0;
	$groupcounter = 0;
	if (!empty($userGroups)){
		foreach($userGroups as $row){
			if ($row['id']!=""){
				array_push($contactgroups, $row['id']);
				$groupcounter=$groupcounter+1;
			}
		}
		if ($groupcounter == 1){
			foreach ($contactgroups as $contactgroup){
				$contactgroups_to_query = $contactgroup;
			}
		} elseif ($groupcounter > 1) {
			$contactgroups_to_query = join(" or cg.id=", $contactgroups);
		}

		if ($groupcounter > 0){
			$userNotificationsInDirect = queryDB('select distinct n.id, n.notification_name, n.active, n.notify_after_tries, cg.name, cg.name_short, cg.view_only from notifications n
                                        left join notifications_to_contactgroups ncg on n.id=ncg.notification_id
                                        left join contactgroups cg on ncg.contactgroup_id=cg.id
WHERE (cg.id='.$contactgroups_to_query.')');
		}
	}
//	print"TITT TITT<br>";
//	var_dump($userNotificationsInDirect[$counter]);
        foreach ($userNotificationsInDirect as $row) {
		if ($userNotificationsInDirect['id']!=""){
        	        // Title row needed for table?
	                if ($titlerow == 0) {
                        	$templateSubContent = new nwTemplate(TEMPLATE_CONTACT_MANAGER_NOTIFICATIONS_TO_GROUPS_TITLEROW);
                	        $templateSubContent->assign('CONTACTS_HEADING_NOTIFICATION_TO_CONTACTGROUP_MEMBERSHIPS', CONTACTS_HEADING_NOTIFICATION_TO_CONTACTGROUP_MEMBERSHIPS);
        	                $templateSubContent->assign('CONTACTS_TITLE_NOTIFICATION_NAME', CONTACTS_TITLE_NOTIFICATION_NAME);
	                        $templateSubContent->assign('CONTACTS_TITLE_NOTIFICATION_ACTIVE', CONTACTS_TITLE_NOTIFICATION_ACTIVE);
                                $templateSubContent->assign('CONTACTS_TITLE_NOTIFICATION_NOTIFY_AFTER_TRIES', CONTACTS_TITLE_NOTIFICATION_NOTIFY_AFTER_TRIES);
                        	$templateSubContent->assign('CONTACTS_TITLE_GROUP_NAME', CONTACTS_TITLE_GROUP_NAME);
                	        $templateSubContent->assign('CONTACTS_TITLE_GROUP_VIEW_ONLY', CONTACTS_TITLE_GROUP_VIEW_ONLY);
        	                $templateSubContent->assign('CONTACTS_TITLE_TIMEFRAME_NAME', CONTACTS_TITLE_TIMEFRAME_NAME);
	                        $content .= $templateSubContent->getHTML();
                        	$titlerow = 1; // Title has been added, continue.
                	}
        	        $templateSubContent = new nwTemplate(TEMPLATE_CONTACT_MANAGER_NOTIFICATIONS_TO_GROUPS_ROW);
	                $templateSubContent->assign('CONTACTS_NOTIFICATION_NAME', $row['notification_name']);
                	$templateSubcontent->assign('CONTACTS_NOTIFICATION_ACTIVE', ($row['active']==1? GENERIC_YES : GENERIC_NO));
        	        $templateSubContent->assign('CONTACTS_NOTIFICATION_NOTIFY_AFTER_TRIES', $row['notify_after_tries']);
	                $templateSubContent->assign('CONTACTS_GROUP_NAME', $row['name']);
                	$templateSubContent->assign('CONTACTS_GROUP_VIEW_ONLY', $row['view_only']);
        	        $templateSubContent->assign('CONTACTS_TIMEFRAME_NAME', $row['timeframe_name']);
	                $content .= $templateSubContent->getHTML();
		}
	}
        $templateContent->assign('NOTIFICATIONS_FROM_GROUPS', $content);
*/

	if (empty($user)) {
		$templateContent->assign('CONTACTS_SUBMIT', CONTACTS_SUBMIT_ADD);
	} else {
		$templateContent->assign('CONTACTS_SUBMIT', CONTACTS_SUBMIT_UPDATE);
	}



	return $templateContent->getHTML();

}

?>
