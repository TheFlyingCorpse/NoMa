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
        $notification_name = prepareDBValue($p['notification_name']);
        $notification_description = prepareDBValue($p['notification_description']);
	$notify_after_tries = prepareDBValue($p['notify_after_tries']);
        $notify_on_ok = prepareDBValue((isset($p['notify_on_ok']) && $p['notify_on_ok'] == 'on') ? '1' : '0');
        $notify_on_warning = prepareDBValue((isset($p['notify_on_warning']) && $p['notify_on_warning'] == 'on') ? '1' : '0');
        $notify_on_unknown = prepareDBValue((isset($p['notify_on_unknown']) && $p['notify_on_unknown'] == 'on') ? '1' : '0');
        $notify_on_host_unreachable = prepareDBValue((isset($p['notify_on_host_unreachable']) && $p['notify_on_host_unreachable'] == 'on') ? '1' : '0');
	$notify_on_critical = prepareDBValue((isset($p['notify_on_critical']) && $p['notify_on_critical'] == 'on') ? '1' : '0');
	$notify_on_host_up = prepareDBValue((isset($p['notify_on_host_up']) && $p['notify_on_host_up'] == 'on') ? '1' : '0');
	$notify_on_host_down = prepareDBValue((isset($p['notify_on_host_down']) && $p['notify_on_host_down'] == 'on') ? '1' : '0');
	$notify_on_type_problem = prepareDBValue((isset($p['notify_on_type_problem']) && $p['notify_on_type_problem'] == 'on') ? '1' : '0');
	$notify_on_type_recovery = prepareDBValue((isset($p['notify_on_type_recovery']) && $p['notify_on_type_recovery'] == 'on') ? '1' : '0');
	$notify_on_type_flappingstart = prepareDBValue((isset($p['notify_on_type_flappingstart']) && $p['notify_on_type_flappingstart'] == 'on') ? '1' : '0');
	$notify_on_type_flappingstop = prepareDBValue((isset($p['notify_on_type_flappingstop']) && $p['notify_on_type_flappingstop'] == 'on') ? '1' : '0');
	$notify_on_type_flappingdisabled = prepareDBValue((isset($p['notify_on_type_flappingdisabled']) && $p['notify_on_type_flappingdisabled'] == 'on') ? '1' : '0');
	$notify_on_type_downtimestart = prepareDBValue((isset($p['notify_on_type_downtimestart']) && $p['notify_on_type_downtimestart'] == 'on') ? '1' : '0');
	$notify_on_type_downtimeend = prepareDBValue((isset($p['notify_on_type_downtimeend']) && $p['notify_on_type_downtimeend'] == 'on') ? '1' : '0');
	$notify_on_type_downtimecancelled = prepareDBValue((isset($p['notify_on_type_downtimecancelled']) && $p['notify_on_type_downtimecancelled'] == 'on') ? '1' : '0');
	$notify_on_type_acknowledgement = prepareDBValue((isset($p['notify_on_type_acknowledgement']) && $p['notify_on_type_acknowledgement'] == 'on') ? '1' : '0');
        $notify_on_type_custom = prepareDBValue((isset($p['notify_on_type_custom']) && $p['notify_on_type_custom'] == 'on') ? '1' : '0');
        $timeframe_id = prepareDBValue($p['timeframe']);
        $timezone_id = prepareDBValue($p['timezone']);
	$let_notifier_handle = prepareDBValue((isset($p['let_notifier_handle']) && ($p['let_notifier_handle']) == 'on') ? '1' : '0');
	$rollover = prepareDBValue((isset($p['rollover']) && $p['rollover'] == 'on') ? '1' : '0');


	// perform securicy checks
	if (!checkUser($p['owner'])) return false;


	// check whether notification exists
	$query = sprintf(
		'select id from notifications
			where active=0 and username=\'%s\' and noticication_name=\'%s\' and noticication_description=\'%s\' and recipients_include=\'%s\' and recipients_exclude=\'%s\' and hostgroups_include=\'%s\' and hostgroups_exclude=\'%s\' and hosts_include=\'%s\' and hosts_exclude=\'%s\'  and servicegroups_include=\'%s\' and servicegroups_exclude=\'%s\' and services_include=\'%s\' and services_exclude=\'%s\' and notify_after_tries=\'%s\' and on_ok=\'%s\' and on_warning=\'%s\' and on_unknown=\'%s\' and on_host_unreachable=\'%s\' and on_critical=\'%s\' and on_host_up=\'%s\' and on_host_down=\'%s\' and on_type_problem=\'%s\' and on_type_recovery=\'%s\' and on_type_flappingstart=\'%s\' and on_type_flappingstop=\'%s\' and on_type_flappingdisabled=\'%s\' and on_type_downtimestart=\'%s\' and on_type_downtimeend=\'%s\' and on_type_downtimecancelled=\'%s\' and on_type_acknowledgement=\'%s\' and on_type_custom=\'%s\' and timeframe_id=\'%s\' and timezone_id=\'%s\'',
		$owner,
		$notification_name,
		$notification_description,
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
                $timeframe_id,
                $timezone_id
	);
	$dbResult = queryDB($query);
	if (count($dbResult)) return false;
	

	// add notification
	$query = sprintf(
		'INSERT INTO notifications 
		(active,username,notification_name,notification_description,recipients_include,recipients_exclude,hosts_include,hosts_exclude,hostgroups_include,hostgroups_exclude,services_include,services_exclude,servicegroups_include,servicegroups_exclude,notify_after_tries,let_notifier_handle,rollover,on_ok,on_warning,on_unknown,on_host_unreachable,on_critical,on_host_up,on_host_down,on_type_problem,on_type_recovery,on_type_flappingstart,on_type_flappingstop,on_type_flappingdisabled,on_type_downtimestart,on_type_downtimeend,on_type_downtimecancelled,on_type_acknowledgement,on_type_custom,timezone_id,timeframe_id)
VALUES (\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\')',
                '0',
                $owner,
		$notification_name,
                $notification_description,
                $recipients_include,
                $recipients_exclude,
                $hosts_include,
                $hosts_exclude,
                $hostgroups_include,
                $hostgroups_exclude,
                $services_include,
                $services_exclude,
                $servicegroups_include,
                $servicegroups_exclude,
                $notify_after_tries,
                $let_notifier_handle,
                $rollover,
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
                $timezone_id,
                $timeframe_id
	);

	queryDB($query);

	// get new id
	$query = sprintf(
		'SELECT id FROM notifications
			WHERE active=\'0\' and username=\'%s\' and notification_name=\'%s\' and notification_description=\'%s\' and recipients_include=\'%s\' and recipients_exclude=\'%s\' and hostgroups_include=\'%s\' and hostgroups_exclude=\'%s\' and  hosts_include=\'%s\' and hosts_exclude=\'%s\' and servicegroups_include=\'%s\' and servicegroups_exclude=\'%s\' and services_include=\'%s\' and services_exclude=\'%s\' and notify_after_tries=\'%s\' and on_ok=\'%s\' and on_warning=\'%s\' and on_unknown=\'%s\' and on_host_unreachable=\'%s\' and on_critical=\'%s\' and on_host_up=\'%s\' and on_host_down=\'%s\' and on_type_problem=\'%s\' and on_type_recovery=\'%s\' and on_type_flappingstart=\'%s\' and on_type_flappingstop=\'%s\' and on_type_flappingdisabled=\'%s\' and on_type_downtimestart=\'%s\' and on_type_downtimeend=\'%s\' and on_type_downtimecancelled=\'%s\' and on_type_acknowledgement=\'%s\' and on_type_custom=\'%s\' and timeframe_id=\'%s\' and timezone_id=\'%s\'',
		$owner,
		$notification_name,
		$notification_description,
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
                $timeframe_id,
                $timezone_id
	);
	$dbResult = queryDB($query);
	$id = $dbResult[0]['id'];

	if (!$id) return false;


        // add owner to notifications list, if configured
        if ($notifications['add_owner'] === true) {

	        $owner_id = getContactID($owner);

                if (is_array($p['notify_users']) === false) {

                        $p['notify_users'][] = $owner_id;

                } elseif (in_array($owner_id, $p['notify_users']) === false) {

                        $p['notify_users'][] = $owner_id;

                }

        }

	if (isset($p['notify_users']) && is_array($p['notify_users'])) {

                // Because of SQLite3, this needs to be split into several transactions.
                foreach ($p['notify_users'] as $user) {

                        if (!empty($user)){
                                $query = sprintf('INSERT INTO notifications_to_contacts (notification_id,contact_id) VALUES (\'%s\',\'%s\');', $id, getContactID($user));
                                queryDB($query);

			}

                }

	}

	// store contactgroups
	if (isset($p['notify_groups']) && is_array($p['notify_groups'])) {

                // Because of SQLite3, this needs to be split into several transactions.
                foreach ($p['notify_groups'] as $group) {

                         if (!empty($group)){
                                $query = sprintf('INSERT INTO notifications_to_contactgroups (notification_id,contactgroup_id) VALUES (\'%s\',\'%s\');', $id, prepareDBValue($group));
                                queryDB($query);
                         }

                }

	}


	// add notification methods
	if (isset($p['notify_by']) && is_array($p['notify_by'])) {

                // Because of SQLite3, this needs to be split into several transactions.
                foreach ($p['notify_by'] as $methodID) {
                         if (!empty($methodID)){
                                $query = 'INSERT INTO notifications_to_methods (notification_id,method_id) VALUES (\''.$id.'\',\''.prepareDBValue($methodID).'\')';
                                queryDB($query);
                         }

                }

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
        $notification_name = prepareDBValue($p['notification_name']);
        $notification_description = prepareDBValue($p['notification_description']);
	$notify_after_tries = prepareDBValue($p['notify_after_tries'][0]);
        $notify_on_ok = prepareDBValue((isset($p['notify_on_ok'][0]) && ($p['notify_on_ok'][0]) == 'on') ? '1' : '0');
        $notify_on_warning = prepareDBValue((isset($p['notify_on_warning'][0]) && ($p['notify_on_warning'][0]) == 'on') ? '1' : '0');
        $notify_on_unknown = prepareDBValue((isset($p['notify_on_unknown'][0]) && ($p['notify_on_unknown'][0]) == 'on') ? '1' : '0');
        $notify_on_host_unreachable = prepareDBValue((isset($p['notify_on_host_unreachable'][0]) && ($p['notify_on_host_unreachable'][0]) == 'on') ? '1' : '0');
        $notify_on_critical = prepareDBValue((isset($p['notify_on_critical'][0]) && ($p['notify_on_critical'][0]) == 'on') ? '1' : '0');
        $notify_on_host_up = prepareDBValue((isset($p['notify_on_host_up'][0]) && ($p['notify_on_host_up'][0]) == 'on') ? '1' : '0');
        $notify_on_host_down = prepareDBValue((isset($p['notify_on_host_down'][0]) && ($p['notify_on_host_down'][0]) == 'on') ? '1' : '0');
        $notify_on_type_problem = prepareDBValue((isset($p['notify_on_type_problem'][0]) && ($p['notify_on_type_problem'][0]) == 'on') ? '1' : '0');
        $notify_on_type_recovery = prepareDBValue((isset($p['notify_on_type_recovery'][0]) && ($p['notify_on_type_recovery'][0]) == 'on') ? '1' : '0');
        $notify_on_type_flappingstart = prepareDBValue((isset($p['notify_on_type_flappingstart'][0]) && ($p['notify_on_type_flappingstart'][0]) == 'on') ? '1' : '0');
        $notify_on_type_flappingstop = prepareDBValue((isset($p['notify_on_type_flappingstop'][0]) && ($p['notify_on_type_flappingstop'][0]) == 'on') ? '1' : '0');
        $notify_on_type_flappingdisabled = prepareDBValue((isset($p['notify_on_type_flappingdisabled'][0]) && ($p['notify_on_type_flappingdisabled'][0]) == 'on') ? '1' : '0');
        $notify_on_type_downtimestart = prepareDBValue((isset($p['notify_on_type_downtimestart'][0]) && ($p['notify_on_type_downtimestart'][0]) == 'on') ? '1' : '0');
        $notify_on_type_downtimeend = prepareDBValue((isset($p['notify_on_type_downtimeend'][0]) && ($p['notify_on_type_downtimeend'][0]) == 'on') ? '1' : '0');
        $notify_on_type_downtimecancelled = prepareDBValue((isset($p['notify_on_type_downtimecancelled'][0]) && ($p['notify_on_type_downtimecancelled'][0]) == 'on') ? '1' : '0');
        $notify_on_type_acknowledgement = prepareDBValue((isset($p['notify_on_type_acknowledgement'][0]) && ($p['notify_on_type_acknowledgement'][0]) == 'on') ? '1' : '0');
        $notify_on_type_custom = prepareDBValue((isset($p['notify_on_type_custom'][0]) && ($p['notify_on_type_custom'][0]) == 'on') ? '1' : '0');
	$let_notifier_handle = prepareDBValue((isset($p['let_notifier_handle']) && ($p['let_notifier_handle']) == 'on') ? '1' : '0');
	$rollover = prepareDBValue((isset($p['rollover']) && ($p['rollover']) == 'on') ? '1' : '0');
        $timeframe_id = prepareDBValue($p['timeframe']);
        $timezone_id = prepareDBValue($p['timezone']);


	// perform securicy checks
	if (!isAdmin()) {
		$dbResult = queryDB('select username from notifications where id=\'' . $id . '\'');
		if ($dbResult[0]['username'] != $owner) return false;
	}

	// update notification
	$query = sprintf(
		'UPDATE notifications SET username=\'%s\', notification_name=\'%s\', notification_description=\'%s\', recipients_include=\'%s\', recipients_exclude=\'%s\', hostgroups_include=\'%s\', hostgroups_exclude=\'%s\', hosts_include=\'%s\', hosts_exclude=\'%s\', servicegroups_include=\'%s\', servicegroups_exclude=\'%s\', services_include=\'%s\', services_exclude=\'%s\', notify_after_tries=\'%s\',on_ok=\'%s\', on_warning=\'%s\', on_unknown=\'%s\', on_host_unreachable=\'%s\', on_critical=\'%s\', on_host_up=\'%s\', on_host_down=\'%s\', on_type_problem=\'%s\', on_type_recovery=\'%s\', on_type_flappingstart=\'%s\', on_type_flappingstop=\'%s\', on_type_flappingdisabled=\'%s\', on_type_downtimestart=\'%s\', on_type_downtimeend=\'%s\', on_type_downtimecancelled=\'%s\', on_type_acknowledgement=\'%s\', on_type_custom=\'%s\', let_notifier_handle=\'%s\', rollover=\'%s\', timeframe_id=\'%s\', timezone_id=\'%s\' WHERE id=\'%s\';',
		$owner,
		$notification_name,
		$notification_description,
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
                $timeframe_id,
                $timezone_id,
		$id
	);
	queryDB($query);

	// delete old notification users
	queryDB('delete from notifications_to_contacts where notification_id=\'' . $id . '\'');	

	// add owner to notifications list, if configured
	if ($notifications['add_owner'] === true) {

                $owner_id = getContactID($owner);

                if (is_array($p['notify_users']) === false) {

                        $p['notify_users'][] = $owner_id;

                } elseif (in_array($owner_id, $p['notify_users']) === false) {

                        $p['notify_users'][] = $owner_id;

                }

	}

	// only update when users have been set
	if (isset($p['notify_users'][0])) {

		if (is_array($p['notify_users'][0]) && count($p['notify_users'][0])) {

                        foreach ($p['notify_users'][0] as $user) {
                                if (!empty($user)){
                                        $query = sprintf('insert into notifications_to_contacts (notification_id,contact_id) values(\'%s\',\'%s\')', $id, getContactID($user));
                                        queryDB($query);

                                }

                        }

		}

	}


	// delete old notitication groups
	queryDB('delete from notifications_to_contactgroups where notification_id=\'' . $id . '\'');

	// add new groups
	if (isset($p['notify_groups'][0])) {

		if (is_array($p['notify_groups'][0]) && count($p['notify_groups'][0])) {

                        // Because of SQLite3, this needs to be split into several transactions.
                        foreach ($p['notify_groups'][0] as $group) {
                                if (!empty($group)){
                                        $query = sprintf('insert into notifications_to_contactgroups (notification_id,contactgroup_id) values(\'%s\',\'%s\')', $id, prepareDBValue($group));
                                        queryDB($query);

                                }

                        }

		}

	}


	// delete old notification methods
	queryDB('delete from notifications_to_methods where notification_id=\'' . $id . '\'');

	// add notification methods
	if (isset($p['notify_by'][0])) {

		if (is_array($p['notify_by'][0]) && count($p['notify_by'][0])) {

			// Because of SQLite3, this has been split into several transactions.
			foreach ($p['notify_by'][0] as $methodID) {
				if (!empty($methodID)) {
					$query = sprintf('insert into notifications_to_methods (notification_id,method_id) values(\'%s\',\'%s\')', $id, prepareDBValue($methodID));
		                        queryDB($query);

				}

			}

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
			$notify_on_ok = prepareDBValue((isset($p['notify_on_ok'][$x]) && ($p['notify_on_ok'][$x]) == 'on') ? '1' : '0');
                        $notify_on_warning = prepareDBValue((isset($p['notify_on_warning'][$x]) && ($p['notify_on_warning'][$x]) == 'on') ? '1' : '0');
                        $notify_on_unknown = prepareDBValue((isset($p['notify_on_unknown'][$x]) && ($p['notify_on_unknown'][$x]) == 'on') ? '1' : '0');
                        $notify_on_host_unreachable = prepareDBValue((isset($p['notify_on_host_unreachable'][$x]) && ($p['notify_on_host_unreachable'][$x]) == 'on') ? '1' : '0');
                        $notify_on_critical = prepareDBValue((isset($p['notify_on_critical'][$x]) && ($p['notify_on_critical'][$x]) == 'on') ? '1' : '0');
                        $notify_on_host_up = prepareDBValue((isset($p['notify_on_host_up'][$x]) && ($p['notify_on_host_up'][$x]) == 'on') ? '1' : '0');
                        $notify_on_host_down = prepareDBValue((isset($p['notify_on_host_down'][$x]) && ($p['notify_on_host_down'][$x]) == 'on') ? '1' : '0');
                        $notify_on_type_problem = prepareDBValue((isset($p['notify_on_type_problem'][$x]) && ($p['notify_on_type_problem'][$x]) == 'on') ? '1' : '0');
                        $notify_on_type_recovery = prepareDBValue((isset($p['notify_on_type_recovery'][$x]) && ($p['notify_on_type_recovery'][$x]) == 'on') ? '1' : '0');
                        $notify_on_type_flappingstart = prepareDBValue((isset($p['notify_on_type_flappingstart'][$x]) && ($p['notify_on_type_flappingstart'][$x]) == 'on') ? '1' : '0');
                        $notify_on_type_flappingstop = prepareDBValue((isset($p['notify_on_type_flappingstop'][$x]) && ($p['notify_on_type_flappingstop'][$x]) == 'on') ? '1' : '0');
                        $notify_on_type_flappingdisabled = prepareDBValue((isset($p['notify_on_type_flappingdisabled'][$x]) && ($p['notify_on_type_flappingdisabled'][$x]) == 'on') ? '1' : '0');
                        $notify_on_type_downtimestart = prepareDBValue((isset($p['notify_on_type_downtimestart'][$x]) && ($p['notify_on_type_downtimestart'][$x]) == 'on') ? '1' : '0');
                        $notify_on_type_downtimeend = prepareDBValue((isset($p['notify_on_type_downtimeend'][$x]) && ($p['notify_on_type_downtimeend'][$x]) == 'on') ? '1' : '0');
                        $notify_on_type_downtimecancelled = prepareDBValue((isset($p['notify_on_type_downtimecancelled'][$x]) && ($p['notify_on_type_downtimecancelled'][$x]) == 'on') ? '1' : '0');
                        $notify_on_type_acknowledgement = prepareDBValue((isset($p['notify_on_type_acknowledgement'][$x]) && ($p['notify_on_type_acknowledgement'][$x]) == 'on') ? '1' : '0');
                        $notify_on_type_custom = prepareDBValue((isset($p['notify_on_type_custom'][$x]) && ($p['notify_on_type_custom'][$x]) == 'on') ? '1' : '0');

			$query = sprintf(
				'INSERT INTO escalations_contacts
					(notification_id, on_ok, on_warning, on_critical, on_unknown, on_host_up, on_host_unreachable, on_host_down, on_type_problem, on_type_recovery, on_type_flappingstart, on_type_flappingstop, on_type_flappingdisabled, on_type_downtimestart, on_type_downtimeend, on_type_downtimecancelled, on_type_acknowledgement, on_type_custom, notify_after_tries) 
					VALUES (\'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\');',
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
				'SELECT id FROM escalations_contacts WHERE
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

			                // Because of SQLite3, this needs to be split into several transactions.
			                foreach ($p['notify_users'] as $user) {

			                        if (!empty($user) and (prepareDBValue($user) != '')){
			                                $query = sprintf('INSERT INTO escalations_contacts_to_contacts (escalation_contacts_id,contacts_id)) VALUES (\'%s\',\'%s\');', $id, prepareDBValue($user));
			                                queryDB($query);

			                        }

			                }

				}

			}


			// store contactgroups
			if (isset($p['notify_groups'][$x])) {

				if (is_array($p['notify_groups'][$x]) && count($p['notify_groups'][$x])) {

		                        // Because of SQLite3, this has been split into several transactions.
		                        foreach ($p['notify_groups'][$x] as $groupID) {

		                                if (!empty($groupID)) {

		                                        $query = sprintf('INSERT INTO escalations_contacts_to_contactgroups (escalation_contacts_id,contactgroup_id) VALUES (\'%s\',\'%s\');', $eid, prepareDBValue($groupID));

		                                        queryDB($query);

		       	                        }

		                        }

				}

			}


			// store methods
			if (isset($p['notify_by'][$x])) {

				if (is_array($p['notify_by'][$x]) && count($p['notify_by'][$x])) {

                                        // Because of SQLite3, this has been split into several transactions.
                                        foreach ($p['notify_by'][$x] as $methodID) {

                                                if (!empty($methodID)) {

                                                        $query = sprintf('INSERT INTO escalations_contacts_to_methods (escalation_contacts_id,method_id) VALUES (\'%s\',\'%s\')', $eid, prepareDBValue($methodID));

                                                        queryDB($query);

                                                }

                                        }

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
	$dbResult = queryDB('SELECT username FROM notifications WHERE username=\'[---]\' and id=\'' . $id . '\'');
	if (isset($dbResult[0]['username'])) {
		// deactivate
		queryDB('UPDATE notifications SET active=\'0\' WHERE id=\'' . $id . '\'');
		return false;
	}

	// toggle state
	$dbResult = queryDB('SELECT active FROM notifications WHERE id=\'' . $id . '\'');
	$active = '0';
	if ($dbResult[0]['active'] == '0') $active = '1';
	queryDB('UPDATE notifications SET active=\'' . $active . '\' WHERE id=\'' . $id . '\'');

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

	queryDB('DELETE FROM notifications WHERE id=\'' . $id . '\'');
	queryDB('DELETE FROM notifications_to_methods WHERE notification_id=\'' . $id . '\'');
	queryDB('DELETE FROM notifications_to_contacts WHERE notification_id=\'' . $id . '\'');
	queryDB('DELETE FROM notifications_to_contactgroups WHERE notification_id=\'' . $id . '\'');

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
	$dbResult = queryDB('SELECT id FROM escalations_contacts WHERE notification_id=\'' . $id . '\'');

	if (count($dbResult)) {

		// create where statement
		$where = null;
		$sep = null;
		foreach($dbResult as $row) {
			$where .= $sep . 'escalation_contacts_id=\'' . $row['id'] . '\'';
			if (!$sep) $sep = ' or ';
		}

		// clear old escalations and relations
		queryDB('DELETE FROM escalations_contacts WHERE notification_id=\''  . $id . '\'');
		queryDB('DELETE FROM escalations_contacts_to_contactgroups WHERE ' . $where);
		queryDB('DELETE FROM escalations_contacts_to_contacts WHERE ' . $where);
		queryDB('DELETE FROM escalations_contacts_to_methods WHERE ' . $where);

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
			'SELECT count(*) cnt FROM contacts c
				left join notifications n on c.username=n.username
				left join escalations_contacts ec on ec.notification_id=n.id
				WHERE ec.id=\'%s\' and c.username=\'%s\'',
			$eid,
			prepareDBValue($_SESSION['user'])
		);
		$dbResult = queryDB($query);
		if ($dbResult[0]['cnt'] != '1') return false;
	}

	queryDB('DELETE FROM escalations_contacts WHERE id=\'' . $eid . '\'');
	queryDB('DELETE FROM escalations_contacts_to_contacts WHERE escalation_contacts_id=\'' . $eid . '\'');
	queryDB('DELETE FROM escalations_contacts_to_contactgroups WHERE escalation_contacts_id=\'' . $eid . '\'');
	queryDB('DELETE FROM escalations_contacts_to_methods WHERE escalation_contacts_id=\'' . $eid . '\'');

	return true;

}
	

?>
