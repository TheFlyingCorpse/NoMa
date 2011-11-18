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

	global $p, $contactgroups, $message;

	// security
	if ($contactgroups['admin_only'] && !isAdmin()) return null;

	// set some sane defaults
	$groupNotificationsDirect = array();
	$groupEscalationsDirect = array();
	
	// get contactgroup to edit
	$contactgroup = ((isset($p['contactgroup'])) ? $p['contactgroup'] : null);
	if (empty($contactgroup)) $contactgroup = null;

	$templateContent = new nwTemplate(TEMPLATE_CONTACTGROUP_MANAGER);


	// assign statics
	$templateContent->assign('CONTACTGROUPS_OVERVIEW_LINK', CONTACTGROUPS_OVERVIEW_LINK);
	$templateContent->assign('CONTACTGROUPS_HEADING', CONTACTGROUPS_HEADING);
	$templateContent->assign('CONTACTGROUPS_HEADING_EDIT', CONTACTGROUPS_HEADING_EDIT);
	$templateContent->assign('CONTACTGROUPS_HEADING_SELECT', CONTACTGROUPS_HEADING_SELECT);
	$templateContent->assign('CONTACTGROUPS_EDIT_GROUPS', CONTACTGROUPS_EDIT_GROUPS);
	$templateContent->assign('CONTACTGROUPS_EDIT_BUTTON', CONTACTGROUPS_EDIT_BUTTON);

	// add message
	if (!empty($message)) $templateContent->assign('MESSAGE', $message);


	// assign contactgroup id
	$id = $contactgroup;
	$templateContent->assign('ID', $id);

	// assign select fields for contactgroups and contacts
	$contactgroups = getContactGroups();
	$templateContent->assign('CONTACTGROUPS_EDIT_GROUPS_SELECT', htmlSelect('contactgroup', $contactgroups, $id,  'onchange="document.contact_form.edit.click();"', array('', CONTACTGROUPS_SELECT_GROUP_NEW)));

	// add form content
	if (!empty($id)) {
		$groupData = getContactGroupById($id);

		$templateSubContent = new nwTemplate(TEMPLATE_CONTACTGROUP_MANAGER_EDIT);
		$templateSubContent->assign('CONTACTGROUPS_HEADING_EDIT', CONTACTGROUPS_HEADING_EDIT);
		$templateSubContent->assign('CONTACTGROUPS_EDIT_NAME_SHORT', CONTACTGROUPS_EDIT_NAME_SHORT);
		$templateSubContent->assign('CONTACTGROUPS_EDIT_NAME', CONTACTGROUPS_EDIT_NAME);
		$templateSubContent->assign('CONTACTGROUPS_EDIT_USERS', CONTACTGROUPS_EDIT_USERS);
		$templateSubContent->assign('CONTACTGROUPS_SUBMIT_CHANGES_BUTTON', CONTACTGROUPS_SUBMIT_CHANGES_BUTTON);
		$templateSubContent->assign('CONTACTGROUPS_VIEW_ONLY', CONTACTGROUPS_VIEW_ONLY);
		$templateSubContent->assign('CONTACTGROUP_NAME_SHORT', $groupData['name_short']);
		$templateSubContent->assign('CONTACTGROUP_NAME', $groupData['name']);
	        $templateSubContent->assign('CONTACTGROUPS_TIMEFRAME', CONTACTGROUPS_TIMEFRAME);
                $templateSubContent->assign('CONTACTGROUPS_TIMEZONE', CONTACTGROUPS_TIMEZONE);
       		if (!isset($groupData['timeframe_id'])) $groupData['timeframe_id'] = null;
	        $templateSubContent->assign('TIMEFRAME_SELECT', htmlSelect('timeframe', getTimeFrames(), $groupData['timeframe_id']));
                if (!isset($groupData['timezone_id'])) $groupData['timezone_id'] = getServerTimeZone();
                $templateSubContent->assign('TIMEZONE_SELECT', htmlSelect('timezone', getTimeZone(), $groupData['timezone_id']));
		$templateSubContent->assign('CONTACTGROUPS_EDIT_USERS_SELECT', htmlSelect('contacts[]', getContacts(), getContactGroupMembers($contactgroup), 'size="5" multiple="multiple"'));
		$templateSubContent->assign('VIEW_ONLY_CHECKED', ($groupData['view_only'] == '1') ? ' checked="true"' : null);

                $groupNotificationsDirect = queryDB('SELECT distinct n.notification_name, n.active, n.notify_after_tries, tf.timeframe_name FROM notifications as n, notifications_to_contactgroups as ncg, timeframes as tf WHERE n.timeframe_id=tf.id AND n.id=ncg.notification_id AND ncg.contactgroup_id=\'' . $groupData['id'] . '\'');
                $groupEscalationsDirect = queryDB('SELECT distinct n.notification_name, n.active, ec.notify_after_tries FROM notifications as n, escalations_contacts as ec, escalations_contacts_to_contactgroups as eccg WHERE ec.id=eccg.escalation_contacts_id AND n.id=ec.notification_id AND eccg.contactgroup_id=\'' . $groupData['id'] . '\'');

	        $templateSubContent->assign('LINKED_OBJECTS', LINKED_OBJECTS);
		$templateSubContent->assign('LINKED_OBJECTS_SHOW', LINKED_OBJECTS_SHOW);
		$templateSubContent->assign('LINKED_OBJECTS_HIDE', LINKED_OBJECTS_HIDE);

		// add group's assigned notifications
		$content = null;
		$titlerow = 0;
		foreach ($groupNotificationsDirect as $row) {
				// Title row needed for table?
				if ($titlerow == 0) {
						$templateSubSubContent = new nwTemplate(TEMPLATE_CONTACTGROUP_MANAGER_NOTIFICATIONS_TITLEROW);
						$templateSubSubContent->assign('CONTACTGROUPS_HEADING_NOTIFICATION_MEMBERSHIPS', CONTACTGROUPS_HEADING_NOTIFICATION_MEMBERSHIPS);
						$templateSubSubContent->assign('CONTACTGROUPS_TITLE_NOTIFICATION_NAME', CONTACTGROUPS_TITLE_NOTIFICATION_NAME);
						$templateSubSubContent->assign('CONTACTGROUPS_TITLE_NOTIFICATION_ACTIVE', CONTACTGROUPS_TITLE_NOTIFICATION_ACTIVE);
						$templateSubSubContent->assign('CONTACTGROUPS_TITLE_NOTIFICATION_NOTIFY_AFTER_TRIES', CONTACTGROUPS_TITLE_NOTIFICATION_NOTIFY_AFTER_TRIES);
						$templateSubSubContent->assign('CONTACTGROUPS_TITLE_TIMEFRAME_NAME', CONTACTGROUPS_TITLE_TIMEFRAME_NAME);
						$content .= $templateSubSubContent->getHTML();
						$titlerow = 1; // Title has been added, continue.
				}
				$templateSubSubContent = new nwTemplate(TEMPLATE_CONTACTGROUP_MANAGER_NOTIFICATIONS_ROW);
				$templateSubSubContent->assign('CONTACTGROUPS_NOTIFICATION_NAME', $row['notification_name']);
				$templateSubSubContent->assign('CONTACTGROUPS_NOTIFICATION_ACTIVE', ($row['active']==1? GENERIC_YES : GENERIC_NO));
				$templateSubSubContent->assign('CONTACTGROUPS_NOTIFICATION_NOTIFY_AFTER_TRIES', $row['notify_after_tries']);
				$templateSubSubContent->assign('CONTACTGROUPS_TIMEFRAME_NAME', $row['timeframe_name']);
				$content .= $templateSubSubContent->getHTML();
		}
		$templateSubContent->assign('NOTIFICATIONS', $content);

		// add group's assigned notification escalations.
		$content = null;
		$titlerow = 0;
		foreach ($groupEscalationsDirect as $row) {
				// Title row needed for table?
				if ($titlerow == 0) {
						$templateSubSubContent = new nwTemplate(TEMPLATE_CONTACTGROUP_MANAGER_ESCALATIONS_TITLEROW);
						$templateSubSubContent->assign('CONTACTGROUPS_HEADING_ESCALATION_MEMBERSHIPS', CONTACTGROUPS_HEADING_ESCALATION_MEMBERSHIPS);
						$templateSubSubContent->assign('CONTACTGROUPS_TITLE_NOTIFICATION_NAME', CONTACTGROUPS_TITLE_NOTIFICATION_NAME);
						$templateSubSubContent->assign('CONTACTGROUPS_TITLE_NOTIFICATION_ACTIVE', CONTACTGROUPS_TITLE_NOTIFICATION_ACTIVE);
						$templateSubSubContent->assign('CONTACTGROUPS_TITLE_ESCALATION_NOTIFY_AFTER_TRIES', CONTACTGROUPS_TITLE_ESCALATION_NOTIFY_AFTER_TRIES);
						$content .= $templateSubSubContent->getHTML();
						$titlerow = 1; // Title has been added, continue.
				}
				$templateSubSubContent = new nwTemplate(TEMPLATE_CONTACTGROUP_MANAGER_ESCALATIONS_ROW);
				$templateSubSubContent->assign('CONTACTGROUPS_NOTIFICATION_NAME', $row['notification_name']);
				$templateSubSubContent->assign('CONTACTGROUPS_NOTIFICATION_ACTIVE', ($row['active']==1? GENERIC_YES : GENERIC_NO));
				$templateSubSubContent->assign('CONTACTGROUPS_ESCALATION_NOTIFY_AFTER_TRIES', $row['notify_after_tries']);
				$content .= $templateSubSubContent->getHTML();
		}
		$templateSubContent->assign('ESCALATIONS', $content);

		$templateSubContentDelete = new nwTemplate(TEMPLATE_CONTACTGROUP_MANAGER_DELETE);
		$templateSubContentDelete->assign('CONTACTGROUPS_DELETE_BUTTON', CONTACTGROUPS_DELETE_BUTTON);
		$templateSubContentDelete->assign('CONTACTGROUP_CONFIRM_DEL', CONTACTGROUP_CONFIRM_DEL);
		$templateContent->assign('CONTACTGROUPS_DELETE_BUTTON', $templateSubContentDelete->getHTML());
	} else {
		$templateSubContent = new nwTemplate(TEMPLATE_CONTACTGROUP_MANAGER_ADD);
		$templateSubContent->assign('CONTACTGROUPS_HEADING_ADD', CONTACTGROUPS_HEADING_ADD);
		$templateSubContent->assign('CONTACTGROUPS_ADD_NAME_SHORT', CONTACTGROUPS_ADD_NAME_SHORT);
		$templateSubContent->assign('CONTACTGROUPS_ADD_NAME', CONTACTGROUPS_ADD_NAME);
                $templateSubContent->assign('CONTACTGROUPS_TIMEFRAME', CONTACTGROUPS_TIMEFRAME);
                $templateSubContent->assign('CONTACTGROUPS_TIMEZONE', CONTACTGROUPS_TIMEZONE);
                if (!isset($groupData['timeframe_id'])) $groupData['timeframe_id'] = null;
                $templateSubContent->assign('TIMEFRAME_SELECT', htmlSelect('timeframe', getTimeFrames(), $groupData['timeframe_id']));
                if (!isset($groupData['timezone_id'])) $groupData['timezone_id'] = getServerTimeZone();
                $templateSubContent->assign('TIMEZONE_SELECT', htmlSelect('timezone', getTimeZone(), $groupData['timezone_id']));
		$templateSubContent->assign('CONTACTGROUPS_VIEW_ONLY', CONTACTGROUPS_VIEW_ONLY);
		$templateSubContent->assign('CONTACTGROUPS_ADD_BUTTON', CONTACTGROUPS_ADD_BUTTON);

	}

	$templateContent->assign('CONTACTGROUPS_MAIN_CONTENT', $templateSubContent->getHTML());

	return $templateContent->getHTML();

}


?>
