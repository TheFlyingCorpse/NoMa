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

	global $stati, $authentication_type, $message, $p;
	global $logs;

	// init
	$cols = array (
		'n.id' => 'NOTIFICATION_RULE',
		'n.notification_name' => 'NOTIFICATION_NAME',
                'n.recipients_include' => 'RECIPIENT',
                'n.servicegroups_include' => 'SERVICEGROUP',
		'n.hostgroups_include' => 'HOSTGROUP',
		'n.hosts_include' => 'HOST',
		'n.services_include' => 'SERVICE',
		'n.username' => 'OWNER'
	);

	$templateContent = new nwTemplate(TEMPLATE_OVERVIEW);

	// assign messages
	if (!empty($message)) $templateContent->assign('MESSAGE', $message);

	// BEGIN - assign static
	$templateContent->assign('OVERVIEW_ADD_NEW_NOTIFICATION', OVERVIEW_ADD_NEW_NOTIFICATION);
	$templateContent->assign('OVERVIEW_HEADING_NOTIFICATION_RULE', OVERVIEW_HEADING_NOTIFICATION_RULE);
        $templateContent->assign('OVERVIEW_HEADING_NOTIFICATION_NAME', OVERVIEW_HEADING_NOTIFICATION_NAME);
	$templateContent->assign('OVERVIEW_HEADING_ACTIONS', OVERVIEW_HEADING_ACTIONS);
        $templateContent->assign('OVERVIEW_HEADING_RECIPIENTS', OVERVIEW_HEADING_RECIPIENTS);
        $templateContent->assign('OVERVIEW_HEADING_SERVICEGROUPS', OVERVIEW_HEADING_SERVICEGROUPS);
	$templateContent->assign('OVERVIEW_HEADING_HOSTGROUPS', OVERVIEW_HEADING_HOSTGROUPS);
	$templateContent->assign('OVERVIEW_HEADING_HOSTS', OVERVIEW_HEADING_HOSTS);
	$templateContent->assign('OVERVIEW_HEADING_SERVICES', OVERVIEW_HEADING_SERVICES);
	$templateContent->assign('OVERVIEW_HEADING_OWNER', OVERVIEW_HEADING_OWNER);
	$templateContent->assign('OVERVIEW_HEADING_TIMEZONE', OVERVIEW_HEADING_TIMEZONE);
	$templateContent->assign('OVERVIEW_HEADING_NOTIFY_ON', OVERVIEW_HEADING_NOTIFY_ON);
	$templateContent->assign('OVERVIEW_HEADING_NOTIFY_BY', OVERVIEW_HEADING_NOTIFY_BY);
	$templateContent->assign('OVERVIEW_HEADING_NOTIFY_USERS', OVERVIEW_HEADING_NOTIFY_USERS);
	$templateContent->assign('OVERVIEW_LONG_INCLUDE_HEADING', OVERVIEW_LONG_INCLUDE_HEADING);
	$templateContent->assign('OVERVIEW_LONG_EXCLUDE_HEADING', OVERVIEW_LONG_EXCLUDE_HEADING);
	// END - assign static

	// check whether user is admin
	$admin = false;
	if (!empty($_SESSION['user']) || !$authentication_type) {
		if (!empty($_SESSION['user'])) {
			$user = prepareDBValue($_SESSION['user']);
			$dbData = queryDB('select admin from contacts where username=\'' . $user . '\'');
			if ($dbData[0]['admin'] == '1') $admin = true;
		} else {
			$admin = true;
		}
	}


	$query = 'select distinct n.*,c.full_name,tz.timezone from notifications n, contacts c, timezones tz
						where n.username=c.username and n.timezone_id=tz.id ';

	if (!empty($_SESSION['user']) && !$admin) {
		$dbUser = prepareDBValue($_SESSION['user']);
		$query .= 'and n.username=\'' . $dbUser . '\' ';
	}


	$query .= 'order by ';
	$order_by = "";
	$order_dir = "";

	// set order by
	if (!isset($p['order_by'])) $p['order_by'] = 'n.id';
	if (array_key_exists($p['order_by'], $cols)) {
		$order_by = $p['order_by'];
	} else {
		$order_by = 'n.id';
	}

	// set order directory
	if (!isset($p['order_dir'])) $p['order_dir'] = 'asc';
	switch ($p['order_dir']) {
		case 'asc':
			$order_dir = 'asc';
			break;
		case 'desc':
		default:
			$order_dir = 'desc';
			break;
	}

	// set urls and image
	$qStr = getQueryString(array('order_by','order_dir'));
	foreach ($cols as $key => $value) {

		if ($order_by == $key) {

			if ($order_dir == 'asc') {
				$current_dir = 'desc';
				$image = '<img src="images/arrow_down.gif" alt="down" border="0"/>';
			} else {
				$current_dir = 'asc';
				$image = '<img src="images/arrow_up.gif" alt="up" border="0"/>';
			}

		} else {

			$current_dir = 'desc';
			$image = null;

		}

		$url = 'index.php?' . $qStr . '&amp;order_by=' . $key . '&amp;order_dir=' . $current_dir;

		$templateContent->assign('LINK_SORT_' . $value, $url);
		if (!empty($image)) $templateContent->assign('SORT_IMAGE_' . $value, $image);

	}


	$dbData = queryDB($query.$order_by.' '.$order_dir);


	// fetch contactgroup notifications
	if (!empty($_SESSION['user']) && !$admin) {

		// init where statement
		$whereStatement = null;
		$whereStatementArr = array();

		// determine groups the current contact is a member of
		$query = sprintf ('select distinct cg.id
			from contacts c
			inner join contactgroups_to_contacts cgc on cgc.contact_id = c.id
			inner join contactgroups cg on cg.id = cgc.contactgroup_id
			where c.username = \'%s\'',
			$dbUser
		);

		$dbTmp = queryDB($query);

		if (count($dbTmp)) {

			$contactgroupFilterArr = array();
			foreach ($dbTmp as $row) {
				array_push($contactgroupFilterArr, $row['id']);
			}

			if (count($contactgroupFilterArr)) {
				$contactgroupFilter = sprintf (
					'(cg.id = \'%s\')',
					implode('\' or cg.id = \'', $contactgroupFilterArr)
				);
				array_push($whereStatementArr, $contactgroupFilter);
			}

		}

		// determine notifications to filter out
		if (count($dbData)) {

			$notificationFilterArr = array();
			foreach ($dbData as $row) {
				array_push($notificationFilterArr, $row['id']);
			}

			if (count($notificationFilterArr)) {

				$notificationFilter = sprintf (
					'(n.id <> \'%s\')',
					join('\' and n.id <> \'', $notificationFilterArr)
				);

				array_push($whereStatementArr, $notificationFilter);

			}

		}

		// assemble where statement
		if (count($whereStatementArr)) {
			$whereStatement = sprintf (
				' where %s',
				implode(' and ', $whereStatementArr)
			);
		}

		// create query and fetch contactgroup notifications
		$query = sprintf (
			'select distinct
				n.*,c.ull_name, tz.timezone, cg.id cg_id
				from notifications n
				inner join notifications_to_contacts nc on nc.notification_id = n.id
				inner join contacts c on c.id = nc.contact_id and c.username = n.username
				inner join timezones tz on n.timezone_id = tz.id
				inner join notifications_to_contactgroups ncg on ncg.notification_id = n.id
				inner join contactgroups cg on cg.id = ncg.contactgroup_id
				%s',
			$whereStatement
		);

		$dbDataContactgroups = queryDB($query);

		$dbData = array_merge($dbDataContactgroups, $dbData);
		
	}


	$content = null;
	$rowDark = true;

	foreach ($dbData as $row) {

		$templateSubContent = new nwTemplate(TEMPLATE_OVERVIEW_ROW);

		$templateSubContent->assign('ID', $row['id']);

		// set and toggle row background
		$rowClass = ($rowDark) ? 'row' : 'row-light';
		$templateSubContent->assign('ROW_CLASS', $rowClass);
		$rowDark = ($rowDark) ? false : true;

		if ($row['active'] == '1') {
			$templateSubContent->assign('OVERVIEW_TOGGLE_ACTIVE_IMAGE', 'images/activate.png');
			if (!isset($row['cg_id'])) {
				$templateSubContent->assign('OVERVIEW_TOGGLE_ACTIVE_TOOLTIP', OVERVIEW_ACTIVE_TOOLTIP);
			} else {
				$templateSubContent->assign('OVERVIEW_TOGGLE_ACTIVE_TOOLTIP', OVERVIEW_ACTIVE_TOOLTIP_DISABLED);
			}
		} else {
			$templateSubContent->assign('OVERVIEW_TOGGLE_ACTIVE_IMAGE', 'images/deactivate.png');
			if (!isset($row['cg_id'])) {
				$templateSubContent->assign('OVERVIEW_TOGGLE_ACTIVE_TOOLTIP', OVERVIEW_INACTIVE_TOOLTIP);
			} else {
				$templateSubContent->assign('OVERVIEW_TOGGLE_ACTIVE_TOOLTIP', OVERVIEW_INACTIVE_TOOLTIP_DISABLED);
			}
		}

		// toggle usability of button
		if (!isset($row['cg_id'])) {
			$templateSubContent->assign('OVERVIEW_TOGGLE_ACTIVE_JS', 'onclick="javascript:toggleActive(\'' . $row['id'] . '\')" ');
			$templateSubContent->assign('OVERVIEW_EDIT_ENTRY_ALT_TOOLTIP', OVERVIEW_EDIT_ENTRY_ALT_TOOLTIP);
			$templateSubContent->assign('OVERVIEW_DELETE_ENTRY_ALT_TOOLTIP', OVERVIEW_DELETE_ENTRY_ALT_TOOLTIP);
			$templateSubContent->assign('OVERVIEW_TOGGLE_ACTIVE_ALT', OVERVIEW_TOGGLE_ACTIVE_ALT);
			$templateSubContent->assign('OVERVIEW_EDIT_ENTRY_JS', 'onclick="javascript:editEntry(\'' . $row['id'] . '\')" ');
			$templateSubContent->assign('OVERVIEW_DELETE_ENTRY_JS', 'onclick="javascript:deleteEntry(\'' . $row['id'] . '\')" ');
			$templateSubContent->assign('OVERVIEW_EDIT_ENTRY_IMG', 'images/edit.png');
			$templateSubContent->assign('OVERVIEW_DELETE_ENTRY_IMG', 'images/delete.png');
		} else {
			$templateSubContent->assign('OVERVIEW_TOGGLE_ACTIVE_ALT', OVERVIEW_TOGGLE_ACTIVE_ALT_DISABLED);
			$templateSubContent->assign('OVERVIEW_EDIT_ENTRY_IMG', 'images/spacer.gif');
			$templateSubContent->assign('OVERVIEW_DELETE_ENTRY_IMG', 'images/spacer.gif');
		}
		$data = list($long, $value, $short) = shorten($row['recipients_include'] . ' | ' .$row['recipients_exclude'], 'overview_recipients');
                $templateSubContent->assign('RECIPIENTS', $long);
                if ($short) {
                        $templateSubContent->assign(
                                'RECIPIENTS_MOUSEOVER',
                                ' onmouseover="javascript:showLong(\'&lt;b&gt;+&lt;/b&gt;: ' . $row['recipients_include'] . '&lt;br/&gt;&lt;b&gt;-&lt;/b&gt;: ' . $row['recipients_exclude'] . '\');" onmouseout="javascript:hideLong();"'
                        );
                }
		$data = list($long, $value, $short) = shorten($row['servicegroups_include'] . ' | ' .$row['servicegroups_exclude'], 'overview_servicegroups');
                $templateSubContent->assign('SERVICEGROUPS', $value);
                if ($short) {
                        $templateSubContent->assign(
                                'SERVICEGROUPS_MOUSEOVER',
                                ' onmouseover="javascript:showLong(\'&lt;b&gt;+&lt;/b&gt;: ' . $row['servicegroups_include'] . '&lt;br/&gt;&lt;b&gt;-&lt;/b&gt;: ' . $row['servicegroups_exclude'] . '\');" onmouseout="javascript:hideLong();"'
                        );
                }
		$data = list($long, $value, $short) = shorten($row['hostgroups_include'] . ' | ' .$row['hostgroups_exclude'], 'overview_hostgroups');
		$templateSubContent->assign('HOSTGROUPS', $value);
		if ($short) {
			$templateSubContent->assign(
				'HOSTGROUPS_MOUSEOVER',
				' onmouseover="javascript:showLong(\'&lt;b&gt;+&lt;/b&gt;: ' . $row['hostgroups_include'] . '&lt;br/&gt;&lt;b&gt;-&lt;/b&gt;: ' . $row['hostgroups_exclude'] . '\');" onmouseout="javascript:hideLong();"'
			);
		}

		$data = list($long, $value, $short) = shorten($row['hosts_include'] . ' | ' .$row['hosts_exclude'], 'overview_host');
		$templateSubContent->assign('HOSTS', $value);
		if ($short) {
			$templateSubContent->assign(
				'HOSTS_MOUSEOVER',
				' onmouseover="javascript:showLong(\'&lt;b&gt;+&lt;/b&gt;: ' . $row['hosts_include'] . '&lt;br/&gt;&lt;b&gt;-&lt;/b&gt;: ' . $row['hosts_exclude'] . '\');" onmouseout="javascript:hideLong();"'
			);
		}
		$data = list($long, $value, $short) = shorten($row['services_include'] . ' | ' . $row['services_exclude'], 'overview_service');
		$templateSubContent->assign('SERVICES' , $value);
		if ($short) {
			$templateSubContent->assign(
				'SERVICES_MOUSEOVER',
				' onmouseover="javascript:showLong(\'&lt;b&gt;+&lt;/b&gt;: ' . $row['services_include'] . '&lt;br/&gt;&lt;b&gt;-&lt;/b&gt;: ' . $row['services_exclude'] . '\');" onmouseout="javascript:hideLong();"'
			);
		}

		$templateSubContent->assign('OWNER', $row['username']);
		$templateSubContent->assign('FULL_NAME', $row['full_name']);

		$templateSubContent->assign('TIME_ZONE', $row['timezone']);


		// BEGIN - notify on
		$statiField = array();
		$sep = null;
		foreach ($stati as $key => $settings) {
			$statusArr = array();
			foreach ($settings as $status => $str) {
				if ($row[$status] == '1') {
					array_push($statusArr, $str);
				}
			}
			if (!empty($statusArr)) {
				array_push($statiField, $key . ': ' . implode(', ', $statusArr));
			}
		}
		$templateSubContent->assign('NOTIFY_ON', implode('<br/>', $statiField));
		// END   - notify on


		// BEGIN - notify by
		$query = 'select distinct m.method from notification_methods m
					left join notifications_to_methods nm on m.id=nm.method_id
					where nm.notification_id=\'' . prepareDBValue($row['id']) . '\'';
		$notify = array();
		foreach (queryDB($query) as $subRow) {
			$notify[] = $subRow['method'];
		}
		$templateSubContent->assign('NOTIFY_BY', implode('<br/>', $notify));
		// END   - notify by


		// BEGIN - NOTIFY PERSONS AND GROUPS

		$rowID = prepareDBValue($row['id']);
		$notify = array();

		// BEGIN - notify users
		$query = 'select distinct c.username,c.full_name from contacts c
					left join notifications_to_contacts nc on c.id=nc.contact_id
					where nc.notification_id=\'' . $rowID . '\'';
		foreach (queryDB($query) as $subRow) {
			$notify[] = '<span onmouseover="showLong(\'' . $subRow['full_name'] . '\')" onmouseout="hideLong()">' . $subRow['username'] . '</span>';
		}
		// END   - notify users


		// BEGIN - notify groups
		$query = 'select distinct cg.name_short, cg.name from contactgroups cg
					left join notifications_to_contactgroups ncg on cg.id=ncg.contactgroup_id
					where ncg.notification_id=\'' . $rowID . '\'
					order by cg.name_short';
		foreach (queryDB($query) as $subRow) {
			$notify[] = '<span onmouseover="showLong(\'' . $subRow['name'] . '\')" onmouseout="hideLong()">' . OVERVIEW_CONTACTGROUP_PREFIX . $subRow['name_short'] . '</span>';
		}
		// END   - notify groups		

		$templateSubContent->assign('NOTIFY_USERS_AND_GROUPS', implode('<br/>', $notify));

		// END   - NOTIFY PERSONS AND GROUPS

		// BEGIN - rule no.
		$templateSubContent->assign('NOTIFICATION_RULE', $rowID);
		// END   - rule no.

                // BEGIN - name to no.
                $templateSubContent->assign('NOTIFICATION_NAME', $row['notification_name']);
                // END   - name to no.

		$content .= $templateSubContent->getHTML();

	}

	$templateContent->assign('ROWS_CONTENT', $content);

	return $templateContent->getHTML();

}


?>
