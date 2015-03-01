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
 * addContact - adds a new contact
 *
 * @param		array		$p		posted data for new contact
 * @return		string				message
 */
function addContact ($p) {

	global $authentication_type;

	// security check
	if (!checkContactsMod()) return CONTACTS_ADD_UPDATE_ERROR_INSUFF_RIGHTS;

	// prepare data
	$admin = (isset($p['admin']) && $p['admin'] == 'on') ? '1' : '0';
	$username = prepareDBValue(trim($p['new_user']));
	$full_name = prepareDBValue(trim($p['full_name']));
	$email = prepareDBValue($p['email']);
	$phone = prepareDBValue($p['phone']);
	$mobile = prepareDBValue($p['mobile']);
	$growladdress = prepareDBValue($p['growladdress']);
	$timeframe_id = prepareDBValue($p['timeframe']);
	$timezone_id = prepareDBValue($p['timezone']);
	$restrict_alerts = prepareDBValue((isset($p['restrict_alerts']) && $p['restrict_alerts'] == 'on') ? '1' : '0');
        $growl_registration = ((isset($p['growl_register']) && $p['growl_register'] == 'on') ? registerWithGrowl($growladdress) : null);
	$passwordMask = "";

	// check whether contact already exists
	$query = sprintf(
		'select id from contacts where username=\'%s\' and admin=\'%s\' and full_name=\'%s\' and email=\'%s\' and phone=\'%s\' and mobile=\'%s\' and growladdress=\'%s\' and timeframe_id=\'%s\' and timezone_id=\'%s\'',
		$username,
		$admin,
		$full_name,
		$email,
		$phone,
		$mobile,
		$growladdress,
		$timeframe_id,
		$timezone_id
	);
	$dbResult = queryDB($query);
	if (!empty($dbResult[0]['id'])) return CONTACTS_ADD_USER_EXISTS;

	// we need a Username otherwise things don't look pretty
	if (empty($full_name)) return CONTACTS_ADD_UPDATE_NAME_MISSING;

	// native authentication
	$password = null;
	if ($authentication_type == 'native') {

		if (!isset($_POST['password']) || !isset($_POST['password_verify'])) return CONTACTS_ADD_UPDATE_PASSWD_MISSING;
		if (empty($_POST['password']) || empty($_POST['password_verify'])) return CONTACTS_ADD_UPDATE_PASSWD_MISSING;
		if ($_POST['password'] != $_POST['password_verify']) return CONTACTS_ADD_UPDATE_ERROR_PASSWD_MISMATCH;

		$passwordMask = ',password';

		//$password = ',sha1(\'' . prepareDBValue($_POST['password']) . '\')';
		// Because of SQLite which doesnt have native crypto, this needs to be done via PHP.
                $password = sha1(prepareDBValue($_POST['password']));
		$password = ',\''.prepareDBValue($password).'\'';

	}


	// add contact
	$query = sprintf(
		'insert into contacts (username,admin,full_name,email,phone,mobile,growladdress,timeframe_id,timezone_id,restrict_alerts%s)
			values (\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\'%s)',
		$passwordMask,
		$username,
		$admin,
		$full_name,
		$email,
		$phone,
		$mobile,
		$growladdress,
		$timeframe_id,
		$timezone_id,
		$restrict_alerts,
		$password
	);
	queryDB($query);


	// get contact's ID
	$query = sprintf(
		'select id from contacts where username=\'%s\' and admin=\'%s\' and full_name=\'%s\' and email=\'%s\' and phone=\'%s\' and mobile=\'%s\' and growladdress=\'%s\' and timeframe_id=\'%s\' and timezone_id=\'%s\'',
		$username,
		$admin,
		$full_name,
		$email,
		$phone,
		$mobile,
		$growladdress,
		$timeframe_id,
		$timezone_id
	);
	$dbResult = queryDB($query);
	if (empty($dbResult[0]['id'])) return CONTACTS_ADD_ADDED_BUT_NOT_IN_DB;

        /* AUDIT TRAIL OF NEW CONTACT */
        $audit = sprintf(
                        'INSERT INTO audit_log_contacts (changed_by_username, db_operation, admin, full_name, email, phone, mobile, growladdress, timeframe_id,  timezone_id, restrict_alerts, username, password, section, id)
                         SELECT "\'%s\'", "INSERT-new", admin, full_name, email, phone, mobile, growladdress, timeframe_id,  timezone_id, restrict_alerts, username, password, section, id
                         FROM contacts where id=\'%s\'',
                        $_SESSION['user'],
                        $dbResult[0]['id']
        );
        $auditResult = queryDB($audit);

	// add holidays
	if (!empty($p['holiday_name']) && !empty($p['holiday_start']) && !empty($p['holiday_end'])) {
		addCHolidays($dbResult[0]['id'], $p['holiday_name'], $p['holiday_start'], $p['holiday_end']);
	}


	return CONTACTS_ADDED;

}




/**
 * updateContact - updates an existing contact
 *
 * @param		array		$p		posted data for contact update
 * @return		string				message
 */
function updateContact ($p) {

	global $authentication_type;

	// prepare data
	$id = prepareDBValue($p['id']);
	if (!$id) return CONTACTS_ADD_UPDATE_ERROR_INSUFF_RIGHTS;

	// security check
	if (!checkContactsMod($p['id'])) return CONTACTS_ADD_UPDATE_ERROR_INSUFF_RIGHTS;

	// password updates?
	$password = null;
	if (isset($_POST['password']) && !empty($_POST['password'])) {

		if ($_POST['password'] != $_POST['password_verify']) return CONTACTS_ADD_UPDATE_ERROR_PASSWD_MISMATCH;

                // Because of SQLite which doesnt have native crypto, this needs to be done via PHP.
                $password = sha1($_POST['password']);
                $password = ', password=\''.prepareDBValue($password).'\'';

	}

	// prepare data
	$admin = (isset($p['admin']) && $p['admin'] == 'on') ? '1' : '0';
	$full_name = prepareDBValue($p['full_name']);
	$email = prepareDBValue($p['email']);
	$phone = prepareDBValue($p['phone']);
	$mobile = prepareDBValue($p['mobile']);
        $growladdress = prepareDBValue($p['growladdress']);
	$timeframe_id = prepareDBValue($p['timeframe']);
	$timezone_id = prepareDBValue($p['timezone']);
	$restrict_alerts = prepareDBValue((isset($p['restrict_alerts']) && $p['restrict_alerts'] == 'on') ? '1' : '0');
        $growl_registration = ((isset($p['growl_register']) && $p['growl_register'] == 'on') ? registerWithGrowl($growladdress) : null);

	// update contact
	$query = sprintf(
		'update contacts set admin=\'%s\', full_name=\'%s\', email=\'%s\', phone=\'%s\', mobile=\'%s\', growladdress=\'%s\', timeframe_id=\'%s\', timezone_id=\'%s\', restrict_alerts=\'%s\'%s where id=\'%s\'',
		$admin,
		$full_name,
		$email,
		$phone,
		$mobile,
		$growladdress,
		$timeframe_id,
		$timezone_id,
		$restrict_alerts,
		$password,
		$id
	);
	queryDB($query);

	/* AUDIT TRAIL OF UPDATED CONTACT */
        $audit = sprintf(
                        'INSERT INTO audit_log_contacts (changed_by_username, db_operation, admin, full_name, email, phone, mobile, growladdress, timeframe_id,  timezone_id, restrict_alerts, username, password, section, id)
                         SELECT "\'%s\'", "UPDATE-contact", admin, full_name, email, phone, mobile, growladdress, timeframe_id,  timezone_id, restrict_alerts, username, password, section, id
                         FROM contacts where id=\'%s\'',
                        $_SESSION['user'],
                        $id
        );
        $auditResult = queryDB($audit);


	// delete holidays
	if (isset($p['del_holiday']) && is_array($p['del_holiday'])) {

		$query = 'delete from holidays where (';
		$sep = null;
		foreach ($p['del_holiday'] as $key => $value) {
			$query .= $sep . 'id=\'' . prepareDBValue($key) . '\'';
			if (!$sep) $sep = ' or ';

                        /* AUDIT TRAIL */
                        $audit = sprintf(
                                 'INSERT INTO audit_log_holidays (changed_by_username, db_operation, contact_id, holiday_name, holiday_start, holiday_end, id)
                                  SELECT "\'%s\'", "DELETE-update", contact_id, holiday_name, holiday_start, holiday_end, id
                                  FROM holidays where contact_id=\'%s\' and id=\'%s\'',
                                  $_SESSION['user'],
                                  $id,
                                  prepareDBValue($key)
                         );
                         $auditResult = queryDB($audit);

		}
		$query .= ') and contact_id=\'' . $id . '\'';
		queryDB($query);

	}


	// add holidays
	if (!empty($p['holiday_name']) && !empty($p['holiday_start']) && !empty($p['holiday_end'])) {
		addCHolidays($id, $p['holiday_name'], $p['holiday_start'], $p['holiday_end']);
	}


	return CONTACTS_UPDATED;

}




/**
 * delContact - deletes a contact and sets all owned notifications to disabled
 *
 * @param		array		$p		posted data for contact update
 * @return							boolean value (false on error)
 */
function delContact ($p) {

	// pre checks
	if (!isAdmin()) return false;
	if (!isset($p['user'])) return false;
	if (empty($p['user'])) return false;

	// security
	$userPrep = prepareDBValue($p['user']);

	// get contact id
	$dbResult = queryDB('select id from contacts where username=\'' . $userPrep . '\'');
	if (!isset($dbResult[0]['id'])) return false;
	$userID = $dbResult[0]['id'];

	// delete all notifications assigned to the posted contact

        /* AUDIT TRAIL */
        $dbResultCount = queryDB('select notification_id from notifications_to_contacts where contact_id=\'' . $userID . '\'');

        if (count($dbResultCount)) {

                foreach($dbResultCount as $row) {

                        $audit = sprintf(
                          'INSERT INTO audit_log_notifications_to_contacts(changed_by_username, db_operation, notification_id, contact_id)
                           SELECT "\'%s\'", "DELETE-contact", notification_id, contact_id
                           FROM notifications_to_contacts WHERE notification_id=\'%s\' and contact_id=\'%s\'',
                           $_SESSION['user'],
                           $row['notification_id'],
                           $userID
                        );
                        $auditResult = queryDB($audit);
                }

        }

	queryDB('delete from notifications_to_contacts where contact_id=\'' . $userID . '\'');

        // disable all notifications and change usernames of all notifications owned by this user
        /* AUDIT TRAIL */
        $dbResultCount = queryDB('select id from notifications where username=\'' . $userPrep . '\'' );

        if (count($dbResultCount)) {

                foreach($dbResultCount as $row) {

                        /* AUDIT TRAIL OF UPDATE ABOVE */
                        $audit = sprintf(
                                'INSERT INTO audit_log_notifications (changed_by_username, db_operation, id, notification_name, notification_description, active, username, recipients_include, recipients_exclude, hosts_include, hosts_exclude, hostgroups_include, hostgroups_exclude, services_include, services_exclude, servicegroups_include, servicegroups_exclude, customvariables_include, customvariables_exclude, notify_after_tries, let_notifier_handle, rollover, reloop_delay, on_ok, on_warning, on_unknown, on_host_unreachable, on_critical, on_host_up, on_host_down, on_type_problem, on_type_recovery, on_type_flappingstart, on_type_flappingstop, on_type_flappingdisabled, on_type_downtimestart, on_type_downtimeend, on_type_downtimecancelled, on_type_acknowledgement, on_type_custom, timezone_id, timeframe_id)
                                        SELECT "\'%s\'", "UPDATE-owner", id, notification_name, notification_description, active, username, recipients_include, recipients_exclude, hosts_include, hosts_exclude, hostgroups_include, hostgroups_exclude, services_include, services_exclude, servicegroups_include, servicegroups_exclude, customvariables_include, customvariables_exclude, notify_after_tries, let_notifier_handle, rollover, reloop_delay, on_ok, on_warning, on_unknown, on_host_unreachable, on_critical, on_host_up, on_host_down, on_type_problem, on_type_recovery, on_type_flappingstart, on_type_flappingstop, on_type_flappingdisabled, on_type_downtimestart, on_type_downtimeend, on_type_downtimecancelled, on_type_acknowledgement, on_type_custom, timezone_id, timeframe_id
                                        FROM notifications WHERE id=\'%s\'',
                                $_SESSION['user'],
                                $row['id']
                        );
                        $auditResult = queryDB($audit);

                }

        }

	queryDB('update notifications set active=\'0\', username=\'' . prepareDBValue('[' . $p['user'] . ']') . '\' where username=\'' . $userPrep . '\'');

        // delete the user from escalations_contacts_to_contacts
        /* AUDIT TRAIL */
        $dbResultCount = queryDB('select escalation_contacts_id from escalations_contacts_to_contacts where contacts_id=\'' . $userID . '\'');

        if (count($dbResultCount)) {

                foreach($dbResultCount as $row) {

                $audit = sprintf(
                                'INSERT INTO audit_log_escalations_contacts_to_contacts (changed_by_username, db_operation, escalation_contacts_id, contacts_id)
                                 SELECT "\'%s\'", "DELETE-contact", escalation_contacts_id, contacts_id
                                 FROM escalations_contacts_to_contacts WHERE contacts_id=\'%s\' and escalation_contacts_id=\'%s\'',
                                $_SESSION['user'],
                                $userID,
                                $row['escalation_contacts_id']
                );
                $auditResult = queryDB($audit);

                }

        }
        queryDB('delete from escalations_contacts_to_contacts where contacts_id=\'' . $userID . '\'');


        // delete the user from contactgroups
        /* AUDIT TRAIL */
        $dbResultCount = queryDB('select contactgroup_id from contactgroups_to_contacts where contact_id=\'' . $userID . '\'');

        if (count($dbResultCount)) {

                foreach($dbResultCount as $row) {

                $audit = sprintf(
                                'INSERT INTO audit_log_contactgroups_to_contacts (changed_by_username, db_operation, contactgroup_id, contact_id)
                                 SELECT "\'%s\'", "DELETE-contact", contactgroup_id, contact_id
                                 FROM contactgroups_to_contacts WHERE contact_id=\'%s\' and contactgroup_id=\'%s\'',
                                $_SESSION['user'],
                                $userID,
                                $row['contactgroup_id']
                );
                $auditResult = queryDB($audit);

                }

        }
        queryDB('delete from contactgroups_to_contacts where contact_id=\'' . $userID . '\'');

        // finally, delete the user
        /* AUDIT TRAIL */
        $audit = sprintf(
                        'INSERT INTO audit_log_contacts (changed_by_username, db_operation, admin, full_name, email, phone, mobile, growladdress, timeframe_id,  timezone_id, restrict_alerts, username, password, section, id)
                         SELECT "\'%s\'", "DELETE-contact", admin, full_name, email, phone, mobile, growladdress, timeframe_id,  timezone_id, restrict_alerts, username, password, section, id
                         FROM contacts WHERE id=\'%s\'',
                        $_SESSION['user'],
                        $userID
        );

	queryDB('delete from contacts where id=\'' . $userID . '\'');

	return true;

}




/**
 * checkContactsMod - checks whether a user may add or edit a contact
 *
 * @param		string		$id			user id to check (optional)
 * @return								boolean value (false on error)
 */
function checkContactsMod ($id = null) {

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
 * addCHolidays - adds holidays for a certain contact
 *
 * @param		integer			$contact_id	contact's ID
 * @param		string			$holiday_start	start of holidays
 * @param		string			$holiday_end	end of holidays
 * @return									boolean value (false on error)
 */
function addCHolidays ($contact_id, $holiday_name, $holiday_start, $holiday_end) {

	// prepare data
        $holiday_name = prepareDBValue($holiday_name);
	$holiday_start = prepareDBValue($holiday_start);
	$holiday_end = prepareDBValue($holiday_end);

	// check whether holidays exist
	$query =  sprintf(
		'select count(*) as cnt from holidays where contact_id=\'%s\' and holiday_name=\'%s\' and holiday_start=\'%s\' and holiday_end=\'%s\'',
		$contact_id,
                $holiday_name,
		$holiday_start,
		$holiday_end
	);
	$dbResult = queryDB($query);
	if ($dbResult[0]['cnt'] != '0') return false;

	// add holidays
	$query = sprintf(
		'insert into holidays (contact_id,holiday_name,holiday_start,holiday_end) values (\'%s\',\'%s\',\'%s\',\'%s\')',
		$contact_id,
                $holiday_name,
		$holiday_start,
		$holiday_end
	);
	queryDB($query);

	/* AUDIT TRAIL */
	$audit = sprintf(
			'INSERT INTO audit_log_holidays (changed_by_username, db_operation, contact_id, holiday_name, holiday_start, holiday_end)
			 SELECT "\'%s\'", "INSERT-new", contact_id,holiday_name,holiday_start,holiday_end
			 FROM holidays where contact_id=\'%s\'',
			$_SESSION['user'],
			$contact_id
	);
	$auditResult = queryDB($audit);

	return true;

}


?>
