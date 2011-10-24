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
 * authenticateUser - call authenticatian, depending on defined method and set session user
 *
 * @param		none
 * @return		none
 */
function authenticateUser () {

	global $authentication_type;

	$auth = null;

	switch ($authentication_type) {

		case 'native':
			$auth = authenticate_NATIVE($_POST['username'], $_POST['password']);
			if ($auth) $_SESSION['user'] = $_POST['username'];
			break;

		case 'ldap':
			$auth = authenticate_LDAP($_POST['username'], $_POST['password']);
			if (!$auth) $_SESSION['user'] = $_POST['username'];
			break;

		case 'http':
			global $http;
			$user = $_SERVER['REMOTE_USER'];
			if ($http['username_is_email']) {
				$user = preg_replace('/@.*/', '', $user);
			}
			$_SESSION['user'] = $user;
			break;

	}

	if ($auth || $authentication_type == 'http') {
		$_SESSION['remote_addr'] = $_SERVER['REMOTE_ADDR'];
		$_SESSION['user_agent'] = $_SERVER['HTTP_USER_AGENT'];
	}
	
}




/**
 * userExists - check the local database for a certain user
 *
 * @param	string		$username		name of user to search for in the local database
 * @return	boolean						true if user has been found exactly once else false
 */
function userExists ($username) {

	$query = sprintf(
		'select count(*) as cnt from contacts where username=\'%s\'',
		prepareDBValue($username)
	);
	$dbResult = queryDB($query);

	if ($dbResult[0]['cnt'] == '1') return true;

	return false;

}




/**
 * getAuthUser - try to determine name of authenticated user
 *
 * @param		none
 * @return		name of authenticated user
 */
function getAuthUser () {

	global $authentication_type;

	$authUser = null;

	switch ($authentication_type) { 

		case 'ldap':
		case 'native':
			if (array_key_exists('user', $_SESSION)) {
				$authUser = $_SESSION['user'];
			}
			break;

		case 'http':
			global $http;
			$authUser = $_SERVER['REMOTE_USER'];
			if ($http['username_is_email']) {
				$authUser = preg_replace('/@.*/', '', $authUser);
			}
			if ($http['check_local_user'] && !userExists($authUser)) {
				$authUser = null;
			}
			break;

	}

	return $authUser;

}
	



/**
 * authenticate_NATIVE - authenticate via internal contacts table
 *
 * @param		string		$user		username for authentication
 * @param		string		$password	password for authentication
 * @return								boolean value (true on success)
 */
function authenticate_NATIVE ($user, $password) {

	//workaround for SQLite's lack of crypt functions.
	//$password=sha1($password);
	$password=sha1($_POST['password']);
	// print($password);
	$query = sprintf(
		'select id from contacts where username=\'%s\' and password=\'%s\'',
		prepareDBValue($_POST['username']),
		prepareDBValue($password)
	);
	$dbResult = queryDB($query);

	if (isset($dbResult[0]['id'])) return true;

	return false;

}




/**
 * authenticate_LDAP - authenticate via LDAP
 *
 * @param		string		$user		username for authentication
 * @param		string		$password	password for authentication
 * @return								integer value
 *
 * return codes:
 *  0: successful
 *  1: can't connect to server
 *  2: can't bind w/ dir_user
 *  3: can't search directory
 *  4: user not found
 *  5: user credentials are wrong
 */
function authenticate_LDAP ($user, $password) {

	// address of domain controller
	global $ldap;

	// connect to server
	if (!($connect = @ldap_connect($ldap['server']))) return 1;

	// active-directory specific settings
	ldap_set_option($connect, LDAP_OPT_PROTOCOL_VERSION, $ldap['version']);
	ldap_set_option($connect, LDAP_OPT_REFERRALS, 0);

	// bind to server
	if (!($bind = @ldap_bind($connect, $ldap['dir_user'], $ldap['dir_password']))) {
		@ldap_close($connect);
		return 2;
	}

	// set ldap filter
	if (strstr($ldap['filter'], '###USER###') !== false) {
		$user_tmp = str_replace(array('(', ')', '|', '&'), array('', '', '', ''), $user);
		$filter = str_replace('###USER###', $user_tmp, $ldap['filter']);
	} else {
		$filter = $ldap['filter'];
	}
	

	// get entries
	if (!($search = @ldap_search($connect, $ldap['base_dn'], $filter))) {
		@ldap_close($connect);
		return 3;
	}
	$info = ldap_get_entries($connect, $search);

	// search entries for user
	$user_dn = null;
	foreach ($info as $key => $value) {
		if ($info[$key][$ldap['key_find_user']][0] == $user) {
			$user_dn = $info[$key][$ldap['key_set_user']][0];
		}
	}
	if (!$user_dn) {
		@ldap_close($connect);
		return 4;
	}

	// bind to server w/ user credentials
	if (!($bind = @ldap_bind($connect, $user_dn, $password))) {
		@ldap_close($connect);
		return 5;
	}

	// success
	@ldap_close($connect);
	return 0;

}

?>
