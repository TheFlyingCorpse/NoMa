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
 * getTimePeriods - give back associative array of working hours
 *
 * @param		none
 * @return		array of working hours and corresponding ids
 */
function getTimePeriods () {
	$timeperiods = array();
	$dbResult = queryDB('select id,description from time_periods');
	if (is_array($dbResult)) {
		foreach ($dbResult as $row) {
			$timeperiods[$row['id']] = $row['description'];
		}
	}
	return $timeperiods;
}




/**
 * getTimeZone - give back associative array of timezones and corresponding ids
 *
 * @param		string		$id			id of timezone to search
 * @return								array of timezones and corresponding ids
 */
function getTimeZone ($id = null) {
	if ($id) {
		$dbResult = queryDB('select * from timezones where id=\'' . prepareDBValue($id) . '\' order by timezone');
	} else {
		$dbResult = queryDB('select id,timezone,time_diff from timezones order by timezone');
	}
	$timezones = array();
	if (is_array($dbResult)) {
		foreach ($dbResult as $row) {
			$diff = (int)$row['time_diff'];
			$timezones[$row['id']] = $row['timezone'] . sprintf(' (%s%dh)', (($diff < 0) ? null : '+'), $diff);
		}
	}
	return $timezones;
}




/**
 * getContacts - give back associative array of usernames and corresponding full names.
 *
 * @param		string		$exclude		username of user to exclude from list
 * @return									array of full names and corresponding usernames
 */
function getContacts ($exclude = null) {
	$query = 'select username,full_name from contacts where username != \'[---]\'';
	if ($exclude) {
		$query .= ' and username != \'' . prepareDBValue($exclude) . '\'';
	}
	$query .= ' order by full_name';
	$dbResult = queryDB($query);
	$users = array();
	if (is_array($users)) {
		foreach ($dbResult as $row) {
			$users[$row['username']] = $row['full_name'];
		}
	}
	return $users;
}

/**
 * getContactsWithIDs - give back associative array of users and corresponding ids
 *
 * @param               string          $exclude                username of user to exclude from list
 * @return                                                                      array of full names and corresponding ids
 */
function getContactsWithIDs ($exclude = null) {
        $query = 'select id,full_name from contacts where username != \'[---]\'';
        if ($exclude) {
                $query .= ' and username != \'' . prepareDBValue($exclude) . '\'';
        }
        $query .= ' order by full_name';
        $dbResult = queryDB($query);
        $users = array();
        if (is_array($users)) {
                foreach ($dbResult as $row) {
                        $users[$row['id']] = $row['full_name'];
                }
        }
        return $users;
}

/**
 * getContactID - give back given contacts username's corresponding id
 *
 * @param               string          $username                 username to get ID of
 * @return                                                        id.
 */
function getContactID ($username){
        $query = 'select id from contacts where username = \''.prepareDBValue($username).'\'';
        $dbResult = queryDB($query);
        if (count($dbResult) != 1) return false;
        if (!is_array($dbResult[0])) return false;
        return $dbResult[0]['id'];
}

/**
 * getNotificytionMethods - give back associative array of methods and corresponding ids
 *
 * @param		none
 * @return		array of methods and corresponding ids
 */
function getNotificationMethods () {
	$dbResult = queryDB('select id,method from notification_methods order by method');
	$methods = array();
	if (is_array($dbResult)) {
		foreach($dbResult as $row) {
			$methods[$row['id']] = $row['method'];
		}
	}
	return $methods;
}




/**
 * getContactGroups - gives back an associative array of contactgroups and corresponding ids
 *
 * @param		none
 * @return		array of contactgroups and corresponding ids
 */
function getContactGroups () {
	$dbResult = queryDB('select * from contactgroups order by name');
	$contactgroups = array();
	if (is_array($dbResult)) {
		foreach($dbResult as $row) {
			$contactgroups[$row['id']] = $row['name'];
		}
	}
	return $contactgroups;
}




/**
 * getContactGroupContacts - gives back an associative array of contacts of a contact group
 *
 * @param		string		$contactgroup		contactgroup to for search users
 * @return		array							users who are members of the specified contactgroup
 */
function getContactGroupMembers ($contactgroup = null) {
	if (empty($contactgroup)) return array();
	$members = array();
	$query = 'select distinct c.username
				from contacts c
				left join contactgroups_to_contacts cgc on cgc.contact_id=c.id
				left join contactgroups cg on cg.id=cgc.contactgroup_id
				where c.username != \'[---]\' and cg.id=\'' . $contactgroup . '\'';
	$dbResult = queryDB($query);
	if (is_array($dbResult)) {
		foreach ($dbResult as $row) {
			$members[] = $row['username'];
		}
	}
	return $members;	
}




/**
 * getContactGroupShortById - returns the short name of a contact group
 *
 * @param		string		$id			id of contact group
 * @return		string					short name of contact group
 */
function getContactGroupShortById ($id) {
	$dbResult = queryDB('select name_short from contactgroups where id=\'' . prepareDBValue($id) . '\'');
	if (!is_array($dbResult)) return null;
	if (!count($dbResult)) return null;
	return $dbResult[0]['name_short'];
}




/**
 * getContactGroupById - queryies database for information about a certain contactgroup
 *
 * @param		string		$id			id of contact group
 * @return		string					short name of contact group
 */
