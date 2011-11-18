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

	global $p, $message, $notifications;

	$templateContent = new nwTemplate(TEMPLATE_ADD_EDIT);

	// assign messages
	if (!empty($message)) $templateContent->assign('MESSAGE', $message);


	// assign labels
	$templateContent->assign('ADD_EDIT_OVERVIEW_LINK', ADD_EDIT_OVERVIEW_LINK);
	$templateContent->assign('HEADING_HOSTS_AND_SERVICES', ADD_EDIT_HEADING_HOSTS_AND_SERVICES);
        $templateContent->assign('ADD_EDIT_HEADING_NOTIFICATION_NAME', ADD_EDIT_HEADING_NOTIFICATION_NAME);
	$templateContent->assign('ADD_EDIT_HEADING_TIME', ADD_EDIT_HEADING_TIME);
	$templateContent->assign('ADD_EDIT_HEADING_OWNER', ADD_EDIT_HEADING_OWNER);
	$templateContent->assign('ADD_EDIT_OWNER', ADD_EDIT_OWNER);
        $templateContent->assign('ADD_EDIT_INCLUDE_RECIPIENTS', ADD_EDIT_INCLUDE_RECIPIENTS);
        $templateContent->assign('ADD_EDIT_EXCLUDE_RECIPIENTS', ADD_EDIT_EXCLUDE_RECIPIENTS);
        $templateContent->assign('ADD_EDIT_INCLUDE_SERVICEGROUPS', ADD_EDIT_INCLUDE_SERVICEGROUPS);
        $templateContent->assign('ADD_EDIT_EXCLUDE_SERVICEGROUPS', ADD_EDIT_EXCLUDE_SERVICEGROUPS);
	$templateContent->assign('ADD_EDIT_INCLUDE_HOSTGROUPS', ADD_EDIT_INCLUDE_HOSTGROUPS);
	$templateContent->assign('ADD_EDIT_EXCLUDE_HOSTGROUPS', ADD_EDIT_EXCLUDE_HOSTGROUPS);
	$templateContent->assign('ADD_EDIT_INCLUDE_HOSTS', ADD_EDIT_INCLUDE_HOSTS);
	$templateContent->assign('ADD_EDIT_EXCLUDE_HOSTS', ADD_EDIT_EXCLUDE_HOSTS);
	$templateContent->assign('ADD_EDIT_INCLUDE_SERVICES', ADD_EDIT_INCLUDE_SERVICES);
	$templateContent->assign('ADD_EDIT_EXCLUDE_SERVICES', ADD_EDIT_EXCLUDE_SERVICES);
        $templateContent->assign('ADD_EDIT_NOTIFICATION_NAME', ADD_EDIT_NOTIFICATION_NAME);
        $templateContent->assign('ADD_EDIT_NOTIFICATION_DESC', ADD_EDIT_NOTIFICATION_DESC);
	$templateContent->assign('ADD_EDIT_TIMEZONE', ADD_EDIT_TIMEZONE);
        $templateContent->assign('ADD_EDIT_TIMEFRAME', ADD_EDIT_TIMEFRAME);
	$templateContent->assign('ADD_EDIT_SUBMIT', ADD_EDIT_SUBMIT);

	// assign style to preview
	if ($notifications['preview_scroll']) {

		// init
		$style = null;

		// set width of preview window
		if (isset($notifications['preview_width'])) {
			if ($notifications['preview_width'] > 0) {
				$width = $notifications['preview_width'];
			} else {
				$width = 250;
			}
		}
		$style .= 'width:' . $width . 'px;';

		// set max height
		if (isset($notifications['preview_max_height'])) {
			if ($notifications['preview_max_height'] > 0) {
				$style .= 'max-height:' . $notifications['preview_max_height'] . 'px;';
			} 
		}

		// assign style
		$templateContent->assign('STYLE_HS_PREVIEW', ' style="overflow:auto;' . $style . '"');

	}


	// get info and assign defaults
	$id = (!isset($_GET['id'])) ? ((isset($_POST['id'])) ? $_POST['id'] : null) : $_GET['id'];
	$timezone_id = null;
	$timeframe_id = null;
	$notify_users = null;
	$notify_groups = null;
	$notify_by = null;
	$owner = null;
	$dbResult = null;

	if (!empty($id)) {

		$id_safe = prepareDBValue($id);

		$templateContent->assign('ID', $id);

		$dbResult = queryDB('select * from notifications where id=\'' . $id_safe . '\'');

		$templateContent->assign('ACTION', 'update');
		$templateContent->assign('HEADING', ADD_EDIT_HEADING_EDIT);

		$templateContent->assign('INCLUDE_RECIPIENTS', $dbResult[0]['recipients_include']);
		$templateContent->assign('EXCLUDE_RECIPIENTS', $dbResult[0]['recipients_exclude']);

                $templateContent->assign('INCLUDE_SERVICEGROUPS', $dbResult[0]['servicegroups_include']);
                $templateContent->assign('EXCLUDE_SERVICEGROUPS', $dbResult[0]['servicegroups_exclude']);

		$templateContent->assign('INCLUDE_HOSTGROUPS', $dbResult[0]['hostgroups_include']);
		$templateContent->assign('EXCLUDE_HOSTGROUPS', $dbResult[0]['hostgroups_exclude']);

		$templateContent->assign('INCLUDE_HOSTS', $dbResult[0]['hosts_include']);
		$templateContent->assign('EXCLUDE_HOSTS', $dbResult[0]['hosts_exclude']);

		$templateContent->assign('INCLUDE_SERVICES', $dbResult[0]['services_include']);
		$templateContent->assign('EXCLUDE_SERVICES', $dbResult[0]['services_exclude']);

                $templateContent->assign('NOTIFICATION_NAME', $dbResult[0]['notification_name']);
                $templateContent->assign('NOTIFICATION_DESCRIPTION', $dbResult[0]['notification_description']);

		// get notification users
		$dbSub = queryDB('select c.username from contacts c
							left join notifications_to_contacts nc on nc.contact_id=c.id
							where nc.notification_id=\'' . $id_safe . '\'
							order by c.username');
		if (is_array($dbSub)) {
			foreach($dbSub as $subRow) {
				$notify_users[] = $subRow['username'];
			}
		}

		// get notification groups
		$query = 'select cg.id from contactgroups cg
					left join notifications_to_contactgroups ncg on cg.id=ncg.contactgroup_id
					where ncg.notification_id=\'' . $id_safe . '\'';
		$dbSub = queryDB($query);
		if (is_array($dbSub)) {
			foreach($dbSub as $subRow) {
				$notify_groups[] = $subRow['id'];
			}
		}

		// get notification methods
		$dbSub = queryDB('select method_id from notifications_to_methods where notification_id=\'' . $id_safe . '\'');
		if (is_array($dbSub)) {
			foreach($dbSub as $subRow) {
				$notify_by[] = $subRow['method_id'];
			}
		}

	} else {

		$templateContent->assign('ACTION', 'add_new');
		$templateContent->assign('HEADING', ADD_EDIT_HEADING_NEW);

	}

		$timezone_id = $dbResult[0]['timezone_id'];
		if (!isset($timezone_id)) $timezone_id = getServerTimeZone();
        $templateContent->assign('TIMEFRAME_SELECT', htmlSelect('timeframe', getTimeFrames(), $dbResult[0]['timeframe_id']));
        $templateContent->assign('TIMEZONE_SELECT', htmlSelect('timezone', getTimeZone(), $timezone_id));

	if (empty($id) && !empty($_SESSION['user'])) {
		$templateContent->assign('OWNER_SELECT', $_SESSION['user'] . htmlInput('owner', 'hidden', $_SESSION['user']));
	} else {
		$templateContent->assign('OWNER_SELECT', htmlSelect('owner', getContacts(), $dbResult[0]['username']));
	}

	// BEGIN - assign content for contacts and methods
	// init
	$action = $p['action'];
	$content = '';


	$count = 1;
	if (!empty($id)) {
		// get escalations
		$query = sprintf(
			'select id,on_ok,on_warning,on_critical,on_unknown,on_host_up,on_host_unreachable,on_host_down,on_type_problem,on_type_recovery,on_type_flappingstart,on_type_flappingstop,on_type_flappingdisabled,on_type_downtimestart,on_type_downtimeend,on_type_downtimecancelled,on_type_acknowledgement,on_type_custom,notify_after_tries
				from escalations_contacts
				where notification_id=\'%s\'
				order by notify_after_tries asc',
				$id_safe
		);
		$escalations = queryDB($query);


		// get counter for loop
		$count = count($escalations) + 1;
		if ($action == 'add_escalation') $count++;
	}
	$last = $count - 1;


	// assign content
	for ($x = 0; $x < $count; $x++) {

		$templateSubContent = new nwTemplate(TEMPLATE_ADD_EDIT_CONTACTS_METHODS);

		$formArray = ($action != 'add') ? "[$x]" : null;


		// init
		if ($x) {
			$notify_users = array();
			$notify_groups = array();
			$notify_by = array();
			$dbResult = array();
		}
	
		// assign 'let notifier handle'
		if (!$x) {
			$templateSubSubContent = new nwTemplate(TEMPLATE_ADD_EDIT_LET_NOTIFIER_HANDLE);
			$templateSubSubContent->assign('ADD_EDIT_LET_NOTIFIER_HANDLE', ADD_EDIT_LET_NOTIFIER_HANDLE);
			// $templateSubSubContent->assign('ADD_EDIT_RELOOP_DELAY', ADD_EDIT_RELOOP_DELAY);
			$templateSubSubContent->assign('ADD_EDIT_ROLLOVER', ADD_EDIT_ROLLOVER);
			$templateSubSubContent->assign('CHECKED_LET_NOTIFIER_HANDLE', ($dbResult[0]['let_notifier_handle']==1)?' checked="checked" ':'');
			$templateSubSubContent->assign('CHECKED_ROLLOVER', ($dbResult[0]['rollover']==1)?' checked="checked" ':'');
			// $templateSubSubContent->assign('RELOOP_DELAY', $dbResult[0]['reloop_delay']);
			$templateSubContent->assign('LET_NOTIFIER_HANDLE', $templateSubSubContent->getHTML());
		}


		// get escalation data
		if ($x && (($x != $last && $action == 'add_escalation') || $action != 'add_escalation')) {

			// get db result from escalations
			$dbResult[$x] = $escalations[$x-1];

			// get contacts
			$query = sprintf(
				'select distinct c.username from contacts c
					left join escalations_contacts_to_contacts ecc on ecc.contacts_id=c.id
					left join escalations_contacts ec on ec.id=ecc.escalation_contacts_id
					where ec.id=\'%s\'',
					$dbResult[$x]['id']
			);
			$dbResult_tmp = queryDB($query);

			$notify_users = array();
			foreach($dbResult_tmp as $row) {
				$notify_users[] = $row['username'];
			}

			// get contact groups
			$query = sprintf(
				'select distinct eccg.contactgroup_id from escalations_contacts_to_contactgroups eccg
					left join escalations_contacts ec on ec.id=eccg.escalation_contacts_id
					where ec.id=\'%s\'',
					$dbResult[$x]['id']
			);
			$dbResult_tmp = queryDB($query);

			$notify_groups = array();
			foreach($dbResult_tmp as $row) {
				$notify_groups[] = $row['contactgroup_id'];
			}

			// get notification methods
			$query = sprintf(
				'select distinct ecm.method_id from escalations_contacts_to_methods ecm
					left join escalations_contacts ec on ec.id=ecm.escalation_contacts_id
					where ec.id=\'%s\'',
					$dbResult[$x]['id']
			);
			$dbResult_tmp = queryDB($query);

			$notify_by = array();
			foreach($dbResult_tmp as $row) {
				$notify_by[] = $row['method_id'];
			}

		}



		if ($x && $action != 'add' && !($x == $last && $action == 'add_escalation')) {

			$button = htmlInput(
				'remove_escalation' . $formArray,
				'submit', ADD_EDIT_BUTTON_REMOVE_ESCALATION,
				'onclick="if(confirm(\'' . ADD_EDIT_CONFIRM_REMOVE_ESCALATION . '\')){setValue(\'eid\',\'' . $dbResult[$x]['id'] . '\');setValue(\'action\',\'remove_escalation\');}else{return false;}"'
			);

			$templateSubContent->assign('BUTTON_REMOVE_ESCALATION', $button);

		} else {

			$templateSubContent->assign('BUTTON_REMOVE_ESCALATION', '&nbsp;');

		}


		if ($x == $last && $action != 'add' && $action != 'add_escalation') {

			$button = '&nbsp;';
			$button .= htmlInput(
				'add_escalation',
				'submit', ADD_EDIT_BUTTON_ADD_ESCALATION,
				'onclick="if(confirm(\'' . ADD_EDIT_CONFIRM_ADD_ESCALATION . '\')){setValue(\'action\',\'add_escalation\');}else{return false;}"'
			);

			$templateSubContent->assign('BUTTON_ADD_ESCALATION', $button);

		} else {

			$templateSubContent->assign('BUTTON_ADD_ESCALATION', '&nbsp;');

		}


		$templateSubContent->assign('ESCALATION_COUNT', $x);

		$templateSubContent->assign('ADD_EDIT_NOTIFY_AFTER_TRIES', ADD_EDIT_NOTIFY_AFTER_TRIES);
		$templateSubContent->assign('NOTIFY_AFTER_TRIES', $dbResult[$x]['notify_after_tries']);
		$templateSubContent->assign('ADD_EDIT_NUM_NOTIFICATIONS', ADD_EDIT_NUM_NOTIFICATIONS);
		$templateSubContent->assign('ADD_EDIT_HEADING_CONTACTS_METHODS', ADD_EDIT_HEADING_CONTACTS_METHODS);
		$templateSubContent->assign('ADD_EDIT_NOTIFY_USERS', ADD_EDIT_NOTIFY_USERS);
		$templateSubContent->assign('ADD_EDIT_NOTIFY_GROUPS', ADD_EDIT_NOTIFY_GROUPS);
		$templateSubContent->assign('ADD_EDIT_NOTIFY_BY', ADD_EDIT_NOTIFY_BY);
		$templateSubContent->assign('ADD_EDIT_NOTIFY_ON', ADD_EDIT_NOTIFY_ON);

                $templateSubContent->assign('NOTIFY_USERS_SELECT', htmlSelect('notify_users' . $formArray . '[]', getContacts(), $notify_users, 'size="5" multiple="multiple"'));
		$templateSubContent->assign('NOTIFY_GROUPS_SELECT', htmlSelect('notify_groups' . $formArray . '[]', getContactGroups(), $notify_groups, 'size="5" multiple="multiple"'));

		$templateSubContent->assign('NOTIFY_BY_SELECT', htmlSelect('notify_by' . $formArray . '[]', getNotificationMethods(), $notify_by, 'size="5" multiple="multiple"'));

		$templateSubContent->assign('CHECKED_NOTIFY_OK', ($dbResult[$x]['on_ok']=='1') ? ' checked="checked"' : '' );
		$templateSubContent->assign('CHECKED_NOTIFY_WARNING', ($dbResult[$x]['on_warning']=='1') ? ' checked="checked"' : '' );
                $templateSubContent->assign('CHECKED_NOTIFY_UNKNOWN', ($dbResult[$x]['on_unknown']=='1') ? ' checked="checked"' : '' );
                $templateSubContent->assign('CHECKED_NOTIFY_HOST_UNREACHABLE', ($dbResult[$x]['on_host_unreachable']=='1') ? ' checked="checked"' : '' );
                $templateSubContent->assign('CHECKED_NOTIFY_CRITICAL', ($dbResult[$x]['on_critical']=='1') ? ' checked="checked"' : '' );
                $templateSubContent->assign('CHECKED_NOTIFY_HOST_UP', ($dbResult[$x]['on_host_up']=='1') ? ' checked="checked"' : '' );
                $templateSubContent->assign('CHECKED_NOTIFY_HOST_DOWN', ($dbResult[$x]['on_host_down']=='1') ? ' checked="checked"' : '' );

                $templateSubContent->assign('CHECKED_NOTIFY_TYPE_PROBLEM', ($dbResult[$x]['on_type_problem']=='1') ? ' checked="checked"' : '' );
                $templateSubContent->assign('CHECKED_NOTIFY_TYPE_RECOVERY', ($dbResult[$x]['on_type_recovery']=='1') ? ' checked="checked"' : '' );
                $templateSubContent->assign('CHECKED_NOTIFY_TYPE_FLAPPINGSTART', ($dbResult[$x]['on_type_flappingstart']=='1') ? ' checked="checked"' : '' );
                $templateSubContent->assign('CHECKED_NOTIFY_TYPE_FLAPPINGSTOP', ($dbResult[$x]['on_type_flappingstop']=='1') ? ' checked="checked"' : '' );
                $templateSubContent->assign('CHECKED_NOTIFY_TYPE_FLAPPINGDISABLED', ($dbResult[$x]['on_type_flappingdisabled']=='1') ? ' checked="checked"' : '' );
                $templateSubContent->assign('CHECKED_NOTIFY_TYPE_DOWNTIMESTART', ($dbResult[$x]['on_type_downtimestart']=='1') ? ' checked="checked"' : '' );
                $templateSubContent->assign('CHECKED_NOTIFY_TYPE_DOWNTIMEEND', ($dbResult[$x]['on_type_downtimeend']=='1') ? ' checked="checked"' : '' );
                $templateSubContent->assign('CHECKED_NOTIFY_TYPE_DOWNTIMECANCELLED', ($dbResult[$x]['on_type_downtimecancelled']=='1') ? ' checked="checked"' : '' );
                $templateSubContent->assign('CHECKED_NOTIFY_TYPE_ACKNOWLEDGEMENT', ($dbResult[$x]['on_type_acknowledgement']=='1') ? ' checked="checked"' : '' );
		$templateSubContent->assign('CHECKED_NOTIFY_TYPE_CUSTOM', ($dbResult[$x]['on_type_custom']==1)?' checked="checked" ':'');

		$templateSubContent->assign('ARRAY_ITEM', $formArray);

		$content .= $templateSubContent->getHTML();

	}

	$templateContent->assign('CONTACTS_METHODS', $content);
	// END - assign content for contacts and methods


	// BEGIN - generate content for asynchronous-preview call
	if ($notifications['host_service_preview']) {

                $templateContent->assign('ONCHANGE_RECIPIENTS_INCLUDE', ' onkeyup="update_preview(\'r\',\'i\');"');
                $templateContent->assign('ONCHANGE_RECIPIENTS_EXCLUDE', ' onkeyup="update_preview(\'r\',\'e\');"');

                $templateContent->assign('ONCHANGE_SERVICEGROUPS_INCLUDE', ' onkeyup="update_preview(\'sg\',\'i\');"');
                $templateContent->assign('ONCHANGE_SERVICEGROUPS_EXCLUDE', ' onkeyup="update_preview(\'sg\',\'e\');"');

		$templateContent->assign('ONCHANGE_HOSTGROUPS_INCLUDE', ' onkeyup="update_preview(\'hg\',\'i\');"');
		$templateContent->assign('ONCHANGE_HOSTGROUPS_EXCLUDE', ' onkeyup="update_preview(\'hg\',\'e\');"');

		$templateContent->assign('ONCHANGE_HOSTS_INCLUDE', ' onkeyup="update_preview(\'h\',\'i\');"');
		$templateContent->assign('ONCHANGE_HOSTS_EXCLUDE', ' onkeyup="update_preview(\'h\',\'e\');"');

		$templateContent->assign('ONCHANGE_SERVICES_INCLUDE', ' onkeyup="update_preview(\'s\',\'i\');"');
		$templateContent->assign('ONCHANGE_SERVICES_EXCLUDE', ' onkeyup="update_preview(\'s\',\'e\');"');

	}
	// END - generate content for asynchronous-preview call
	

	return $templateContent->getHTML();

}

?>
