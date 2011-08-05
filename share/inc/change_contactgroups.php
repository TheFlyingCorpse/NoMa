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
 * addContactGroup - creates a new contactgroup
 *
 * @param		none
 * @return		boolean value
 */
function addContactGroup () {

	global $p;

	$contactgroup = ((isset($p['contactgroup_name'])) ? $p['contactgroup_name'] : null);
	if (empty($contactgroup)) return false;
	$contactgroup = prepareDBValue($contactgroup);

	$contactgroup_short = ((isset($p['contactgroup_name_short'])) ? $p['contactgroup_name_short'] : null);
	if (empty($contactgroup_short)) return false;
	$contactgroup_short = prepareDBValue($contactgroup_short);
        $timeframe_id = prepareDBValue($timeframe_id);
        $timezone_id = prepareDBValue($timezone_id);
	
	$contactgroup_view_only = (isset($p['contactgroup_view_only'])) ? (int)$p['contactgroup_view_only'] : '0';

	// insert new group
	$query = sprintf(
		'insert into contactgroups (name,name_short,view_only,timezone_id,timeframe_id) values (\'%s\',\'%s\',\'%s\',\'%s\',\'%s\')',
		$contactgroup,
		$contactgroup_short,
		$contactgroup_view_only,
		$timezone_id,
		$timeframe_id
	);
	queryDB($query);

	// set new contactgroup to 'edit'
	$query = sprintf(
		'select id from contactgroups where name=\'%s\' and name_short=\'%s\' and timezone_id=\'%s\'  and timeframe_id=\'%s\'',
		$contactgroup,
		$contactgroup_short,
		$timezone_id,
		$timeframe_id
	);
	$dbResult = queryDB($query);
	if (!is_array($dbResult)) return false;
	if(!count($dbResult)) return false;
	$p['contactgroup'] = $dbResult[0]['id'];

	return true;

}




/**
 * updateContactGroup - updates a contact group
 *
 * @param		none
 * @return		boolean value
 */
function updateContactGroup () {

	global $p;

	$id = ((isset($p['id'])) ? $p['id'] : null);
	if (empty($id)) return false;
	$id = prepareDBValue($id);

	if (!isset($p['update_contactgroup_name'])) return false;
	if (empty($p['update_contactgroup_name'])) return false;
	$contactgroup_name = prepareDBValue($p['update_contactgroup_name']);

	if (!isset($p['update_contactgroup_name_short'])) return false;
	if (empty($p['update_contactgroup_name_short'])) return false;
	$contactgroup_name_short = prepareDBValue($p['update_contactgroup_name_short']);

        $timeframe_id = prepareDBValue($p['timeframe_id']);

	$contactgroup_view_only = (isset($p['contactgroup_view_only'])) ? (int)$p['contactgroup_view_only'] : '0';

	$contacts = ((isset($p['contacts']) && is_array($p['contacts'])) ? $p['contacts'] : array());


	// update contact group's name
	$query = sprintf(
		'update contactgroups set name=\'%s\',name_short=\'%s\',view_only=\'%s\',timezone_id=\'%s\',timeframe_id=\'%s\' where id=\'%s\'',
		$contactgroup_name,
		$contactgroup_name_short,
		$contactgroup_view_only,
		$timezone_id,
		$timeframe_id,
		$id
	);
	queryDB($query);


	// delete old contactgroup members
	$query = sprintf(
		'delete from contactgroups_to_contacts where contactgroup_id=\'%s\'',
		$id
	);
	queryDB($query);


	// get contact ids
	if (count($contacts)) {

		$ids = null;
		$sep = null;
		foreach ($contacts as $contact) {
			$ids .= sprintf(
				'%susername=\'%s\'',
				$sep,
				prepareDBValue($contact)
			);
			if (!$sep) $sep = ' or ';
		}
		$dbResult = queryDB('select id from contacts where ' . $ids);


		// determine new relationships
		$relationships = null;
		$sep = null;
		foreach ($dbResult as $row) {
			$relationships .= sprintf(
				'%s(\'%s\',\'%s\')',
				$sep,
				$id,
				$row['id']
			);
			if(!$sep) $sep = ',';
		}

		// insert new contactgroup members
		$query = sprintf(
			'insert into contactgroups_to_contacts values %s',
			$relationships
		);
		queryDB($query);

	}

	return true;

}




/**
 * deleteContactGroup - delete a contact group and all relations to existing contacts
 *
 * @param		none
 * @return		boolean value
 */
function deleteContactGroup () {

	global $p;

	$id = ((isset($p['contactgroup'])) ? $p['contactgroup'] : null);
	if (empty($id)) return false;
	$id = prepareDBValue($id);


	// delete group
	$query = sprintf(
		'delete from contactgroups where id=\'%s\'',
		$id
	);
	queryDB($query);


	// delete all contactgroup-to-contact relationships
	$query = sprintf(
		'delete from contactgroups_to_contacts where contactgroup_id=\'%s\'',
		$id
	);
	queryDB($query);


	return true;

}


?>
