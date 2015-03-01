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
	$customvariables_include = prepareDBValue($p['customvariables_include']);
	$customvariables_exclude = prepareDBValue($p['customvariables_exclude']);
        $notification_name = prepareDBValue($p['notification_name']);
        $notification_description = prepareDBValue($p['notification_description']);
	$notify_after_tries = prepareDBValue($p['notify_after_tries']);

    $notify_on_ok = prepareDBValue((isset($p['notify_on_ok']) && $p['notify_on_ok'] == 'on') ? 1 : 0);

    $notify_on_warning = prepareDBValue(
        ((isset($p['notify_on_warning']) && ($p['notify_on_warning']) == 'on') ? 1 : 0)
        | ((isset($p['notify_on_critical_to_warning']) && ($p['notify_on_critical_to_warning']) == 'on') ? 8 : 0)
        | ((isset($p['notify_on_unknown_to_warning']) && ($p['notify_on_unknown_to_warning']) == 'on') ? 16 : 0)
    );
    $notify_on_critical = prepareDBValue(
        ((isset($p['notify_on_critical']) && ($p['notify_on_critical']) == 'on') ? 1 : 0)
        | ((isset($p['notify_on_warning_to_critical']) && ($p['notify_on_warning_to_critical']) == 'on') ? 4 : 0)
        | ((isset($p['notify_on_unknown_to_critical']) && ($p['notify_on_unknown_to_critical']) == 'on') ? 16 : 0)
    );
    $notify_on_unknown = prepareDBValue(
        ((isset($p['notify_on_unknown']) && ($p['notify_on_unknown']) == 'on') ? 1 : 0)
        | ((isset($p['notify_on_warning_to_unknown']) && ($p['notify_on_warning_to_unknown']) == 'on') ? 4 : 0)
        | ((isset($p['notify_on_critical_to_unknown']) && ($p['notify_on_critical_to_unknown']) == 'on') ? 8 : 0)
    );

	$notify_on_host_up = prepareDBValue((isset($p['notify_on_host_up']) && $p['notify_on_host_up'] == 'on') ? 1 : 0);
	$notify_on_host_down = prepareDBValue((isset($p['notify_on_host_down']) && $p['notify_on_host_down'] == 'on') ? 1 : 0);
    $notify_on_host_unreachable = prepareDBValue((isset($p['notify_on_host_unreachable']) && $p['notify_on_host_unreachable'] == 'on') ? 1 : 0);
	$notify_on_type_flappingstart = prepareDBValue((isset($p['notify_on_type_flappingstart']) && $p['notify_on_type_flappingstart'] == 'on') ? 1 : 0);
	$notify_on_type_flappingstop = prepareDBValue((isset($p['notify_on_type_flappingstop']) && $p['notify_on_type_flappingstop'] == 'on') ? 1 : 0);
	$notify_on_type_flappingdisabled = prepareDBValue((isset($p['notify_on_type_flappingdisabled']) && $p['notify_on_type_flappingdisabled'] == 'on') ? 1 : 0);
	$notify_on_type_downtimestart = prepareDBValue((isset($p['notify_on_type_downtimestart']) && $p['notify_on_type_downtimestart'] == 'on') ? 1 : 0);
	$notify_on_type_downtimeend = prepareDBValue((isset($p['notify_on_type_downtimeend']) && $p['notify_on_type_downtimeend'] == 'on') ? 1 : 0);
	$notify_on_type_downtimecancelled = prepareDBValue((isset($p['notify_on_type_downtimecancelled']) && $p['notify_on_type_downtimecancelled'] == 'on') ? 1 : 0);
	$notify_on_type_acknowledgement = prepareDBValue((isset($p['notify_on_type_acknowledgement']) && $p['notify_on_type_acknowledgement'] == 'on') ? 1 : 0);
        $notify_on_type_custom = prepareDBValue((isset($p['notify_on_type_custom']) && $p['notify_on_type_custom'] == 'on') ? 1 : 0);
        $timeframe_id = prepareDBValue($p['timeframe']);
        $timezone_id = prepareDBValue($p['timezone']);
	$let_notifier_handle = prepareDBValue((isset($p['let_notifier_handle']) && ($p['let_notifier_handle']) == 'on') ? 1 : 0);
	$rollover = prepareDBValue((isset($p['rollover']) && $p['rollover'] == 'on') ? 1 : 0);


	// perform securicy checks
	if (!checkUser($p['owner'])) return false;


	// check whether notification exists
	$query = sprintf(
		'select id from notifications
			where active=0 and username=\'%s\' and notification_name=\'%s\' and notification_description=\'%s\' and recipients_include=\'%s\' and recipients_exclude=\'%s\' and hostgroups_include=\'%s\' and hostgroups_exclude=\'%s\' and hosts_include=\'%s\' and hosts_exclude=\'%s\'  and servicegroups_include=\'%s\' and servicegroups_exclude=\'%s\' and services_include=\'%s\' and services_exclude=\'%s\' and customvariables_include=\'%s\' and customvariables_exclude=\'%s\' and notify_after_tries=\'%s\' and on_ok=%d and on_warning=%d and on_unknown=%d and on_host_unreachable=%d and on_critical=%d and on_host_up=%d and on_host_down=%d and on_type_flappingstart=%d and on_type_flappingstop=%d and on_type_flappingdisabled=%d and on_type_downtimestart=%d and on_type_downtimeend=%d and on_type_downtimecancelled=%d and on_type_acknowledgement=%d and on_type_custom=%d and timeframe_id=\'%s\' and timezone_id=\'%s\'',
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
		$customvariables_include,
		$customvariables_exclude,
		$notify_after_tries,
		$notify_on_ok,
		$notify_on_warning,
		$notify_on_unknown,
		$notify_on_host_unreachable,
		$notify_on_critical,
		$notify_on_host_up,
		$notify_on_host_down,
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
		(active,username,notification_name,notification_description,recipients_include,recipients_exclude,hosts_include,hosts_exclude,hostgroups_include,hostgroups_exclude,services_include,services_exclude,servicegroups_include,servicegroups_exclude,customvariables_include,customvariables_exclude,notify_after_tries,let_notifier_handle,rollover,on_ok,on_warning,on_unknown,on_host_unreachable,on_critical,on_host_up,on_host_down,on_type_flappingstart,on_type_flappingstop,on_type_flappingdisabled,on_type_downtimestart,on_type_downtimeend,on_type_downtimecancelled,on_type_acknowledgement,on_type_custom,timezone_id,timeframe_id)
VALUES (%d,\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,\'%s\',\'%s\')',
                0,
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
		$customvariables_include,
		$customvariables_exclude,
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
			WHERE active=0 and username=\'%s\' and notification_name=\'%s\' and notification_description=\'%s\' and recipients_include=\'%s\' and recipients_exclude=\'%s\' and hostgroups_include=\'%s\' and hostgroups_exclude=\'%s\' and  hosts_include=\'%s\' and hosts_exclude=\'%s\' and servicegroups_include=\'%s\' and servicegroups_exclude=\'%s\' and services_include=\'%s\' and services_exclude=\'%s\' and customvariables_include=\'%s\' and customvariables_exlude=\'%s\' and notify_after_tries=\'%s\' and on_ok=%d and on_warning=%d and on_unknown=%d and on_host_unreachable=%d and on_critical=%d and on_host_up=%d and on_host_down=%d and on_type_flappingstart=%d and on_type_flappingstop=%d and on_type_flappingdisabled=%d and on_type_downtimestart=%d and on_type_downtimeend=%d and on_type_downtimecancelled=%d and on_type_acknowledgement=%d and on_type_custom=%d and timeframe_id=\'%s\' and timezone_id=\'%s\'',
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
		$customvariables_include,
		$customvariables_exclude,
		$notify_after_tries,
		$notify_on_ok,
		$notify_on_warning,
		$notify_on_unknown,
		$notify_on_host_unreachable,
		$notify_on_critical,
		$notify_on_host_up,
		$notify_on_host_down,
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

	/* AUDIT THE NEW NOTIFICATION */
	$audit = sprintf(
                'INSERT INTO audit_log_notifications (changed_by_username, db_operation, id, notification_name, notification_description, active, username, recipients_include, recipients_exclude, hosts_include, hosts_exclude, hostgroups_include, hostgroups_exclude, services_include, services_exclude, servicegroups_include, servicegroups_exclude, customvariables_include, customvariables_exclude, notify_after_tries, let_notifier_handle, rollover, reloop_delay, on_ok, on_warning, on_unknown, on_host_unreachable, on_critical, on_host_up, on_host_down, on_type_problem, on_type_recovery, on_type_flappingstart, on_type_flappingstop, on_type_flappingdisabled, on_type_downtimestart, on_type_downtimeend, on_type_downtimecancelled, on_type_acknowledgement, on_type_custom, timezone_id, timeframe_id)
                        SELECT "\'%s\'", "INSERT-new", id, notification_name, notification_description, active, username, recipients_include, recipients_exclude, hosts_include, hosts_exclude, hostgroups_include, hostgroups_exclude, services_include, services_exclude, servicegroups_include, servicegroups_exclude, customvariables_include, customvariables_exclude, notify_after_tries, let_notifier_handle, rollover, reloop_delay, on_ok, on_warning, on_unknown, on_host_unreachable, on_critical, on_host_up, on_host_down, on_type_problem, on_type_recovery, on_type_flappingstart, on_type_flappingstop, on_type_flappingdisabled, on_type_downtimestart, on_type_downtimeend, on_type_downtimecancelled, on_type_acknowledgement, on_type_custom, timezone_id, timeframe_id
                        FROM notifications WHERE id=\'%s\'',
                $_SESSION['user'],
                $id
        );
        $auditResult = queryDB($audit);

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

				/* AUDIT TRAIL */
                                $audit = sprintf(
                                  'INSERT INTO audit_log_notifications_to_contacts(changed_by_username, db_operation, notification_id, contact_id)
                                   SELECT "\'%s\'", "INSERT-new", notification_id, contact_id
                                   FROM notifications_to_contacts WHERE notification_id=\'%s\' and contact_id=\'%s\'',
                                   $_SESSION['user'],
                                   $id,
                                   getContactID($user)
                                );
                                $auditResult = queryDB($audit);

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

				/* AUDIT TRAIL */
                                $audit = sprintf(
                                  'INSERT INTO audit_log_notifications_to_contactgroups(changed_by_username, db_operation, notification_id, contactgroup_id)
                                   SELECT "\'%s\'", "INSERT-new", notification_id, contactgroup_id
                                   FROM notifications_to_contactgroups WHERE notification_id=\'%s\' and contactgroup_id=\'%s\'',
                                   $_SESSION['user'],
                                   $id,
                                   prepareDBValue($group)
                                );
                                $auditResult = queryDB($audit);

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

				/* AUDIT TRAIL */
                                $audit = sprintf(
                                  'INSERT INTO audit_log_notifications_to_methods(changed_by_username, db_operation, notification_id, method_id)
                                   SELECT "\'%s\'", "INSERT-new", notification_id, method_id
                                   FROM notifications_to_methods WHERE notification_id=\'%s\' and method_id=\'%s\'',
                                   $_SESSION['user'],
                                   $id,
                                   prepareDBValue($methodID)
                                );
                                $auditResult = queryDB($audit);

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
	$customvariables_include = prepareDBValue($p['customvariables_include']);
	$customvariables_exclude = prepareDBValue($p['customvariables_exclude']);
        $notification_name = prepareDBValue($p['notification_name']);
        $notification_description = prepareDBValue($p['notification_description']);
	$notify_after_tries = prepareDBValue($p['notify_after_tries'][0]);
        $notify_on_ok = prepareDBValue((isset($p['notify_on_ok'][0]) && ($p['notify_on_ok'][0]) == 'on') ? 1 : 0);

        $notify_on_warning = prepareDBValue(
            ((isset($p['notify_on_warning'][0]) && ($p['notify_on_warning'][0]) == 'on') ? 1 : 0)
            | ((isset($p['notify_on_critical_to_warning'][0]) && ($p['notify_on_critical_to_warning'][0]) == 'on') ? 8 : 0)
            | ((isset($p['notify_on_unknown_to_warning'][0]) && ($p['notify_on_unknown_to_warning'][0]) == 'on') ? 16 : 0)
        );
        $notify_on_critical = prepareDBValue(
            ((isset($p['notify_on_critical'][0]) && ($p['notify_on_critical'][0]) == 'on') ? 1 : 0)
            | ((isset($p['notify_on_warning_to_critical'][0]) && ($p['notify_on_warning_to_critical'][0]) == 'on') ? 4 : 0)
            | ((isset($p['notify_on_unknown_to_critical'][0]) && ($p['notify_on_unknown_to_critical'][0]) == 'on') ? 16 : 0)
        );
        $notify_on_unknown = prepareDBValue(
            ((isset($p['notify_on_unknown'][0]) && ($p['notify_on_unknown'][0]) == 'on') ? 1 : 0)
            | ((isset($p['notify_on_warning_to_unknown'][0]) && ($p['notify_on_warning_to_unknown'][0]) == 'on') ? 4 : 0)
            | ((isset($p['notify_on_critical_to_unknown'][0]) && ($p['notify_on_critical_to_unknown'][0]) == 'on') ? 8 : 0)
        );
        $notify_on_host_up = prepareDBValue((isset($p['notify_on_host_up'][0]) && ($p['notify_on_host_up'][0]) == 'on') ? 1 : 0);
        $notify_on_host_down = prepareDBValue((isset($p['notify_on_host_down'][0]) && ($p['notify_on_host_down'][0]) == 'on') ? 1 : 0);
        $notify_on_host_unreachable = prepareDBValue((isset($p['notify_on_host_unreachable'][0]) && ($p['notify_on_host_unreachable'][0]) == 'on') ? 1 : 0);
        $notify_on_type_flappingstart = prepareDBValue((isset($p['notify_on_type_flappingstart'][0]) && ($p['notify_on_type_flappingstart'][0]) == 'on') ? 1 : 0);
        $notify_on_type_flappingstop = prepareDBValue((isset($p['notify_on_type_flappingstop'][0]) && ($p['notify_on_type_flappingstop'][0]) == 'on') ? 1 : 0);
        $notify_on_type_flappingdisabled = prepareDBValue((isset($p['notify_on_type_flappingdisabled'][0]) && ($p['notify_on_type_flappingdisabled'][0]) == 'on') ? 1 : 0);
        $notify_on_type_downtimestart = prepareDBValue((isset($p['notify_on_type_downtimestart'][0]) && ($p['notify_on_type_downtimestart'][0]) == 'on') ? 1 : 0);
        $notify_on_type_downtimeend = prepareDBValue((isset($p['notify_on_type_downtimeend'][0]) && ($p['notify_on_type_downtimeend'][0]) == 'on') ? 1 : 0);
        $notify_on_type_downtimecancelled = prepareDBValue((isset($p['notify_on_type_downtimecancelled'][0]) && ($p['notify_on_type_downtimecancelled'][0]) == 'on') ? 1 : 0);
        $notify_on_type_acknowledgement = prepareDBValue((isset($p['notify_on_type_acknowledgement'][0]) && ($p['notify_on_type_acknowledgement'][0]) == 'on') ? 1 : 0);
        $notify_on_type_custom = prepareDBValue((isset($p['notify_on_type_custom'][0]) && ($p['notify_on_type_custom'][0]) == 'on') ? 1 : 0);
	$let_notifier_handle = prepareDBValue((isset($p['let_notifier_handle']) && ($p['let_notifier_handle']) == 'on') ? 1 : 0);
	$rollover = prepareDBValue((isset($p['rollover']) && ($p['rollover']) == 'on') ? 1 : 0);
        $timeframe_id = prepareDBValue($p['timeframe']);
        $timezone_id = prepareDBValue($p['timezone']);


	// perform securicy checks
	if (!isAdmin()) {
		$dbResult = queryDB('select username from notifications where id=\'' . $id . '\'');
		if ($dbResult[0]['username'] != $owner) return false;
	}

	// update notification
	$query = sprintf(
		'UPDATE notifications SET username=\'%s\', notification_name=\'%s\', notification_description=\'%s\', recipients_include=\'%s\', recipients_exclude=\'%s\', hostgroups_include=\'%s\', hostgroups_exclude=\'%s\', hosts_include=\'%s\', hosts_exclude=\'%s\', servicegroups_include=\'%s\', servicegroups_exclude=\'%s\', services_include=\'%s\', services_exclude=\'%s\', customvariables_include=\'%s\', customvariables_exclude=\'%s\', notify_after_tries=\'%s\',on_ok=%d, on_warning=%d, on_unknown=%d, on_host_unreachable=%d, on_critical=%d, on_host_up=%d, on_host_down=%d, on_type_flappingstart=%d, on_type_flappingstop=%d, on_type_flappingdisabled=%d, on_type_downtimestart=%d, on_type_downtimeend=%d, on_type_downtimecancelled=%d, on_type_acknowledgement=%d, on_type_custom=%d, let_notifier_handle=%d, rollover=%d, timeframe_id=\'%s\', timezone_id=\'%s\' WHERE id=\'%s\';',
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
		$customvariables_include,
		$customvariables_exclude,
		$notify_after_tries,
		$notify_on_ok,
		$notify_on_warning,
		$notify_on_unknown,
		$notify_on_host_unreachable,
		$notify_on_critical,
		$notify_on_host_up,
		$notify_on_host_down,
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

        /* AUDIT TRAIL OF UPDATE ABOVE */
        $audit = sprintf(
                'INSERT INTO audit_log_notifications (changed_by_username, db_operation, id, notification_name, notification_description, active, username, recipients_include, recipients_exclude, hosts_include, hosts_exclude, hostgroups_include, hostgroups_exclude, services_include, services_exclude, servicegroups_include, servicegroups_exclude, customvariables_include, customvariables_exclude, notify_after_tries, let_notifier_handle, rollover, reloop_delay, on_ok, on_warning, on_unknown, on_host_unreachable, on_critical, on_host_up, on_host_down, on_type_problem, on_type_recovery, on_type_flappingstart, on_type_flappingstop, on_type_flappingdisabled, on_type_downtimestart, on_type_downtimeend, on_type_downtimecancelled, on_type_acknowledgement, on_type_custom, timezone_id, timeframe_id)
                        SELECT "\'%s\'", "UPDATE-rule", id, notification_name, notification_description, active, username, recipients_include, recipients_exclude, hosts_include, hosts_exclude, hostgroups_include, hostgroups_exclude, services_include, services_exclude, servicegroups_include, servicegroups_exclude, customvariables_include, customvariables_exclude, notify_after_tries, let_notifier_handle, rollover, reloop_delay, on_ok, on_warning, on_unknown, on_host_unreachable, on_critical, on_host_up, on_host_down, on_type_problem, on_type_recovery, on_type_flappingstart, on_type_flappingstop, on_type_flappingdisabled, on_type_downtimestart, on_type_downtimeend, on_type_downtimecancelled, on_type_acknowledgement, on_type_custom, timezone_id, timeframe_id
                        FROM notifications WHERE id=\'%s\'',
                $_SESSION['user'],
                $id
        );
        $auditResult = queryDB($audit);

	// delete old notification users
	/* AUDIT TRAIL */
        $audit = sprintf(
          'INSERT INTO audit_log_notifications_to_contacts(changed_by_username, db_operation, notification_id, contact_id)
           SELECT "\'%s\'", "DELETE-update", notification_id, contact_id
           FROM notifications_to_contacts WHERE notification_id=\'%s\' ',
           $_SESSION['user'],
           $id
        );
        $auditResult = queryDB($audit);

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

                                        /* AUDIT TRAIL */
                                        $audit = sprintf(
                                          'INSERT INTO audit_log_notifications_to_contacts (changed_by_username, db_operation, notification_id, contact_id)
                                           SELECT "\'%s\'", "INSERT-update", notification_id, contact_id
                                           FROM notifications_to_contacts WHERE notification_id=\'%s\' and contact_id=\'%s\'',
                                           $_SESSION['user'],
                                           $id,
                                           getContactID($user)
                                        );
                                        $auditResult = queryDB($audit);

                                }

                        }

		}

	}


	// delete old notitication groups
	/* AUDIT TRAIL */
        $audit = sprintf(
          'INSERT INTO audit_log_notifications_to_contactgroups(changed_by_username, db_operation, notification_id, contactgroup_id)
           SELECT "\'%s\'", "DELETE-update", notification_id, contactgroup_id
           FROM notifications_to_contactgroups WHERE notification_id=\'%s\'',
           $_SESSION['user'],
           $id
        );
        $auditResult = queryDB($audit);

	queryDB('delete from notifications_to_contactgroups where notification_id=\'' . $id . '\'');

	// add new groups
	if (isset($p['notify_groups'][0])) {

		if (is_array($p['notify_groups'][0]) && count($p['notify_groups'][0])) {

                        // Because of SQLite3, this needs to be split into several transactions.
                        foreach ($p['notify_groups'][0] as $group) {
                                if (!empty($group)){
					/* AUDIT TRAIL */
                                        $query = sprintf('insert into notifications_to_contactgroups (notification_id,contactgroup_id) values(\'%s\',\'%s\')', $id, prepareDBValue($group));
                                        queryDB($query);

                                        /* AUDIT TRAIL */
                                        $audit = sprintf(
                                          'INSERT INTO audit_log_notifications_to_contactgroups(changed_by_username, db_operation, notification_id, contactgroup_id)
                                           SELECT "\'%s\'", "INSERT-update", notification_id, contactgroup_id
                                           FROM notifications_to_contactgroups WHERE notification_id=\'%s\' and contactgroup_id=\'%s\'',
                                           $_SESSION['user'],
                                           $id,
                                           prepareDBValue($group)
                                        );
                                        $auditResult = queryDB($audit);

                                }

                        }

		}

	}


	// delete old notification methods
        /* AUDIT TRAIL */
        $audit = sprintf(
          'INSERT INTO audit_log_notifications_to_methods(changed_by_username, db_operation, notification_id, method_id)
           SELECT "\'%s\'", "DELETE-update", notification_id, method_id
           FROM notifications_to_methods WHERE notification_id=\'%s\'',
           $_SESSION['user'],
           $id
        );
        $auditResult = queryDB($audit);

	queryDB('delete from notifications_to_methods where notification_id=\'' . $id . '\'');

	// add notification methods
	if (isset($p['notify_by'][0])) {

		if (is_array($p['notify_by'][0]) && count($p['notify_by'][0])) {

			// Because of SQLite3, this has been split into several transactions.
			foreach ($p['notify_by'][0] as $methodID) {
				if (!empty($methodID)) {
					/* AUDIT TRAIL */
					$query = sprintf('insert into notifications_to_methods (notification_id,method_id) values(\'%s\',\'%s\')', $id, prepareDBValue($methodID));
		                        queryDB($query);

                                        /* AUDIT TRAIL */
                                        $audit = sprintf(
                                          'INSERT INTO audit_log_notifications_to_methods(changed_by_username, db_operation, notification_id, method_id)
                                           SELECT "\'%s\'", "INSERT-update", notification_id, method_id
                                           FROM notifications_to_methods WHERE notification_id=\'%s\' and method_id=\'%s\'',
                                           $_SESSION['user'],
                                           $id,
                                           prepareDBValue($methodID)
                                        );
                                        $auditResult = queryDB($audit);

				}

			}

		}

	}


	// BEGIN - handle escalations

	// delete escalations
	/* AUDIT TRAIL INSIDE FUNCTION */
	deleteEscalationsByNotificationId($id, 'update');

	// insert new escalations
	if (isset($p['escalation_count']) && is_array($p['escalation_count'])) {

		foreach ($p['escalation_count'] as $x) {

			// skip first notification
			if (!$x) continue;

			// add escalation
			$notify_after_tries = prepareDBValue($p['notify_after_tries'][$x]);

			$query = sprintf(
				'INSERT INTO escalations_contacts
					(notification_id, on_ok, on_warning, on_critical, on_unknown, on_host_up, on_host_unreachable, on_host_down, on_type_problem, on_type_recovery, on_type_flappingstart, on_type_flappingstop, on_type_flappingdisabled, on_type_downtimestart, on_type_downtimeend, on_type_downtimecancelled, on_type_acknowledgement, on_type_custom, notify_after_tries) 
					VALUES (\'%s\',0 , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, \'%s\');',
				$id,
                $notify_after_tries
			);
			queryDB($query);

			/* AUDIT TRAIL */
			$audit = sprintf(
				'INSERT INTO audit_log_escalations_contacts
                                        (changed_by_username, db_operation, notification_id, on_ok, on_warning, on_critical, on_unknown, on_host_up, on_host_unreachable, on_host_down, on_type_problem, on_type_recovery, on_type_flappingstart, on_type_flappingstop, on_type_flappingdisabled, on_type_downtimestart, on_type_downtimeend, on_type_downtimecancelled, on_type_acknowledgement, on_type_custom, notify_after_tries)
				SELECT "\'%s\'", "INSERT-update", notification_id, on_ok, on_warning, on_critical, on_unknown, on_host_up, on_host_unreachable, on_host_down, on_type_problem, on_type_recovery, on_type_flappingstart, on_type_flappingstop, on_type_flappingdisabled, on_type_downtimestart, on_type_downtimeend, on_type_downtimecancelled, on_type_acknowledgement, on_type_custom, notify_after_tries
				FROM escalations_contacts WHERE notification_id=\'%s\'',
				$_SESSION['user'],
                                $id
			);
			$auditResult = queryDB($audit);

			// get escalation id
			$query = sprintf(
				'SELECT id FROM escalations_contacts WHERE
					notification_id=\'%s\' and notify_after_tries=\'%s\'',
				$id,
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
			                foreach ($p['notify_users'][$x] as $notify_contact) {

				                if (!empty($notify_contact) and (prepareDBValue($notify_contact) != '')){

			                                $query = sprintf('INSERT INTO escalations_contacts_to_contacts (escalation_contacts_id,contacts_id) VALUES (\'%s\',\'%s\');', $eid, getContactID($notify_contact));
			                                queryDB($query);

                                                        /* AUDIT TRAIL */
                                                        $audit = sprintf(
                                                          'INSERT INTO audit_log_escalations_contacts_to_contacts(changed_by_username, db_operation, escalation_contacts_id, contacts_id)
                                                           SELECT "\'%s\'", "INSERT-update", escalation_contacts_id, contacts_id
                                                           FROM escalations_contacts_to_contacts WHERE escalation_contacts_id=\'%s\' and contacts_id=\'%s\'',
                                                           $_SESSION['user'],
                                                           $eid,
                                                           getContactID($notify_contact)
                                                        );
                                                        $auditResult = queryDB($audit);

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

							/* AUDIT TRAIL */
                                                        $audit = sprintf(
                                                          'INSERT INTO audit_log_escalations_contacts_to_contactgroups(changed_by_username, db_operation, escalation_contacts_id, contactgroup_id)
                                                           SELECT "\'%s\'", "INSERT-update", escalation_contacts_id, contactgroup_id
                                                           FROM escalations_contacts_to_contactgroups WHERE escalation_contacts_id=\'%s\' and contactgroup_id=\'%s\'',
                                                           $_SESSION['user'],
                                                           $eid,
                                                           prepareDBValue($groupID)
                                                        );
                                                        $auditResult = queryDB($audit);

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

							/* AUDIT TRAIL */
                                                        $audit = sprintf(
                                                          'INSERT INTO audit_log_escalations_contacts_to_methods(changed_by_username, db_operation, escalation_contacts_id, method_id)
                                                           SELECT "\'%s\'", "INSERT-update", escalation_contacts_id, method_id
                                                           FROM escalations_contacts_to_methods WHERE escalation_contacts_id=\'%s\' and method_id=\'%s\'',
                                                           $_SESSION['user'],
                                                           $eid,
                                                           prepareDBValue($methodID)
                                                        );
                                                        $auditResult = queryDB($audit);

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

                        /* AUDIT TRAIL OF UPDATE ABOVE */
                        $audit = sprintf(
                                'INSERT INTO audit_log_notifications (changed_by_username, db_operation, id, notification_name, notification_description, active, username, recipients_include, recipients_exclude, hosts_include, hosts_exclude, hostgroups_include, hostgroups_exclude, services_include, services_exclude, servicegroups_include, servicegroups_exclude, customvariables_include, customvariables_exclude, notify_after_tries, let_notifier_handle, rollover, reloop_delay, on_ok, on_warning, on_unknown, on_host_unreachable, on_critical, on_host_up, on_host_down, on_type_problem, on_type_recovery, on_type_flappingstart, on_type_flappingstop, on_type_flappingdisabled, on_type_downtimestart, on_type_downtimeend, on_type_downtimecancelled, on_type_acknowledgement, on_type_custom, timezone_id, timeframe_id)
                                        SELECT "\'%s\'", "UPDATE-active", id, notification_name, notification_description, active, username, recipients_include, recipients_exclude, hosts_include, hosts_exclude, hostgroups_include, hostgroups_exclude, services_include, services_exclude, servicegroups_include, servicegroups_exclude, customvariables_include, customvariables_exclude, notify_after_tries, let_notifier_handle, rollover, reloop_delay, on_ok, on_warning, on_unknown, on_host_unreachable, on_critical, on_host_up, on_host_down, on_type_problem, on_type_recovery, on_type_flappingstart, on_type_flappingstop, on_type_flappingdisabled, on_type_downtimestart, on_type_downtimeend, on_type_downtimecancelled, on_type_acknowledgement, on_type_custom, timezone_id, timeframe_id
                                        FROM notifications WHERE id=\'%s\'',
                                $_SESSION['user'],
                                $id
                        );
                        $auditResult = queryDB($audit);

		return false;
	}

	// toggle state
	$dbResult = queryDB('SELECT active FROM notifications WHERE id=\'' . $id . '\'');
	$active = '0';
	if ($dbResult[0]['active'] == '0') $active = '1';
	queryDB('UPDATE notifications SET active=\'' . $active . '\' WHERE id=\'' . $id . '\'');

        /* AUDIT TRAIL OF UPDATE ABOVE */
        $audit = sprintf(
                'INSERT INTO audit_log_notifications (changed_by_username, db_operation, id, notification_name, notification_description, active, username, recipients_include, recipients_exclude, hosts_include, hosts_exclude, hostgroups_include, hostgroups_exclude, services_include, services_exclude, servicegroups_include, servicegroups_exclude, customvariables_include, customvariables_exclude, notify_after_tries, let_notifier_handle, rollover, reloop_delay, on_ok, on_warning, on_unknown, on_host_unreachable, on_critical, on_host_up, on_host_down, on_type_problem, on_type_recovery, on_type_flappingstart, on_type_flappingstop, on_type_flappingdisabled, on_type_downtimestart, on_type_downtimeend, on_type_downtimecancelled, on_type_acknowledgement, on_type_custom, timezone_id, timeframe_id)
                        SELECT "\'%s\'", "UPDATE-active", id, notification_name, notification_description, active, username, recipients_include, recipients_exclude, hosts_include, hosts_exclude, hostgroups_include, hostgroups_exclude, services_include, services_exclude, servicegroups_include, servicegroups_exclude, customvariables_include, customvariables_exclude, notify_after_tries, let_notifier_handle, rollover, reloop_delay, on_ok, on_warning, on_unknown, on_host_unreachable, on_critical, on_host_up, on_host_down, on_type_problem, on_type_recovery, on_type_flappingstart, on_type_flappingstop, on_type_flappingdisabled, on_type_downtimestart, on_type_downtimeend, on_type_downtimecancelled, on_type_acknowledgement, on_type_custom, timezone_id, timeframe_id
                        FROM notifications WHERE id=\'%s\'',
                $_SESSION['user'],
                $id
        );
        $auditResult = queryDB($audit);

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

        /* AUDIT TRAIL OF DELETE BELOW */
        $audit = sprintf(
                'INSERT INTO audit_log_notifications (changed_by_username, db_operation, id, notification_name, notification_description, active, username, recipients_include, recipients_exclude, hosts_include, hosts_exclude, hostgroups_include, hostgroups_exclude, services_include, services_exclude, servicegroups_include, servicegroups_exclude, customvariables_include, customvariables_exclude, notify_after_tries, let_notifier_handle, rollover, reloop_delay, on_ok, on_warning, on_unknown, on_host_unreachable, on_critical, on_host_up, on_host_down, on_type_problem, on_type_recovery, on_type_flappingstart, on_type_flappingstop, on_type_flappingdisabled, on_type_downtimestart, on_type_downtimeend, on_type_downtimecancelled, on_type_acknowledgement, on_type_custom, timezone_id, timeframe_id)
                        SELECT "\'%s\'", "DELETE-rule", id, notification_name, notification_description, active, username, recipients_include, recipients_exclude, hosts_include, hosts_exclude, hostgroups_include, hostgroups_exclude, services_include, services_exclude, servicegroups_include, servicegroups_exclude, customvariables_include, customvariables_exclude, notify_after_tries, let_notifier_handle, rollover, reloop_delay, on_ok, on_warning, on_unknown, on_host_unreachable, on_critical, on_host_up, on_host_down, on_type_problem, on_type_recovery, on_type_flappingstart, on_type_flappingstop, on_type_flappingdisabled, on_type_downtimestart, on_type_downtimeend, on_type_downtimecancelled, on_type_acknowledgement, on_type_custom, timezone_id, timeframe_id
                        FROM notifications WHERE id=\'%s\'',
                $_SESSION['user'],
                $id
        );
        $auditResult = queryDB($audit);

        /* AUDIT TRAIL ON EVERY */
        $audit = sprintf(
                'INSERT INTO audit_log_notifications_to_methods (changed_by_username, db_operation, notification_id)
                 SELECT "\'%s\'", "DELETE-rule", notification_id
                 FROM notifications_to_methods where notification_id=\'%s\'',
                $_SESSION['user'],
                $id
        );
        $auditResult = queryDB($audit);

        $audit = sprintf(
                'INSERT INTO audit_log_notifications_to_contacts (changed_by_username, db_operation, notification_id)
                 SELECT "\'%s\'", "DELETE-rule", notification_id
                 FROM notifications_to_contacts where notification_id=\'%s\'',
                $_SESSION['user'],
                $id
        );
        $auditResult = queryDB($audit);

        $audit = sprintf(
                'INSERT INTO audit_log_notifications_to_contactgroups (changed_by_username, db_operation, notification_id)
                 SELECT "\'%s\'", "DELETE-rule", notification_id
                 FROM notifications_to_contactgroups where notification_id=\'%s\'',
                $_SESSION['user'],
                $id
        );
        $auditResult = queryDB($audit);

	queryDB('DELETE FROM notifications WHERE id=\'' . $id . '\'');
	queryDB('DELETE FROM notifications_to_methods WHERE notification_id=\'' . $id . '\'');
	queryDB('DELETE FROM notifications_to_contacts WHERE notification_id=\'' . $id . '\'');
	queryDB('DELETE FROM notifications_to_contactgroups WHERE notification_id=\'' . $id . '\'');

	deleteEscalationsByNotificationId($id, 'rule');

}




/**
 * deleteEscalationsByNotificationId - deletes escalations related to a notification
 *
 * @param		integer		$id		related notification id
 * @param               string          $operation      what type of operation that calls it (update rule or delete rule)
 * @return		none
 */
function deleteEscalationsByNotificationId ($id, $operation) {

	// get escalation_ids
	$dbResult = queryDB('SELECT id FROM escalations_contacts WHERE notification_id=\'' . $id . '\'');

	if (count($dbResult)) {

		// create where statement
		$where = null;
		$sep = null;
		foreach($dbResult as $row) {
			$where .= $sep . 'escalation_contacts_id=\'' . $row['id'] . '\'';
			if (!$sep) $sep = ' or ';

			/* AUDIT TRAIL ON EVERY ID TO BE DELETED */
                        $audit = sprintf(
                                'INSERT INTO audit_log_escalations_contacts_to_methods (changed_by_username, db_operation, escalation_contacts_id)
                                 SELECT "\'%s\'", "DELETE-%s", escalation_contacts_id
                                 FROM escalations_contacts_to_methods where escalation_contacts_id=\'%s\'',
                                $_SESSION['user'],
				$operation,
                                $row['id']
                        );
                        $auditResult = queryDB($audit);

                        $audit = sprintf(
                                'INSERT INTO audit_log_escalations_contacts_to_contacts (changed_by_username, db_operation, escalation_contacts_id)
                                 SELECT "\'%s\'", "DELETE-%s", escalation_contacts_id
                                 FROM escalations_contacts_to_contacts where escalation_contacts_id=\'%s\'',
                                $_SESSION['user'],
				$operation,
                                $row['id']
                        );
                        $auditResult = queryDB($audit);

                        $audit = sprintf(
                                'INSERT INTO audit_log_escalations_contacts_to_contactgroups (changed_by_username, db_operation, escalation_contacts_id)
                                 SELECT "\'%s\'", "DELETE-%s", escalation_contacts_id
                                 FROM escalations_contacts_to_contactgroups where escalation_contacts_id=\'%s\'',
                                $_SESSION['user'],
				$operation,
                                $row['id']
                        );
                        $auditResult = queryDB($audit);

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

	/* AUDIT TRAIL ON ID TO BE DELETED */
	$audit = sprintf(
                'INSERT INTO audit_log_escalations_contacts
                 (changed_by_username, db_operation, notification_id, on_ok, on_warning, on_critical, on_unknown, on_host_up, on_host_unreachable, on_host_down, on_type_problem, on_type_recovery, on_type_flappingstart, on_type_flappingstop, on_type_flappingdisabled, on_type_downtimestart, on_type_downtimeend, on_type_downtimecancelled, on_type_acknowledgement, on_type_custom, notify_after_tries)
                 SELECT "\'%s\'", "DELETE-esc", notification_id, on_ok, on_warning, on_critical, on_unknown, on_host_up, on_host_unreachable, on_host_down, on_type_problem, on_type_recovery, on_type_flappingstart, on_type_flappingstop, on_type_flappingdisabled, on_type_downtimestart, on_type_downtimeend, on_type_downtimecancelled, on_type_acknowledgement, on_type_custom, notify_after_tries
                 FROM escalations_contacts WHERE notification_id=\'%s\'',
                $_SESSION['user'],
	        $eid
        );
        $auditResult = queryDB($audit);

	$audit = sprintf(
			'INSERT INTO audit_log_escalations_contacts_to_methods (changed_by_username, db_operation, escalation_contacts_id)
			 SELECT "\'%s\'", "DELETE-esc", escalation_contacts_id
			 FROM escalations_contacts_to_methods where escalation_contacts_id=\'%s\'',
			$_SESSION['user'],
			$eid
	);
	$auditResult = queryDB($audit);

	$audit = sprintf(
			'INSERT INTO audit_log_escalations_contacts_to_contacts (changed_by_username, db_operation, escalation_contacts_id)
			 SELECT "\'%s\'", "DELETE-esc", escalation_contacts_id
			 FROM escalations_contacts_to_contacts where escalation_contacts_id=\'%s\'',
			$_SESSION['user'],
			$eid
	);
	$auditResult = queryDB($audit);

	$audit = sprintf(
			'INSERT INTO audit_log_escalations_contacts_to_contactgroups (changed_by_username, db_operation, escalation_contacts_id)
			 SELECT "\'%s\'", "DELETE-esc", escalation_contacts_id
			 FROM escalations_contacts_to_contactgroups where escalation_contacts_id=\'%s\'',
			$_SESSION['user'],
			$eid
	);
	$auditResult = queryDB($audit);

	queryDB('DELETE FROM escalations_contacts WHERE id=\'' . $eid . '\'');
	queryDB('DELETE FROM escalations_contacts_to_contacts WHERE escalation_contacts_id=\'' . $eid . '\'');
	queryDB('DELETE FROM escalations_contacts_to_contactgroups WHERE escalation_contacts_id=\'' . $eid . '\'');
	queryDB('DELETE FROM escalations_contacts_to_methods WHERE escalation_contacts_id=\'' . $eid . '\'');

	return true;

}
	

?>
