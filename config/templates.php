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

define('TEMPLATE_DIR', 'templates/');

define('TEMPLATE_INDEX', TEMPLATE_DIR . 'index.html');

define('TEMPLATE_NAVIGATION', TEMPLATE_DIR . 'navigation.html');
define('TEMPLATE_NAVIGATION_LINK', TEMPLATE_DIR . 'navigation_link.html');

define('TEMPLATE_OVERVIEW', TEMPLATE_DIR . 'overview.html');
define('TEMPLATE_OVERVIEW_ROW', TEMPLATE_DIR . 'overview_row.html');

define('TEMPLATE_LOGIN', TEMPLATE_DIR . 'login.html');

define('TEMPLATE_ADD_EDIT', TEMPLATE_DIR . 'add-edit_notification.html');
define('TEMPLATE_ADD_EDIT_CONTACTS_METHODS', TEMPLATE_DIR . 'add-edit_notification_contacts_methods.html');
define('TEMPLATE_ADD_EDIT_LET_NOTIFIER_HANDLE', TEMPLATE_DIR . 'add-edit_let_notifier_handle.html');

define('TEMPLATE_CONTACT_MANAGER', TEMPLATE_DIR . 'contact_manager.html');
define('TEMPLATE_CONTACT_MANAGER_ADMIN', TEMPLATE_DIR . 'contact_manager_admin.html');
define('TEMPLATE_CONTACT_MANAGER_ADMIN_DELETE', TEMPLATE_DIR . 'contact_manager_admin_delete.html');
define('TEMPLATE_CONTACT_MANAGER_PASSWORD', TEMPLATE_DIR . 'contact_manager_password.html');
define('TEMPLATE_CONTACT_MANAGER_HOLIDAYS_ROW', TEMPLATE_DIR . 'contact_manager_holidays_row.html');

define('TEMPLATE_LOG_VIEWER', TEMPLATE_DIR . 'log_viewer.html');
define('TEMPLATE_LOG_VIEWER_ROW', TEMPLATE_DIR . 'log_viewer_row.html');

define('TEMPLATE_CONTACTGROUP_MANAGER', TEMPLATE_DIR . 'contactgroup_manager.html');
define('TEMPLATE_CONTACTGROUP_MANAGER_ADD', TEMPLATE_DIR . 'contactgroup_manager_add.html');
define('TEMPLATE_CONTACTGROUP_MANAGER_EDIT', TEMPLATE_DIR . 'contactgroup_manager_edit.html');
define('TEMPLATE_CONTACTGROUP_MANAGER_DELETE', TEMPLATE_DIR . 'contactgroup_manager_delete.html');

?>
