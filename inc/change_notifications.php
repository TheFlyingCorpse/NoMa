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
 * addNotification - adds a new notification
 *
 * @param		array		$p		posted data for new notification
 * @return							boolean value (false on error)
 */
function addNotification ($p) {

	// get gloabl config
	global $notifications;


	// prepare data
	$owner = prepareDBValue($p['owner']);
        $recipients_include = prepareDBValue($p['recipients_include']);
        $recipients_exclude = prepareDBValue($p['recipients_exclude']);
        $servicegroups_include = prepareDBValue($p['servicegroups_include']);
        $servicegroups_exclude = prepareDBValue($p['servicegroups_exclude']);
	$hostgroups_include = prepareDBValue($p['hostgroups_include']);
	$hostgroups_exclude = prepareDBValue($p['hostgroups_exclude']);
	$hosts_include = prepareDBValue($p['hosts_include']);
	$hosts_exclude = prepareDBValue($p['hosts_exclude']);
	$services_include = prepareDBValue($p['services_include']);
	$services_exclude = prepareDBValue($p['services_exclude']);
	$notify_after_tries = prepareDBValue($p['notify_after_tries']);
	$notify_on_ok = (($p['notify_on_ok'] == 'on') ? '1' : '0');
	$notify_on_warning = (($p['notify_on_warning'] == 'on') ? '1' : '0');
	$notify_on_unknown = (($p['notify_on_unknown'] == 'on') ? '1' : '0');
	$notify_on_host_unreachable = (($p['notify_on_host_unreachable'] == 'on') ? '1' : '0');
	$notify_on_critical = (($p['notify_on_critical'] == 'on') ? '1' : '0');
	$notify_on_host_up = (($p['notify_on_host_up'] == 'on') ? '1' : '0');
	$notify_on_host_down = (($p['notify_on_host_down'] == 'on') ? '1' : '0');
	$notify_on_type_problem = (($p['notify_on_type_problem'][$x] == 'on') ? '1' : '0');
	$notify_on_type_recovery = (($p['notify_on_type_recovery'][$x] == 'on') ? '1' : '0');
	$notify_on_type_flappingstart = (($p['notify_on_type_flappingstart'][$x] == 'on') ? '1' : '0');
	$notify_on_type_flappingstop = (($p['notify_on_type_flappingstop'][$x] == 'on') ? '1' : '0');
	$notify_on_type_flappingdisabled = (($p['notify_on_type_flappingdisabled'][$x] == 'on') ? '1' : '0');
	$notify_on_type_downtimestart = (($p['notify_on_type_downtimestart'][$x] == 'on') ? '1' : '0');
	$notify_on_type_downtimeend = (($p['notify_on_type_downtimeend'][$x] == 'on') ? '1' : '0');
	$notify_on_type_downtimecancelled = (($p['notify_on_type_downtimecancelled'][$x] == 'on') ? '1' : '0');
	$notify_on_type_acknowledgement = (($p['notify_on_type_acknowledgement'][$x] == 'on') ? '1' : '0');
	$notify_on_type_custom = (($p['notify_on_type_custom'][$x] == 'on') ? '1' : '0');
        $timeframe_id = prepareDBValue($p['timeframe']);
        $timezone_id = prepareDBValue($p['timezone']);
	$let_notifier_handle = ($p['let_notifier_handle']);
	$rollover = ($p['rollover']);


	// perform securicy checks
	if (!checkUser($p['owner'])) return false;


	// check whether notification exists
		$query = sprintf(
		'select id from notifications
			where active=0 and username=\'%s\' and timeframe_id=\'%s\' and timezone_id=\'%s\' and recipients_include=\'%s\' and recipients_exclude=\'%s\' and hostgroups_include=\'%s\' and hostgroups_exclude=\'%s\' and hosts_include=\'%s\' and hosts_exclude=\'%s\'  and servicegroups_include=\'%s\' and servicegroups_exclude=\'%s\' and services_include=\'%s\' and services_exclude=\'%s\' and notify_after_tries=\'%s\' and on_ok=\'%s\' and on_warning=\'%s\' and on_unknown=\'%s\' and on_host_unreachable=\'%s\' and on_critical=\'%s\' and on_host_up=\'%s\' and on_host_down=\'%s\' and on_type_problem=\'%s\' and on_type_recovery=\'%s\' and on_type_flappingstart=\'%s\' and on_type_flappingstop=\'%s\' and on_type_flappingdisabled=\'%s\' and on_type_downtimestart=\'%s\' and on_type_downtimeend=\'%s\' and on_type_downtimecancelled=\'%s\' and on_type_acknowledgement=\'%s\' and on_type_custom=\'%s\'',
		$owner,
		$timeframe_id,
		$timezone_id,
		$recipients_include,
		$recipients_exclude,
		$hostgroups_include,
		$hostgroups_exclude,
		$hosts_include,
		$hosts_exclude,
		$servicegroups_include,
		$servicegroups_exclude,
		$services_include,
		$services_exclude,
		$notify_after_tries,
		$notify_on_ok,
		$notify_on_warning,
		$notify_on_unknown,
		$notify_on_host_unreachable,
		$notify_on_critical,
		$notify_on_host_up,
		$notify_on_host_down,
		$notify_on_type_problem,
		$notify_on_type_recovery,
		$notify_on_type_flappingstart,
		$notify_on_type_flappingstop,
		$notify_on_type_flappingdisabled,
		$notify_on_type_downtimestart,
		$notify_on_type_downtimeend,
		$notify_on_type_downtimecancelled,
		$notify_on_type_acknowledgement,
		$notify_on_type_custom
	);
	$dbResult = queryDB($query);
	if (count($dbResult)) return false;
	

	// add notification
	$query = sprintf(
		'insert into notifications
			(active,username,timeframe_id,timezone_id,recipients_include,recipients_exclude,hostgroups_include,hostgroups_exclude,hosts_include,hosts_exclude,servicegroups_include,servicegroups_exclude,services_include,services_exclude,notify_after_tries,on_ok,on_warning,on_unknown,on_host_unreachable,on_critical,on_host_up,on_host_down,on_type_problem,on_type_recovery,on_type_flappingstart,on_type_flappingstop,on_type_flappingdisabled,on_type_downtimestart,on_type_downtimeend,on_type_downtimecancelled,on_type_acknowledgement,on_type_custom,let_notifier_handle,rollover)
			values (\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\')',
		'0',
		$owner,
                $timeframe_id,
                $timezone_id,
		$recipients_include,
		$recipients_exclude,
		$hostgroups_include,
		$hostgroups_exclude,
		$hosts_include,
		$hosts_exclude,
                $servicegroups_include,
                $servicegroups_exclude,
		$services_include,
		$services_exclude,
		$notify_after_tries,
		$notify_on_ok,
		$notify_on_warning,
		$notify_on_unknown,
		$notify_on_host_unreachable,
		$notify_on_critical,
		$notify_on_host_up,
		$notify_on_host_down,
		$notify_on_type_problem,
                $notify_on_type_recovery,
                $notify_on_type_flappingstart,
                $notify_on_type_flappingstop,
                $notify_on_type_flappingdisabled,
                $notify_on_type_downtimestart,
                $notify_on_type_downtimeend,
                $notify_on_type_downtimecancelled,
                $notify_on_type_acknowledgement,
                $notify_on_type_custom,
		$let_notifier_handle,
		$rollover
	);
	queryDB($query);

	// get new id
	$query = sprintf(
		'select id from notifications
			where active=\'0\' and timeframe_id=\'%s\' and timezone_id=\'%s\' and username=\'%s\' and recipients_include=\'%s\' and recipients_exclude=\'%s\' and hostgroups_include=\'%s\' and hostgroups_exclude=\'%s\' and  hosts_include=\'%s\' and hosts_exclude=\'%s\' and servicegroups_include=\'%s\' and servicegroups_exclude=\'%s\' and services_include=\'%s\' and services_exclude=\'%s\' and notify_after_tries=\'%s\' and on_ok=\'%s\' and on_warning=\'%s\' and on_unknown=\'%s\' and on_host_unreachable=\'%s\' and on_critical=\'%s\' and on_host_up=\'%s\' and on_host_down=\'%s\' and on_type_problem=\'%s\' and on_type_recovery=\'%s\' and on_type_flappingstart=\'%s\' and on_type_flappingstop=\'%s\' and on_type_flappingdisabled=\'%s\' and on_type_downtimestart=\'%s\' and on_type_downtimeend=\'%s\' and on_type_downtimecancelled=\'%s\' and on_type_acknowledgement=\'%s\' and on_type_custom=\'%s\'',
		$owner,
                $timeframe_id,
                $timezone_id,
		$recipients_include,
		$recipients_exclude,
		$hostgroups_include,
		$hostgroups_exclude,
		$hosts_include,
		$hosts_exclude,
                $servicegroups_include,
                $servicegroups_exclude,
		$services_include,
		$services_exclude,
		$notify_after_tries,
		$notify_on_ok,
		$notify_on_warning,
		$notify_on_unknown,
		$notify_on_host_unreachable,
		$notify_on_critical,
		$notify_on_host_up,
		$notify_on_host_down,
                $notify_on_type_problem,
                $notify_on_type_recovery,
                $notify_on_type_flappingstart,
                $notify_on_type_flappingstop,
                $notify_on_type_flappingdisabled,
                $notify_on_type_downtimestart,
                $notify_on_type_downtimeend,
                $notify_on_type_downtimecancelled,
                $notify_on_type_acknowledgement,
                $notify_on_type_custom
	);
	$dbResult = queryDB($query);
	$id = $dbResult[0]['id'];

	if (!$id) return false;


	// get notification users' usernames and add them
	// get user IDs
	$query = 'select id from contacts where ';
	$sep = null;

	// add owner to notifications list, if configured
	if ($notifications['add_owner'] === true) {
		if (is_array($p['notify_users']) === false) {
			$p['notify_users'][] = $p['owner'];
		} elseif (in_array($p['owner'], $p['notify_users']) === false) {
			$p['notify_users'][] = $p['owner'];
		}
	}

	if (isset($p['notify_users']) && is_array($p['notify_users'])) {

		foreach ($p['notify_users'] as $username) {
			if (!empty($username)) {
				$query .= sprintf('%susername=\'%s\'', $sep, prepareDBValue($username));
				if (!$sep) $sep = ' or ';
			}
		}

		$dbResult = queryDB($query);

		// add user IDs
		$query = 'insert into notifications_to_contacts (notification_id,contact_id) values ';
		$sep = null;
		foreach ($dbResult as $row) {
			if (!empty($row['id'])) {
				$query .= sprintf('%s(%s,%s)', $sep, $id, $row['id']);
				if (!$sep) $sep = ',';
			}
		}
		queryDB($query);

	}

	// store contactgroups
	if (isset($p['notify_groups']) && is_array($p['notify_groups'])) {

		$contactgroups = null;
		$sep = null;

		foreach ($p['notify_groups'] as $group) {
			$contactgroups .= $sep . '(\'' . $id . '\',\'' . prepareDBValue($group) . '\')';
			if(!$sep) $sep = ',';
		}

		queryDB('insert into notifications_to_contactgroups values ' . $contactgroups);

	}


	// add notification methods
	if (isset($p['notify_by']) && is_array($p['notify_by'])) {

		$query = 'insert into notifications_to_methods (notification_id,method_id) values ';
		$sep = null;

		foreach ($p['notify_by'] as $methodID) {
			if (!empty($methodID)) {
				$query .= sprintf('%s(%s,%s)', $sep, $id, prepareDBValue($methodID));
				if (!$sep) $sep = ',';
			}
		}

		queryDB($query);

	}

	return true;

}




/**
 * updateNotification - updates an existing notification
 *
 * @param		array		$p		posted data for notification update
 * @return							boolean value (false on error)
 */
function updateNotification ($p) {

	// get global configuration
	global $notifications;


	// prepare data
	$id = prepareDBValue($p['id']);
	if (!$id) return false;

	$owner = prepareDBValue($p['owner']);
        $recipients_include = prepareDBValue($p['recipients_include']);
        $recipients_exclude = prepareDBValue($p['recipients_exclude']);
        $servicegroups_include = prepareDBValue($p['servicegroups_include']);
        $servicegroups_exclude = prepareDBValue($p['servicegroups_exclude']);
	$hostgroups_include = prepareDBValue($p['hostgroups_include']);
	$hostgroups_exclude = prepareDBValue($p['hostgroups_exclude']);
	$hosts_include = prepareDBValue($p['hosts_include']);
	$hosts_exclude = prepareDBValue($p['hosts_exclude']);
	$services_include = prepareDBValue($p['services_include']);
	$services_exclude = prepareDBValue($p['services_exclude']);
	$notify_after_tries = prepareDBValue($p['notify_after_tries'][0]);
	$notify_on_ok = (($p['notify_on_ok'][0] == 'on') ? '1' : '0');
	$notify_on_warning = (($p['notify_on_warning'][0] == 'on') ? '1' : '0');
	$notify_on_unknown = (($p['notify_on_unknown'][0] == 'on') ? '1' : '0');
	$notify_on_host_unreachable = (($p['notify_on_host_unreachable'][0] == 'on') ? '1' : '0');
	$notify_on_critical = (($p['notify_on_critical'][0] == 'on') ? '1' : '0');
	$notify_on_host_up = (($p['notify_on_host_up'][0] == 'on') ? '1' : '0');
	$notify_on_host_down = (($p['notify_on_host_down'][0] == 'on') ? '1' : '0');
	$notify_on_type_problem = (($p['notify_on_type_problem'][$x] == 'on') ? '1' : '0');
	$notify_on_type_recovery = (($p['notify_on_type_recovery'][$x] == 'on') ? '1' : '0');
	$notify_on_type_flappingstart = (($p['notify_on_type_flappingstart'][$x] == 'on') ? '1' : '0');
	$notify_on_type_flappingstop = (($p['notify_on_type_flappingstop'][$x] == 'on') ? '1' : '0');
	$notify_on_type_flappingdisabled = (($p['notify_on_type_flappingdisabled'][$x] == 'on') ? '1' : '0');
	$notify_on_type_downtimestart = (($p['notify_on_type_downtimestart'][$x] == 'on') ? '1' : '0');
	$notify_on_type_downtimeend = (($p['notify_on_type_downtimeend'][$x] == 'on') ? '1' : '0');
	$notify_on_type_downtimecancelled = (($p['notify_on_type_downtimecancelled'][$x] == 'on') ? '1' : '0');
	$notify_on_type_acknowledgement = (($p['notify_on_type_acknowledgement'][$x] == 'on') ? '1' : '0');
	$notify_on_type_custom = (($p['notify_on_type_custom'][$x] == 'on') ? '1' : '0');
        $timeframe_id = prepareDBValue($p['timeframe']);
        $timezone_id = prepareDBValue($p['timezone']);
	$let_notifier_handle = ($p['let_notifier_handle']);
	$rollover = ($p['rollover']);


	// perform securicy checks
	if (!isAdmin()) {
		$dbResult = queryDB('select username from notifications where id=\'' . $id . '\'');
		if ($dbResult[0]['username'] != $owner) return false;
	}


	// update notification
	$query = sprintf(
		'update notifications set username=\'%s\', timeframe_id=\'%s\', timezone_id=\'%s\', recipients_include=\'%s\', recipients_exclude=\'%s\', hostgroups_include=\'%s\', hostgroups_exclude=\'%s\', hosts_include=\'%s\', hosts_exclude=\'%s\', servicegroups_include=\'%s\', servicegroups_exclude=\'%s\', services_include=\'%s\', services_exclude=\'%s\', notify_after_tries=\'%s\',on_ok=\'%s\', on_warning=\'%s\', on_unknown=\'%s\', on_host_unreachable=\'%s\', on_critical=\'%s\', on_host_up=\'%s\', on_host_down=\'%s\', on_type_problem=\'%s\', on_type_recovery=\'%s\', on_type_flappingstart=\'%s\', on_type_flappingstop=\'%s\', on_type_flappingdisabled=\'%s\', on_type_downtimestart=\'%s\', on_type_downtimeend=\'%s\', on_type_downtimecancelled=\'%s\', on_type_acknowledgement=\'%s\', on_type_custom=\'%s\', let_notifier_handle=\'%s\', rollover=\'%s\' where id=\'%s\'',
		$owner,
                $timeframe_id,
                $timezone_id,
		$recipients_include,
		$recipients_exclude,
		$hostgroups_include,
		$hostgroups_exclude,
		$hosts_include,
		$hosts_exclude,
                $servicegroups_include,
                $servicegroups_exclude,
		$services_include,
		$services_exclude,
		$notify_after_tries,
		$notify_on_ok,
		$notify_on_warning,
		$notify_on_unknown,
		$notify_on_host_unreachable,
		$notify_on_critical,
		$notify_on_host_up,
		$notify_on_host_down,
		$notify_on_type_problem,
		$notify_on_type_recovery,
		$notify_on_type_flappingstart,
		$notify_on_type_flappingstop,
		$notify_on_type_flappingdisabled,
		$notify_on_type_downtimestart,
		$notify_on_type_downtimeend,
		$notify_on_type_downtimecancelled,
		$notify_on_type_acknowledgement,
		$notify_on_type_custom,
		$let_notifier_handle,
		$rollover,
		$id
	);
	queryDB($query);

	// delete old notification users
	queryDB('delete from notifications_to_contacts where notification_id=\'' . $id . '\'');	

	// get notification users' usernames and add them
	// get user IDs
	$query = 'select id from contacts where ';
	$sep = null;

	// add owner to notifications list, if configured
	if ($notifications['add_owner'] === true) {
		if (is_array($p['notify_users']) === false) {
			$p['notify_users'][] = $p['owner'];
		} elseif (in_array($p['owner'], $p['notify_users']) === false) {
			$p['notify_users'][] = $p['owner'];
		}
	}

	// only update when users have been set
	if (isset($p['notify_users'][0])) {

		if (is_array($p['notify_users'][0]) && count($p['notify_users'][0])) {

			foreach ($p['notify_users'][0] as $username) {
				if (!empty($username)) {
					$query .= sprintf('%susername=\'%s\'', $sep, prepareDBValue($username));
					if (!$sep) $sep = ' or ';
				}
			}
			$dbResult = queryDB($query);

			// add user IDs
			$query = 'insert into notifications_to_contacts (notification_id,contact_id) values ';
			$sep = null;
			foreach ($dbResult as $row) {
				if (!empty($row['id'])) {
					$query .= sprintf('%s(%s,%s)', $sep, $id, $row['id']);
					if (!$sep) $sep = ',';
				}
			}
			queryDB($query);

		}

	}


	// delete old notitication groups
	queryDB('delete from notifications_to_contactgroups where notification_id=\'' . $id . '\'');

	// add new groups
	if (isset($p['notify_groups'][0])) {

		if (is_array($p['notify_groups'][0]) && count($p['notify_groups'][0])) {

			$contactgroups = null;
			$sep = null;

			foreach ($p['notify_groups'][0] as $group) {
				$contactgroups .= $sep . '(\'' . $id . '\',\'' . prepareDBValue($group) . '\')';
				if (!$sep) $sep = ',';
			}

			queryDB('insert into notifications_to_contactgroups values ' . $contactgroups);

		}

	}


	// delete old notification methods
	queryDB('delete from notifications_to_methods where notification_id=\'' . $id . '\'');

	// add notification methods
	if (isset($p['notify_by'][0])) {

		if (is_array($p['notify_by'][0]) && count($p['notify_by'][0])) {

			$query = 'insert into notifications_to_methods (notification_id,method_id) values ';
			$sep = null;
			foreach ($p['notify_by'][0] as $methodID) {
				if (!empty($methodID)) {
					$query .= sprintf('%s(\'%s\',\'%s\')', $sep, $id, prepareDBValue($methodID));
					if (!$sep) $sep = ',';
				}
			}
			queryDB($query);
		}

	}


	// BEGIN - handle escalations

	// delete escalations
	deleteEscalationsByNotificationId($id);

	// insert new escalations
	if (isset($p['escalation_count']) && is_array($p['escalation_count'])) {

		foreach ($p['escalation_count'] as $x) {

			// skip first notification
			if (!$x) continue;

			// add escalation
			$notify_after_tries = prepareDBValue($p['notify_after_tries'][$x]);
			$notify_on_ok = (($p['notify_on_ok'][$x] == 'on') ? '1' : '0');
			$notify_on_warning = (($p['notify_on_warning'][$x] == 'on') ? '1' : '0');
			$notify_on_unknown = (($p['notify_on_unknown'][$x] == 'on') ? '1' : '0');
			$notify_on_host_unreachable = (($p['notify_on_host_unreachable'][$x] == 'on') ? '1' : '0');
			$notify_on_critical = (($p['notify_on_critical'][$x] == 'on') ? '1' : '0');
			$notify_on_host_up = (($p['notify_on_host_up'][$x] == 'on') ? '1' : '0');
			$notify_on_host_down = (($p['notify_on_host_down'][$x] == 'on') ? '1' : '0');
			$notify_on_type_problem = (($p['notify_on_type_problem'][$x] == 'on') ? '1' : '0');
			$notify_on_type_recovery = (($p['notify_on_type_recovery'][$x] == 'on') ? '1' : '0');
			$notify_on_type_flappingstart = (($p['notify_on_type_flappingstart'][$x] == 'on') ? '1' : '0');
			$notify_on_type_flappingstop = (($p['notify_on_type_flappingstop'][$x] == 'on') ? '1' : '0');
			$notify_on_type_flappingdisabled = (($p['notify_on_type_flappingdisabled'][$x] == 'on') ? '1' : '0');
			$notify_on_type_downtimestart = (($p['notify_on_type_downtimestart'][$x] == 'on') ? '1' : '0');
			$notify_on_type_downtimeend = (($p['notify_on_type_downtimeend'][$x] == 'on') ? '1' : '0');
			$notify_on_type_downtimecancelled = (($p['notify_on_type_downtimecancelled'][$x] == 'on') ? '1' : '0');
			$notify_on_type_acknowledgement = (($p['notify_on_type_acknowledgement'][$x] == 'on') ? '1' : '0');
			$notify_on_type_custom = (($p['notify_on_type_custom'][$x] == 'on') ? '1' : '0');

			$query = sprintf(
				'insert into escalations_contacts
					(notification_id,on_ok,on_warning,on_critical,on_unknown,on_host_up,on_host_unreachable,on_host_down,on_type_problem,on_type_recovery,on_type_flappingstart,on_type_flappingstop,on_type_flappingdisabled,on_type_downtimestart,on_type_downtimeend,on_type_downtimecancelled,on_type_acknowledgement,on_type_custom,notify_after_tries) values
					(\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\,\'%s\',\'%s\',\'%s\',\'%s\',\'%s\)',
				$id,
				$notify_on_ok,
				$notify_on_warning,
				$notify_on_critical,
				$notify_on_unknown,
				$notify_on_host_up,
				$notify_on_host_unreachable,
				$notify_on_host_down,
				$notify_on_type_problem,
				$notify_on_type_recovery,
				$notify_on_type_flappingstart,
				$notify_on_type_flappingstop,
				$notify_on_type_flappingdisabled,
				$notify_on_type_downtimestart,
				$notify_on_type_downtimeend,
				$notify_on_type_downtimecancelled,
				$notify_on_type_acknowledgement,
				$notify_on_type_custom,
				$notify_after_tries
			);
			queryDB($query);


			// get escalation id
			$query = sprintf(
				'select id from escalations_contacts where
					notification_id=\'%s\' and on_ok=\'%s\' and on_warning=\'%s\' and on_critical=\'%s\' and on_unknown=\'%s\' and on_host_up=\'%s\' and on_host_unreachable=\'%s\' and on_host_down=\'%s\' and on_type_problem=\'%s\' and on_type_recovery=\'%s\' and on_type_flappingstart=\'%s\' and on_type_flappingstop=\'%s\' and on_type_flappingdisabled=\'%s\' and on_type_downtimestart=\'%s\' and on_type_downtimeend=\'%s\' and on_type_downtimecancelled=\'%s\' and on_type_acknowledgement=\'%s\' and on_type_custom=\'%s\' and notify_after_tries=\'%s\'',
				$id,
				$notify_on_ok,
				$notify_on_warning,
				$notify_on_critical,
				$notify_on_unknown,
				$notify_on_host_up,
				$notify_on_host_unreachable,
				$notify_on_host_down,
				$notify_on_type_problem,
				$notify_on_type_recovery,
				$notify_on_type_flappingstart,
				$notify_on_type_flappingstop,
				$notify_on_type_flappingdisabled,
				$notify_on_type_downtimestart,
				$notify_on_type_downtimeend,
				$notify_on_type_downtimecancelled,
				$notify_on_type_acknowledgement,
				$notify_on_type_custom,
				$notify_after_tries
			);
			$dbResult = queryDB($query);

			if (!is_array($dbResult)) return false;
			if (!count($dbResult)) return false;

			$eid = $dbResult[0]['id'];


			// handle contacts
			if (isset($p['notify_users'][$x])) {

				if (is_array($p['notify_users'][$x]) && count($p['notify_users'][$x])) {

					// get contact ids
					$where = null;
					$sep = null;
					foreach($p['notify_users'][$x] as $contact) {
						$where .= $sep . 'username=\'' . prepareDBValue($contact) . '\'';
						if (!$sep) $sep = ' or ';
					}
					$dbResult = queryDB('select distinct id from contacts where ' . $where);

					// store escalation contacts
					$values = null;
					$sep = null;
					foreach ($dbResult as $row) {
						$values .= sprintf('%s(\'%s\',\'%s\')', $sep, $eid, $row['id']);
						if (!$sep) $sep = ',';
					}
					queryDB('insert into escalations_contacts_to_contacts (escalation_contacts_id,contacts_id) values ' . $values);

				}

			}


			// store contactgroups
			if (isset($p['notify_groups'][$x])) {

				if (is_array($p['notify_groups'][$x]) && count($p['notify_groups'][$x])) {

					$values = null;
					$sep = null;
					foreach ($p['notify_groups'][$x] as $groupID) {
						$values .= sprintf('%s(\'%s\',\'%s\')', $sep, $eid, $groupID);
						if (!$sep) $sep = ',';
					}
					queryDB('insert into escalations_contacts_to_contactgroups (escalation_contacts_id,contactgroup_id) values ' . $values);

				}

			}


			// store methods
			if (isset($p['notify_by'][$x])) {

				if (is_array($p['notify_by'][$x]) && count($p['notify_by'][$x])) {

					$values = null;
					$sep = null;
					foreach ($p['notify_by'][$x] as $methodID) {
						$values .= sprintf('%s(\'%s\',\'%s\')', $sep, $eid, $methodID);
						if (!$sep) $sep = ',';
					}
					queryDB('insert into escalations_contacts_to_methods (escalation_contacts_id,method_id) values ' . $values);

				}

			}

		}

	}
	// END - handle escalations

	return true;

}




/**
 * toggleActive - toggle activity of notification
 *
 * @param		string		$id		ID of notification to toggle
 * @return		none
 */
function toggleActive ($id) {

	$id = prepareDBValue($id);

	// check for deleted user
	$dbResult = queryDB('select username from notifications where username=\'[---]\' and id=\'' . $id . '\'');
	if (isset($dbResult[0]['username'])) {
		// deactivate
		queryDB('update notifications set active=\'0\' where id=\'' . $id . '\'');
		return false;
	}

	// toggle state
	$dbResult = queryDB('select active from notifications where id=\'' . $id . '\'');
	$active = '0';
	if ($dbResult[0]['active'] == '0') $active = '1';
	queryDB('update notifications set active=\'' . $active . '\' where id=\'' . $id . '\'');

	return true;

}




/**
 * deleteNotification - delete notification and related escalations
 *
 * @param		string		$id		ID of notification to delete
 * @return		none
 */
function deleteNotification ($id) {

	$id = prepareDBValue($id);

	queryDB('delete from notifications where id=\'' . $id . '\'');
	queryDB('delete from notifications_to_methods where notification_id=\'' . $id . '\'');
	queryDB('delete from notifications_to_contacts where notification_id=\'' . $id . '\'');
	queryDB('delete from notifications_to_contactgroups where notification_id=\'' . $id . '\'');

	deleteEscalationsByNotificationId($id);

}




/**
 * deleteEscalationsByNotificationId - deletes escalations related to a notification
 *
 * @param		integer		$id		related notification id
 * @return		none
 */
function deleteEscalationsByNotificationId ($id) {

	// get escalation_ids
	$dbResult = queryDB('select id from escalations_contacts where notification_id=\'' . $id . '\'');

	if (count($dbResult)) {

		// create where statement
		$where = null;
		$sep = null;
		foreach($dbResult as $row) {
			$where .= $sep . 'escalation_contacts_id=\'' . $row['id'] . '\'';
			if (!$sep) $sep = ' or ';
		}

		// clear old escalations and relations
		queryDB('delete from escalations_contacts where notification_id=\''  . $id . '\'');
		queryDB('delete from escalations_contacts_to_contactgroups where ' . $where);
		queryDB('delete from escalations_contacts_to_contacts where ' . $where);
		queryDB('delete from escalations_contacts_to_methods where ' . $where);

	}

}




/**
 * deleteEscalationByEscalationId - deletes an escalation, identified by its ID
 *
 * @param		integer			$eid			escalation id
 * @return		none
 */
function deleteEscalationByEscalationId ($eid) {

	$eid = prepareDBValue($eid);

	// perform securicy checks
	if (!isAdmin()) {
		$query = sprintf(
			'select count(*) cnt from contacts c
				left join notifications n on c.username=n.username
				left join escalations_contacts ec on ec.notification_id=n.id
				where ec.id=\'%s\' and c.username=\'%s\'',
			$eid,
			prepareDBValue($_SESSION['user'])
		);
		$dbResult = queryDB($query);
		if ($dbResult[0]['cnt'] != '1') return false;
	}

	queryDB('delete from escalations_contacts where id=\'' . $eid . '\'');
	queryDB('delete from escalations_contacts_to_contacts where escalation_contacts_id=\'' . $eid . '\'');
	queryDB('delete from escalations_contacts_to_contactgroups where escalation_contacts_id=\'' . $eid . '\'');
	queryDB('delete from escalations_contacts_to_methods where escalation_contacts_id=\'' . $eid . '\'');

	return true;

}
	

?>
