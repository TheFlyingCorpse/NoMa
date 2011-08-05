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
 * queryMySQLDB - queries MySQL db and return result as array
 *
 * @param               string          $query                  SQL query to execute
 * @param               boolean         $return_count   give back number of rows (optional)
 * @return                                                                      array of result rows
 */
function queryMySQLDB ($query, $return_count = false, $ndo = false) {

        // set shortcut to database configuration
        if (!$ndo) {
                global $dbConf;
        } else {
                global $dbNDO;
                $dbConf = &$dbNDO;
        }

        // connect to database host
        if ($dbConf['persistent']) {
                $dbh = mysql_connect($dbConf['host'], $dbConf['user'], $dbConf['password'])
                        or die("Could not connect to database: " . mysql_error());
        } else {
                $dbh = mysql_pconnect($dbConf['host'], $dbConf['user'], $dbConf['password'])
                        or die("Could not connect to database: " . mysql_error());
        }

        // select database
        mysql_select_db($dbConf['database']) or die("Could not select database!");

        // Uncomment below to log all queries to file.
        $log = new Logging();
        $log->lwrite($query);

        // query database
        $result = mysql_query($query) or die("Could not execute query: " . mysql_error());

        $count = 0;
        if ($return_count) {
                $count = mysql_num_rows($result);
        }

        // initialize result variable
        $dbResult = array();

        // fetch result if it makes sense
        $queryCmd = strtolower(substr($query, 0, 6));
        if ($queryCmd == 'select') {
                while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
                        $dbResult[] = $row;
                }
                // free result memory
                mysql_free_result($result);
        }

        // close database connection if not persistent
        if (!$dbConf['persistent']) mysql_close($dbh);

        if ($return_count) {
                return array($count, $dbResult);
        } else {
                return $dbResult;
        }

}

?>
