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

require_once('config/config.php');
require_once('classes/class_nwTemplate.php');
require_once('inc/html.php');
require_once('inc/change_notifications.php');
require_once('inc/change_contacts.php');
require_once('inc/change_contactgroups.php');
require_once('inc/change_timeframes.php');
require_once('inc/authentication.php');
require_once('inc/content_funcs.php');


$html = new nwTemplate(TEMPLATE_INDEX);

$p = array_merge($_GET, $_POST);


#var_dump($p);exit;

session_start();

$action = null;
if (isset($p['action'])) {
	$action = $p['action'];
}


// check user
$authUser = null;
if ($authentication_type) {
	$authUser = getAuthUser();
	if (empty($authUser)) $action = null;
}


// no logout w/o authentication
if (!$authentication_type && $action == 'logout') $action = null;


// asynchronous preview call
if (isset($p['preview']) && $notifications['host_service_preview']) {
	require_once('inc/preview_host_service.php');
	exit;
}


// main routine
switch ($action) {

	case 'add':
	case 'edit':
	case 'add_escalation':
		$require = 'inc/content_add-edit.php';
		break;

	case 'remove_escalation':
		if (deleteEscalationByEscalationId($p['eid'])) $message = ADD_EDIT_ESCALATION_DELETED;
		else $message = ADD_EDIT_ESCALATION_ERROR;
		$require = 'inc/content_add-edit.php';
		break;

	case 'add_new':
		if (!addNotification($p)) $message = OVERVIEW_NOTIFICATION_ADD_UPDATE_ERROR;
		else $message = OVERVIEW_NOTIFICATION_ADDED;
		$require = 'inc/content_overview.php';
		break;

	case 'update':
		if (!updateNotification($p)) $message = ADD_EDIT_NOTIFICATION_ADD_UPDATE_ERROR;
		else $message = ADD_EDIT_NOTIFICATION_UPDATED;
		$require = 'inc/content_add-edit.php';
		break;

	case 'toggle_active':
		if (toggleActive($p['id'])) $message = OVERVIEW_TOGGLE_OK;
		else $message = OVERVIEW_TOGGLE_ERROR;
		$require = 'inc/content_overview.php';
		break;

	case 'del':
		deleteNotification($p['id']);
		$require = 'inc/content_overview.php';
		break;

	case 'overview':
		$require = 'inc/content_overview.php';
		break;

	case 'logout':
		session_destroy();
		$message = LOGIN_LOGOUT;
		$require = 'inc/content_login.php';
		break;

        case 'timeframes':
                if (isset($p['submit'])) $do = 'add';
                else if (isset($p['edit'])) $do = 'edit';
                else if (isset($p['del'])) $do = 'del';
                else $do = null;

                if ($do == 'add') {
                        if (empty($p['id'])) {
                                $message = addTimeframe($p);
                        } else {
                                $message = updateTimeframe($p);
                        }
                } else if ($do == 'del') {
                        if (isset($p['timeframe'])) {
                                if (!delTimeframe($p)) $message = TIMEFRAME_ADD_UPDATE_DEL_ERROR;
                                else $message = TIMEFRAME_DELETED;
                        } else {
                                $message = TIMEFRAME_ADD_UPDATE_DEL_ERROR;
                        }
                }
                $require = 'inc/content_timeframes.php';
                break;

	case 'contacts':
		if (isset($p['submit'])) $do = 'add';
		else if (isset($p['edit'])) $do = 'edit';
		else if (isset($p['del'])) $do = 'del';
		else $do = null;

		if ($do == 'add') {
			if (empty($p['id'])) {
				$message = addContact($p);
			} else {
				$message = updateContact($p);
			}
		} else if ($do == 'del') {
			if (isset($p['user'])) {
				if (!delContact($p)) $message = CONTACTS_ADD_UPDATE_DEL_ERROR;
				else $message = CONTACTS_DELETED;
			} else {
				$message = CONTACTS_ADD_UPDATE_DEL_ERROR;
			}
		}
		$require = 'inc/content_contact_manager.php';
		break;

	case 'contactgroups':
		$valid_user = false;
		if ($contactgroups['admin_only']) {
			if (isAdmin()) $valid_user = true;
		} else {
			$valid_user = true;
		}

		if ($valid_user) {

			if (isset($p['add'])) {
				if(addContactGroup()) $message = CONTACTGROUPS_GROUP_ADDED;
				else $message = CONTACTGROUPS_ADDING_FAILED;
			} elseif (isset($p['update'])) {
				if(updateContactGroup()) $message = CONTACTGROUPS_GROUP_UPDATE;
				else $message = CONTACTGROUPS_UPDATE_FAILED;
			} elseif (isset($p['delete'])) {
				if (deleteContactGroup()) {
					$message = CONTACTGROUPS_GROUP_DELETED;
					unset($p['id']);
					unset($p['contactgroup']);
				} else $message = CONTACTGROUPS_DELETE_FAILED;
			}

			$require = 'inc/content_contactgroup_manager.php';			

		} else {

			$require = 'inc/content_overview.php';

		}

		break;

	case 'status':
		if ($statuspage['admin_only']) { // link with logs access 
			if (isAdmin()) {
				$require = 'inc/content_status_viewer.php';
			} else {
				$require = 'inc/content_overview.php';
			}
		} else {
			$require = 'inc/content_status_viewer.php';
		}
		break;

	case 'logs':
		if ($logs['admin_only']) {
			if (isAdmin()) {
				$require = 'inc/content_log_viewer.php';
			} else {
				$require = 'inc/content_overview.php';
			}
		} else {
			$require = 'inc/content_log_viewer.php';
		}
		break;

	default:
		if ($authentication_type) {
			if (empty($_SESSION['user']) && (empty($_POST['username']) || empty($_POST['password']))) {
				if ($authentication_type == 'http') {
					authenticateUser();
					if (empty($_SESSION['user'])) {
						$require = 'inc/content_login.php';
					} else {
						$require = 'inc/content_overview.php';
					}
				} else {
					$require = 'inc/content_login.php';
				}
			} else {
				if (empty($_SESSION['user'])) {
						authenticateUser();
						if (empty($_SESSION['user'])) {
							$message = LOGIN_FAIL;
							$require = 'inc/content_login.php';
						} else {
							$require = 'inc/content_overview.php';
						}
				} else {
							$require = 'inc/content_overview.php';
				}
			}
		} else {
			$require = 'inc/content_overview.php';
		}
		break;

}


