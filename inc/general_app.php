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
 * checkUser - checks whether user operation is valid
 *
 * @param		string			$user		user, adding or updating an entry
 * @return									boolean value (false on error)
 */
function checkUser ($user) {

	global $authentication_type;

	if ($authentication_type) {

			// check whether authentication has been circumvented
			if (empty($_SESSION['user'])) return false;
			if ($_SESSION['remote_addr'] != $_SERVER['REMOTE_ADDR']) return false;
			if ($_SESSION['user_agent'] != $_SERVER['HTTP_USER_AGENT']) return false;
			

			// check whether user is spoofed
			$user = prepareDBValue($user);
			$dbResult = queryDB('select distinct username,admin from contacts where username=\'' . $user . '\'');
			if ($dbResult[0]['admin'] != '1' && prepareDBValue($_SESSION['user']) != $user) return false;

	}

	return true;

}




/**
 * isAdmin - checks whether session user has admin rights
 *
 * @param		none
 * @return		boolean value (true on admin)
 */
function isAdmin () {

	global $authentication_type;

	// no authentication -> no security
	if (!$authentication_type) return true;

	// no user
	if (empty($_SESSION['user'])) return false;

	// check user
	$dbResult = queryDB('select admin from contacts where username=\'' . prepareDBValue($_SESSION['user']) . '\'');
	if ($dbResult[0]['admin'] == '1') return true;

	return false;

}




/**
 * setSessionData - stores session data
 *
 * @param		none
 * @return		none
 */
function setSessionData () {
	$_SESSION['remote_addr'] = $_SERVER['REMOTE_ADDR'];
	$_SESSION['user_agent'] = $_SERVER['HTTP_USER_AGENT'];
}

?>
