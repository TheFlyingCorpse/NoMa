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


require_once('templates.php');
require_once('inc/general.php');
require_once('inc/general_app.php');


# attempt to read the configuration with YAML
try {
    $conf = yaml_parse_file('/usr/local/nagios/noma/etc/NoMa.yaml');

    $dbType = $conf['db']['type'];
    $dbConfSQLite3 = array (
            'type'			        => $conf['db']['sqlite3']['type'],
            'dbFilePath'		    => $conf['db']['sqlite3']['dbfile']
    );
    $dbConfMySQL = $conf['db']['mysql'];
    $language = $conf['frontend']['language'];
    $debug = $conf['frontend']['debug']['logging'];
    $log_file = $conf['frontend']['debug']['file'];
    $sqllog = $conf['frontend']['debug']['queries'];

    $dbTypeNDO = $conf['api']['type'];
    
    $dbNDO = $conf['api'];
    
    $growlSettings = array (
            'application'           => $conf['methods']['growl']['application_name'],
            'password'		        => $conf['methods']['growl']['password']
    );

    $authentication_type = $conf['frontend']['authentication_type'];
    if ($authentication_type == 'ldap') {
		$ldap = $conf['frontend']['ldap'];
    }
    $http = $conf['frontend']['http'];
    $notifications = $conf['frontend']['notifications'];
    $contactgroups = $conf['frontend']['contactgroups'];
    $statuspage = $conf['frontend']['statuspage'];
    $logs = $conf['frontend']['logs'];
    $timeframes = $conf['frontend']['timeframes'];
    $str_maxlen = $conf['frontend']['overview'];

} catch(Exception $e) {
# falling back to the old config if it fails




# READ ME!
#
# if you install the php-yaml module then the configuration in this section will be ignored
# and the YAML file will be used instead

    // NoMa SQLite3 database options
    $dbConfSQLite3 = array (
            'type'			=> 'sqlite3',  // Dont change this value!
            'dbFilePath'		=> '/usr/local/nagios/noma/etc/NoMa.db',
            );

    // Database type to use for NoMa (not NDO/IDO!)
    // options: 'mysql' | 'sqlite3'
    $dbType = 'sqlite3';


    // language
    // options: 'en' | 'de'
    $language = 'en';

    // logging
    // output dir
    $log_file = '/tmp/NoMa-logfile.log';
    // debug logging (where implemented) in frontend, options: true | false
    $debug = false;
    // sql frontend logging options: true | false
    $sqllog = false;

    // NoMa MySQL database options
    $dbConfMySQL = array (
            'type'			=> 'mysql',    // Dont change this value!
            'host'			=> 'localhost',
            'user'			=> 'noma',
            'password'		=> 'noma',
            'database'		=> 'noma',
            'persistent'		=> '0',
            );


    // Database type to use for NDO / IDO
    // options: 'mysql'
    $dbTypeNDO = 'mysql';

    // NDO access - only required if host_service_preview is true
    // Currently only supports one backend to query for preview.
    $dbNDO = array (
            // type options: 'mysql'
            'type'                  => 'mysql',
            'host'                  => 'localhost',
            'user'                  => 'nagios',
            'password'              => 'nagios',
            'database'              => 'nagios',
            'persistent'    => '0',
            'table_prefix'  => 'nagios_',
            );

    // Growl settings, make sure they are identical to etc/NoMa.yaml!
    $growlSettings = array (
            'application'		=> 'NoMa',
            'password'		=> 'somepassw0rd'
            );

    // authentication type
    // options: false | 'native' | 'ldap' | 'http'
    $authentication_type = 'native';


    // ldap
    //$ldap = array (
    //	'version'		=> 3,
    //	'server'		=> 'ldap://',
    //	'base_dn'		=> 'OU=someUnit,DC=some,DC=org',
    //	'dir_user'		=> 'CN=DirUser,OU=someUnit,DC=some,DC=org',
    //	'dir_password'	=> 'secret',
    //	'filter'		=> '(|(objectClass=contact)(objectClass=user))',	// simple filter
    //	'filter'		=> '(|(objectClass=person)(uid=###USER###))',		// complex filter: ###USER### will be replaced by the login name
    //  'key_find_user'	=> 'samaccountname',								// LDAP key to find login name
    //	'key_set_user'	=> 'distinguishedname',								// LDAP key to return login name to set in session
    //);


    // http
    $http = array (
            'username_is_email'	=> true,
            'check_local_user'	=> true,
            );


    // notifications /add/del/edit)
    $notifications = array (
            'add_owner' 		=> true,
            'host_service_preview' 	=> true,
            'preview_width' 	=> 250,
            'preview_max_length' 	=> 1000,
            'preview_scroll' 	=> true,
            'preview_max_height' 	=> 120,
            );

    // contactgroup manager
    $contactgroups = array (
            'admin_only' 		=> true,
            );

    // status page
    $statuspage = array (
            'admin_only'		=> true,
            );


    // log viewer
    $logs = array (
            'admin_only'		=> true,
            'pages_per_line'	=> 10,
            'num_results'		=> array (
                10	=> '10',
                20	=> '20',
                50	=> '50',
                100	=> '100',
                ),
            );

    // timeframe
    $timeframes = array (
            'admin_only'		=> true,
            );

    // length of overview fields
    $str_maxlen = array (
            'overview_recipients'		=> 40,
            'overview_hostgroups'	        => 50,
            'overview_host'	                => 40,
            'overview_servicegroups'	=> 50,
            'overview_service'              => 40,
            );

}

// stati
$stati = array (
	'Host'		=> array (
		'on_host_up'			=> 'o',
		'on_host_down'			=> 'd',
		'on_host_unreachable'		=> 'u',
	),
	'Service'	=> array (
		'on_ok'				=> 'o',
		'on_warning'			=> 'w',
		'on_critical'			=> 'c',
		'on_unknown'			=> 'u',
	),
	'Type'		=> array (
		'on_type_problem'		=> 'p',
                'on_type_recovery'		=> 'r',
                'on_type_flappingstart'		=> 'FS',
                'on_type_flappingstop'		=> 'fs',
                'on_type_flappingdisabled'	=> 'fd',
                'on_type_downtimestart'		=> 'DS',
                'on_type_downtimeend'		=> 'ds',
                'on_type_downtimecancelled'	=> 'dc',
                'on_type_acknowledgement'	=> 'A',
                'on_type_custom'		=> 'C',
	),
);


// Setting the proper value.
if ($dbType == 'mysql'){
    $dbConf = $dbConfMySQL;
};
if ($dbType == 'sqlite3'){
    $dbConf = $dbConfSQLite3;
};

// include language file
$languages = array('en', 'de');
if (!in_array($language, $languages)) $language = $languages[0]; 
require_once('lang/' . $language . '.php');


// include developer config
if (file_exists('config/config_override.php')) {
	include_once('config/config_override.php');
}


?>
