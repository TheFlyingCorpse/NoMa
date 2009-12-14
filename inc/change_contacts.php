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
	$username = prepareDBValue($p['new_user']);
	$first_name = prepareDBValue($p['first_name']);
	$last_name = prepareDBValue($p['last_name']);
	$email = prepareDBValue($p['email']);
	$phone = prepareDBValue($p['phone']);
	$mobile = prepareDBValue($p['mobile']);
	$time_period_id = prepareDBValue($p['timeperiod']);
	$timezone_id = prepareDBValue($p['timezone']);
	$restrict_alerts = prepareDBValue((isset($p['restrict_alerts']) && $p['restrict_alerts'] == 'on') ? '1' : '0');
	$passwordMask = "";

	// check whether contact already exists
	$query = sprintf(
		'select id from contacts where username=\'%s\' and admin=\'%s\' and first_name=\'%s\' and last_name=\'%s\' and email=\'%s\' and phone=\'%s\' and mobile=\'%s\' and time_period_id=\'%s\' and timezone_id=\'%s\'',
		$username,
		$admin,
		$first_name,
		$last_name,
		$email,
		$phone,
		$mobile,
		$time_period_id,
		$timezone_id
	);
	$dbResult = queryDB($query);
	if (!empty($dbResult[0]['id'])) return CONTACTS_ADD_USER_EXISTS;


	// native authentication
	$password = null;
	if ($authentication_type == 'native') {

		if (!isset($_POST['password']) || !isset($_POST['password_verify'])) return CONTACTS_ADD_UPDATE_PASSWD_MISSING;
		if (empty($_POST['password']) || empty($_POST['password_verify'])) return CONTACTS_ADD_UPDATE_PASSWD_MISSING;
		if ($_POST['password'] != $_POST['password_verify']) return CONTACTS_ADD_UPDATE_ERROR_PASSWD_MISMATCH;

		$passwordMask = ',password';
		$password = ',sha1(\'' . prepareDBValue($_POST['password']) . '\')';

	}


	// add contact
	$query = sprintf(
		'insert into contacts (username,admin,first_name,last_name,email,phone,mobile,time_period_id,timezone_id,restrict_alerts%s)
			values (\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\'%s)',
		$passwordMask,
		$username,
		$admin,
		$first_name,
		$last_name,
		$email,
		$phone,
		$mobile,
		$time_period_id,
		$timezone_id,
		$restrict_alerts,
		$password
	);
	queryDB($query);


	// get contact's ID
	$query = sprintf(
		'select id from contacts where username=\'%s\' and admin=\'%s\' and first_name=\'%s\' and last_name=\'%s\' and email=\'%s\' and phone=\'%s\' and mobile=\'%s\' and time_period_id=\'%s\' and timezone_id=\'%s\'',
		$username,
		$admin,
		$first_name,
		$last_name,
		$email,
		$phone,
		$mobile,
		$time_period_id,
		$timezone_id
	);
	$dbResult = queryDB($query);
	if (!empty($dbResult[0]['id'])) return CONTACTS_ADD_ADDED_BUT_NOT_IN_DB;



	// add holidays
	if (!empty($p['holiday_start']) && !empty($p['holiday_end'])) {
		addHolidays($dbResult[0]['id'], $p['holiday_start'], $p['holiday_end']);
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

		$password = ', password=sha1(\'' . prepareDBValue($_POST['password']) . '\')';

	}

	// prepare data
	$admin = (isset($p['admin']) && $p['admin'] == 'on') ? '1' : '0';
	$first_name = prepareDBValue($p['first_name']);
	$last_name = prepareDBValue($p['last_name']);
	$email = prepareDBValue($p['email']);
	$phone = prepareDBValue($p['phone']);
	$mobile = prepareDBValue($p['mobile']);
	$time_period_id = prepareDBValue($p['timeperiod']);
	$timezone_id = prepareDBValue($p['timezone']);
	$restrict_alerts = prepareDBValue((isset($p['restrict_alerts']) && $p['restrict_alerts'] == 'on') ? '1' : '0');

	// update contact
	$query = sprintf(
		'update contacts set admin=\'%s\', first_name=\'%s\', last_name=\'%s\', email=\'%s\', phone=\'%s\', mobile=\'%s\', time_period_id=\'%s\', timezone_id=\'%s\', restrict_alerts=\'%s\'%s where id=\'%s\'',
		$admin,
		$first_name,
		$last_name,
		$email,
		$phone,
		$mobile,
		$time_period_id,
		$timezone_id,
		$restrict_alerts,
		$password,
		$id
	);
	queryDB($query);


	// delete holidays
	if (isset($p['del_holiday']) && is_array($p['del_holiday'])) {

		$query = 'delete from holidays where (';
		$sep = null;
		foreach ($p['del_holiday'] as $key => $value) {
			$query .= $sep . 'id=\'' . prepareDBValue($key) . '\'';
			if (!$sep) $sep = ' or ';
		}
		$query .= ') and contact_id=\'' . $id . '\'';
		queryDB($query);

	}


	// add holidays
	if (!empty($p['holiday_start']) && !empty($p['holiday_end'])) {
		addHolidays($id, $p['holiday_start'], $p['holiday_end']);
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
	queryDB('delete from notifications_to_contacts where contact_id=\'' . $userID . '\'');

	// disable all notifications and change usernames of all notifications owned by this user
	queryDB('update notifications set active=\'0\', username=\'' . prepareDBValue('[' . $p['user'] . ']') . '\' where username=\'' . $userPrep . '\'');

	// finally, delete the user
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
 * addHolidays - adds holidays for a certain contact
 *
 * @param		integer			$id			contact's ID
 * @param		string			$start		start of holidays
 * @param		string			$end		end of holidays
 * @return									boolean value (false on error)
 */
function addHolidays ($id, $start, $end) {

	// prepare data
	$start = prepareDBValue($start);
	$end = prepareDBValue($end);

	// check whether holidays exist
	$query =  sprintf(
		'select count(*) cnt from holidays where contact_id=\'%s\' and start=\'%s\' and end=\'%s\'',
		$id,
		$start,
		$end
	);
	$dbResult = queryDB($query);
	if ($dbResult[0]['cnt'] != '0') return false;

	// add holidays
	$query = sprintf(
		'insert into holidays (contact_id,start,end) values (\'%s\',\'%s\',\'%s\')',
		$id,
		$start,
		$end
	);
	queryDB($query);

	return true;

}


?>