require_once($require);

if ($require == 'inc/content_add-edit.php') {
	if (isset($notifications['preview_max_height'])) {
		if ($notifications['preview_max_height'] > 0) {
			$html->assign('MAX_HEIGHT', $notifications['preview_max_height']);
			$html->assign('MAX_HEIGHT_DEC', $notifications['preview_max_height'] - 1);
		}
	}
}

if ($require != 'inc/content_login.php') {
	$html->assign('NAVIGATION_CONTENT', getNavigationContent($action, isAdmin()));
}

$version = null;
if (file_exists('doc/VERSION.txt') && is_readable('doc/VERSION.txt')) {
	if (($version = file_get_contents('doc/VERSION.txt')) === false) {
		$version = null;
	} else {
		$version = str_replace(' ', '&#160;', $version);
		$version = '&#160;' . $version;
	}
}
$html->assign('VERSION', $version);
if (!empty($_SERVER['TRACKING_ID'])) {
    $html->assign('TRACKING_ID', '<script type="text/javascript">var gaJsHost=(("https:"==document.location.protocol)?"https://ssl.":"http://www.");document.write(unescape("%3Cscript src=\'"+gaJsHost+"google-analytics.com/ga.js\' type=\'text/javascript\'%3E%3C/script%3E"));</script><script type="text/javascript">try{var pageTracker=_gat._getTracker("'.$_SERVER['TRACKING_ID'].'");pageTracker._trackPageview();}catch(err){}</script>');
}

$html->assign('MAIN_CONTENT', getContent());
$html->show();

?>
