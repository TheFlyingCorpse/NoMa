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
 * querySQLite3DB - queries SQLite3 db and return result as array
 *
 * @param               string          $query                  SQL query to execute
 * @param               boolean         $return_count   give back number of rows (optional)
 * @return                                                                      array of result rows
 */
function querySQLite3DB ($query, $return_count = false, $ndo = false) {

        // set shortcut to database configuration
        if (!$ndo) {
                global $dbConf;
        } else {
                global $dbNDO;
                $dbConf = &$dbNDO;
        };

	// Try to open the SQLite database.
	$db = new PDO("sqlite:".$dbConf['dbFilePath']);
	if (!$db){
		die('Something wrong\n');
	};

        // Uncomment below to log all queries to file.
        //$log = new Logging();
        //$log->lwrite($query);

        // query database
	$result = $db->query($query);


        // initialize result variable
        $dbResult = array();
	$count = 0;

        // fetch result if it makes sense
        $queryCmd = strtolower(substr($query, 0, 6));
        if ($queryCmd == 'select') {

	                // Replace between SELECT and FROM with COUNT(*) to count the rows.
	                $start = 'select';
	                $end = 'from';
	                $replace_with = ' COUNT(*) ';
			echo "Original Query: ".$query."<br>";
			$countquery = replace_content_inside_delimiters($start, $end, $replace_with, $query);
			echo "Count Query   : ".$countquery."<br/>";
		
			if ($result = $db->query($countquery)) {

				/* Check the number of rows that match the SELECT statement */
				if ( $result->fetchColumn() > 0) {

					/* Issue the real SELECT statement and work with the results */
		                	foreach ($db->query($query) as $row) {
						$count = $count++;
						$dbResult[] = $row;
					}
				}
			}
        } else {
	        // Count results. ONLY valid for UPDATE; INSERT; DELETE statements.
	        if ($return_count) {
	                $count = $result->rowCount();
	        }
	}

        // close database connection if not persistent
        //if (!$dbConf['persistent']) mysql_close($dbh);

        if ($return_count) {
                return array($count, $dbResult);
        } else {
                return $dbResult;
        }

}

function replace_content_inside_delimiters($start, $end, $new, $source) {
        return preg_replace('#('.preg_quote($start).')(.*)('.preg_quote($end).')#si', '$1'.$new.'$3', $source);
}

?>
