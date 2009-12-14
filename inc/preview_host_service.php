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



// pre checks
if (!isset($p['entity']) || ! isset($p['filter'])) exit;
if (empty($p['entity']) || empty($p['filter'])) exit;


// determine table
switch ($p['entity']) {

	case 'h':	$column = 'name1';
				$objecttype_id = 1;
				break;

	case 's':	$column = 'name2';
				$objecttype_id = 2;
				break;

	default:	exit;
	
}


// generate where statement
$arrFilter = explode(',', $p['filter']);

$filter = null;
$sep = null;
foreach ($arrFilter as $element) {

	// remove trailing whitespaces
	$element = trim($element);

	// substitute characters for correctness of database query
	$element = str_replace('%', '%%', $element);
	$element = str_replace('*', '%', $element);

	// append element to where statement
	$filter .= sprintf('%s%s like \'%s\'', $sep, $column, prepareDBValue($element));

	if (!$sep) $sep = ' or ';

}

if (!empty($filter)) {

	$filter = sprintf('and (%s)', $filter);

}

// generate query
$query = sprintf(
	'select distinct %s
		from %sobjects
		where objecttype_id=%s %s order by %s asc',
	$column,
	$dbNDO['table_prefix'],
	$objecttype_id,
	$filter,
	$column
);

// query database
$dbResult = queryDB($query, false, true);


// assemble return string
$retStr = null;
if (!count($dbResult)) {

	$retStr = ADD_EDIT_PREVIEW_NO_RESULTS;

} else {

	$sep = null;
	foreach ($dbResult as $row) {

		$retStr .=  $sep . $row[$column];

		if ($notifications['preview_max_length'] && strlen($retStr) > $notifications['preview_max_length']) {
			$retStr = substr($retStr, 0, $notifications['preview_max_length'] - 3) . '...';
			break;
		}

		if (!$sep) $sep = ', ';

	}

}


// show result
print $retStr;


?>