function getContactGroupById ($id) {
	$dbResult = queryDB('select * from contactgroups where id=\'' . prepareDBValue($id) . '\'');
	if (count($dbResult) != 1) return false;
	if (!is_array($dbResult[0])) return false;
	return $dbResult[0];
}

/**
 * getContactGroups - gives back an associative array of contactgroups and corresponding ids
 *
 * @param               none
 * @return              array of contactgroups and corresponding ids
 */
function getTimeFrames ($exclude = null) {
	$query = 'select * from timeframes where timeframe_name != \'[---]\'';
        if ($exclude) {
                $query .= ' and timeframe_name != \'' . prepareDBValue($exclude) . '\'';
        }
	$query .= '  order by timeframe_name';
        $dbResult = queryDB($query);
        $timeframes = array();
        if (is_array($dbResult)) {
                foreach($dbResult as $row) {
                        $timeframes[$row['id']] = $row['timeframe_name'];
                }
        }
        return $timeframes;
}

/**
 * getContactGroupById - queryies database for information about a certain contactgroup
 *
 * @param               string          $id                     id of contact group
 * @return              string                                  short name of contact group
 */
function getTimeFrameById ($id) {
        $dbResult = queryDB('select * from timeframes where id=\'' . prepareDBValue($id) . '\'');
        if (count($dbResult) != 1) return false;
        if (!is_array($dbResult[0])) return false;
        return $dbResult[0];
}

/**
 * getDBVersion - queryies database for information about what dbversion it is.
 *
 * @param               string          $id                     id of contact group
 * @return              string                                  short name of contact group
 */
function getDBVersion () {
        $dbResult = queryDB('select content from information where type=\'dbversion\'');
        if (count($dbResult) != 1) return false;
        return $dbResult[0]['content'];
}

/**
 *
 */
function registerWithGrowl($growladdress){
		$log = new Logging();
		$log->lwrite('Growl time, dest:'.$growladdress);
		global $growlSettings;
			$g = new Growl();
			$g->setAppName($growlSettings['application']);
			$g->setAddress($growladdress,$growlSettings['password']);
			$g->addNotification("Successfully registered!");
			$g->register();	
}



function getNavigationContent ($action, $admin = false) {
	global $authentication_type;
	global $logs;
	global $contactgroups;
	global $timeframes;
	global $statuspage;

	$navigation = array (
		array(
			'actions'				=> array('', 'overview', 'add_new', 'toggle_active'),
			'admin_only'			=> false,
			'auth_type_required'	=> false,
			'title'					=> NAVIGATION_OVERVIEW,
		),
		array(
			'actions'				=> array('add', 'edit', 'add_escalation', 'update'),
			'admin_only'			=> false,
			'auth_type_required'	=> false,
			'title'					=> NAVIGATION_NOTIFICATION,
		),
		array(
			'actions'				=> array('contacts'),
			'admin_only'			=> false,
			'auth_type_required'	=> false,
			'title'					=> array(
				'user'					=> NAVIGATION_PROFILE,
				'admin'					=> NAVIGATION_CONTACTS,
			),
		),
		array(
			'actions'				=> array('contactgroups'),
			'admin_only'			=> $contactgroups['admin_only'],
			'auth_type_required'	=> false,
			'title'					=> NAVIGATION_CONTACTGROUPS,
		),
                array(
                        'actions'                               => array('timeframes'),
                        'admin_only'                    => $timeframes['admin_only'],
                        'auth_type_required'    => false,
                        'title'                                 => NAVIGATION_TIMEFRAMES,
                ),
		array(
			'actions'				=> array('status'),
			'admin_only'			=> $statuspage['admin_only'],
			'auth_type_required'	=> false,
			'title'					=> NAVIGATION_STATUS,
		),
		array(
			'actions'				=> array('logs'),
			'admin_only'			=> $logs['admin_only'],
			'auth_type_required'	=> false,
			'title'					=> NAVIGATION_LOGS,
		),
		array(
			'actions'				=> array('logout'),
			'admin_only'			=> false,
			'auth_type_required'	=> true,
			'title'					=> NAVIGATION_LOGOUT,
		),
	);

	$separator = '&nbsp;&nbsp;&nbsp;';

	$contentArr = array();

	foreach ($navigation as $settings) {
		if ($settings['actions'][0] == 'logout' && $authentication_type && $authentication_type == 'http' && !empty($_SESSION['user'])) {
			continue;
		}
		if (empty($authentication_type) && $settings['auth_type_required']) {
			continue;
		}
		if (!$settings['admin_only'] || $admin) {
			$active = (in_array($action, $settings['actions'])) ? 'class="active" ' : null;
			$tplTmp = new nwTemplate(TEMPLATE_NAVIGATION_LINK);;
			$tplTmp->assign('NAVIGATION_CLASS_ACTIVE', $active);
			$tplTmp->assign('NAVIGATION_ACTION', $settings['actions'][0]);
			if (!is_array($settings['title'])) {
				$title = $settings['title'];
			} else {
				$title = ($admin) ? $settings['title']['admin'] : $settings['title']['user'];
			}
			$tplTmp->assign('NAVIGATION_TITLE', $title);
			array_push($contentArr, $tplTmp->getHTML());
		}
	}

	$templateNavigation = new nwTemplate(TEMPLATE_NAVIGATION);
	$templateNavigation->assign('NAVIGATION_LINKS',  implode($separator, $contentArr));
	
	return $templateNavigation->getHTML();
}

?>
