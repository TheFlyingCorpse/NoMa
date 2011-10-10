<?php

# COPYRIGHT:
#  
# This software is Copyright (c) 2011 NETWAYS GmbH, William Preston
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



if ($argc != 2) {
    print "Do not run this script directly\nPlease use the perl script\n";
    exit(1);
}
ini_set('include_path', '.:../share:../share/config');
include($argv[1]);


$conf['db']['sqlite3']['type'] = 'sqlite3';
$conf['db']['mysql']['type'] = 'mysql';
$conf['frontend']['language'] =     $language;


if (isset($debug)) {
    $conf['frontend']['debug']['logging'] = $debug;
} else {
    $conf['frontend']['debug']['logging'] = FALSE;
}
if (isset($log_file)) {
    $conf['frontend']['debug']['file'] = $log_file;
} else {
    $conf['frontend']['debug']['file'] = '/tmp/NoMa-logfile.log';
}
if (isset($sqllog)) {
    $conf['frontend']['debug']['queries'] = $sqllog;
} else {
    $conf['frontend']['debug']['queries'] = FALSE;
}
$conf['api'] =     $dbNDO;
$conf['api']['type'] = 'mysql';
    
    
$conf['frontend']['authentication_type'] =     $authentication_type;
if (isset($ldap)) {
    $conf['frontend']['ldap'] = 		$ldap;
}
$conf['frontend']['http'] =     $http;
$conf['frontend']['notifications'] =     $notifications;
$conf['frontend']['contactgroups'] =     $contactgroups;
$conf['frontend']['statuspage'] =     $statuspage;
$conf['frontend']['logs'] =     $logs;

if (isset($timeframes)) {
    $conf['frontend']['timeframes'] =     $timeframes;
} else {
    $conf['frontend']['timeframes']['admin_only'] = TRUE;
}
$conf['frontend']['overview'] =     $str_maxlen;


print yaml_emit($conf);


?>
