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


// navigation
define('NAVIGATION_OVERVIEW', 'Overview');
define('NAVIGATION_NOTIFICATION', 'Notification');
define('NAVIGATION_CONTACTS', 'Contacts');
define('NAVIGATION_PROFILE', 'Profile');
define('NAVIGATION_CONTACTGROUPS', 'Contactgroups');
define('NAVIGATION_STATUS', 'Status');
define('NAVIGATION_LOGS', 'Logs');
define('NAVIGATION_LOGOUT', 'LOGOUT');


// overview
define('OVERVIEW_LOGOUT', 'Logout');
define('OVERVIEW_ADD_NEW_NOTIFICATION', 'Add new notification');
define('OVERVIEW_MANAGE_CONTACTS', 'Manage contacts');
define('OVERVIEW_MANAGE_CONTACTGROUPS', 'Manage contactgroups');
define('OVERVIEW_LOG_VIEWER', 'View logs');
define('OVERVIEW_EDIT_USER_PROFILE', 'Edit user profile');
define('OVERVIEW_HEADING_ACTIONS', 'Actions');
define('OVERVIEW_HEADING_HOSTGROUPS', 'Hostgroups');
define('OVERVIEW_HEADING_HOSTS', 'Hosts');
define('OVERVIEW_HEADING_SERVICES', 'Services');
define('OVERVIEW_HEADING_OWNER', 'Owner');
define('OVERVIEW_HEADING_NOTIFICATION_RULE', 'No.');
define('OVERVIEW_HEADING_TIMEZONE', 'Timezone');
define('OVERVIEW_HEADING_NOTIFY_ON', 'Notify on');
define('OVERVIEW_HEADING_NOTIFY_BY', 'Notify by');
define('OVERVIEW_HEADING_NOTIFY_USERS', 'Notify users');
define('OVERVIEW_LONG_INCLUDE_HEADING', 'Include');
define('OVERVIEW_LONG_EXCLUDE_HEADING', 'Exclude');
define('OVERVIEW_TOGGLE_ACTIVE_ALT', 'Toggle active');
define('OVERVIEW_ACTIVE_TOOLTIP', 'Deactivate');
define('OVERVIEW_INACTIVE_TOOLTIP', 'Activate');
define('OVERVIEW_ACTIVE_TOOLTIP_DISABLED', 'TOGGLING DISABLED');
define('OVERVIEW_INACTIVE_TOOLTIP_DISABLED', 'TOGGLING DISABLED');
define('OVERVIEW_TOGGLE_ACTIVE_ALT_DISABLED', 'TOGGLING DISABLED');
define('OVERVIEW_EDIT_ENTRY_ALT_TOOLTIP', 'Edit entry');
define('OVERVIEW_DELETE_ENTRY_ALT_TOOLTIP', 'Delete entry');
define('OVERVIEW_NOTIFICATION_UPDATED', 'Notification updated.');
define('OVERVIEW_NOTIFICATION_ADDED', 'Notification added.');
define('OVERVIEW_NOTIFICATION_ADD_UPDATE_ERROR', 'An error occurred!');
define('OVERVIEW_TOGGLE_OK', 'Status changed.');
define('OVERVIEW_TOGGLE_ERROR', 'Invalid user!');
define('OVERVIEW_CONTACTGROUP_PREFIX', 'Grp:');


// add/edit notification
define('ADD_EDIT_OVERVIEW_LINK', 'Overview');
define('ADD_EDIT_HEADING_NEW', 'Add new notification');
define('ADD_EDIT_HEADING_EDIT', 'Edit notification');
define('ADD_EDIT_HEADING_HOSTS_AND_SERVICES', 'Hosts and services:');
define('ADD_EDIT_HEADING_TIME', 'Time:');
define('ADD_EDIT_HEADING_CONTACTS_METHODS', 'Contacts and methods:');
define('ADD_EDIT_HEADING_NOTIFICATION', 'Notifications:');
define('ADD_EDIT_HEADING_OWNER', 'Owner:');
define('ADD_EDIT_INCLUDE_HOSTGROUPS', 'Include hostgroups:');
define('ADD_EDIT_EXCLUDE_HOSTGROUPS', 'Exclude hostgroups:');
define('ADD_EDIT_INCLUDE_HOSTS', 'Include hosts:');
define('ADD_EDIT_EXCLUDE_HOSTS', 'Exclude hosts:');
define('ADD_EDIT_INCLUDE_SERVICES', 'Include services:');
define('ADD_EDIT_EXCLUDE_SERVICES', 'Exclude services:');
define('ADD_EDIT_INCLUDE_SERVICEGROUPS', 'Include servicegroups:');
define('ADD_EDIT_EXCLUDE_SERVICEGROUPS', 'Exclude servicegroups:');
define('ADD_EDIT_TIMEZONE', 'Timezone:');
define('ADD_EDIT_OWNER', 'Owner:');
define('ADD_EDIT_NOTIFY_USERS', 'Notify users:');
define('ADD_EDIT_NOTIFY_GROUPS', 'Notify groups:');
define('ADD_EDIT_NOTIFY_BY', 'Notify by:');
define('ADD_EDIT_NOTIFY_ON', 'Notify on:');
define('ADD_EDIT_SUBMIT', 'Save');
define('ADD_EDIT_BUTTON_ADD_ESCALATION', 'Add escalation');
define('ADD_EDIT_CONFIRM_ADD_ESCALATION', 'All unsaved data will be lost. Are you sure?');
define('ADD_EDIT_BUTTON_REMOVE_ESCALATION', 'Remove escalation');
define('ADD_EDIT_CONFIRM_REMOVE_ESCALATION', 'Do you really want to remove this escalation?');
define('ADD_EDIT_NOTIFY_AFTER_TRIES', 'Notify after:');
define('ADD_EDIT_LET_NOTIFIER_HANDLE', 'Let notifier handle escalations:');
define('ADD_EDIT_RELOOP_DELAY', 'Delay (in s) between escalations:');
define('ADD_EDIT_ROLLOVER', 'Rollover if the last rule is reached:');
define('ADD_EDIT_NUM_NOTIFICATIONS', '(number of notifications)');
define('ADD_EDIT_ESCALATION_DELETED', 'Escalation has been deleted.');
define('ADD_EDIT_ESCALATION_ERROR', 'An error occurred!');
define('ADD_EDIT_NOTIFICATION_ADD_UPDATE_ERROR', 'An error occurred!');
define('ADD_EDIT_NOTIFICATION_UPDATED', 'Notification updated.');
define('ADD_EDIT_PREVIEW_NO_RESULTS', 'No results.');


// login
define('LOGIN_HEADING', 'Please login:');
define('LOGIN_USERNAME', 'User name:');
define('LOGIN_PASSWORD', 'Password:');
define('LOGIN_SUBMIT', 'Submit');
define('LOGIN_FAIL', 'Login failed!');
define('LOGIN_LOGOUT', 'You have been logged out.');


// contact manager
define('CONTACTS_OVERVIEW_LINK', 'Overview');
define('CONTACTS_ADD_EDIT_USER', 'Add and edit users');
define('CONTACTS_EDIT_USER', 'Edit user');
define('CONTACTS_SELECT_USER_NEW', 'create new');
define('CONTACTS_HEADING_NAME' , 'Name:');
define('CONTACTS_HEADING_CONTACT' , 'Contact:');
define('CONTACTS_HEADING_TIME' , 'Time:');
define('CONTACTS_HEADING_ADMIN' , 'Admin functions:');
define('CONTACTS_HEADING_HOLIDAYS' , 'Holidays:');
define('CONTACTS_NEW_USERNAME', 'Add user (username):');
define('CONTACTS_FIRST_NAME', 'First name:');
define('CONTACTS_LAST_NAME', 'Last name:');
define('CONTACTS_USERNAME', 'User login:');
define('CONTACTS_PASSWORD', 'Password:');
define('CONTACTS_PASSWORD_VERIFY', 'Password (verification):');
define('CONTACTS_EMAIL', 'E-Mail:');
define('CONTACTS_PHONE', 'Phone:');
define('CONTACTS_MOBILE', 'Mobile:');
define('CONTACTS_RESTRICT_ALERTS', 'Suppress multiple alerts:');
define('CONTACTS_TIMEPERIOD', 'Working hours:');
define('CONTACTS_TIMEZONE', 'Timezone:');
define('CONTACTS_USER', 'User to edit:');
define('CONTACTS_ADMIN', 'Administrator:');
define('CONTACTS_EDIT_BUTTON', 'Select user');
define('CONTACTS_DEL_BUTTON', 'Delete user');
define('CONTACTS_SUBMIT_ADD', 'Add user');
define('CONTACTS_SUBMIT_UPDATE', 'Update user data');
define('CONTACTS_CONFIRM_DEL', 'Do you really want to delete this contact?');
define('CONTACTS_HOLIDAYS_START', 'Start (yyyy-mm-dd hh:ii):');
define('CONTACTS_HOLIDAYS_END', 'End (yyyy-mm-dd hh:ii):');
define('CONTACTS_HOLIDAYS_DELETE', 'Delete');
define('CONTACTS_UPDATED', 'Contact has been updated.');
define('CONTACTS_ADDED', 'Contact has been added.');
define('CONTACTS_DELETED', 'Contact has been deleted.');
define('CONTACTS_ADD_UPDATE_DEL_ERROR', 'An error occurred!');
define('CONTACTS_ADD_UPDATE_ERROR_PASSWD_MISMATCH', 'Password mismatch!');
define('CONTACTS_ADD_UPDATE_ERROR_INSUFF_RIGHTS', 'Insufficient rights to apply changes!');
define('CONTACTS_ADD_USER_EXISTS', 'User already exists!');
define('CONTACTS_ADD_UPDATE_PASSWD_MISSING', 'No Password set!');
define('CONTACTS_ADD_ADDED_BUT_NOT_IN_DB', 'Contact added but database has not been updated, yet.');


// log viewer
define('LOG_VIEWER_OVERVIEW_LINK', 'Overview');
define('LOG_VIEWER_HEADING', 'Log viewer');
define('LOG_VIEWER_FIND', 'Find:');
define('LOG_VIEWER_NUM_RESULTS', 'Number of results to display:');
define('LOG_VIEWER_HEADING_NOTIFICATION_RULE', 'Rule');
define('LOG_VIEWER_HEADING_TIMESTAMP', 'Time');
define('LOG_VIEWER_HEADING_CHECK_TYPE', 'Check type');
define('LOG_VIEWER_HEADING_HOSTGROUP', 'Hostgroup');
define('LOG_VIEWER_HEADING_HOST', 'Host');
define('LOG_VIEWER_HEADING_SERVICE', 'Service');
define('LOG_VIEWER_HEADING_SERVICEGROUP', 'Servicegroup');
define('LOG_VIEWER_HEADING_CHECK_RESULT', 'Check status');
define('LOG_VIEWER_HEADING_METHOD', 'Notification method');
define('LOG_VIEWER_HEADING_USER', 'Recipient');
define('LOG_VIEWER_HEADING_RESULT', 'Notification result');
define('LOG_VIEWER_FIND_SUBMIT', 'Submit');


// contactgroup manager
define('CONTACTGROUPS_OVERVIEW_LINK', 'Overview');
define('CONTACTGROUPS_HEADING', 'Manage contactgroups');
define('CONTACTGROUPS_HEADING_SELECT', 'Select contactgroup:');
define('CONTACTGROUPS_HEADING_ADD', 'Add contactgroup:');
define('CONTACTGROUPS_SELECT_GROUP_NEW', 'create new');
define('CONTACTGROUPS_EDIT_GROUPS', 'Contactgroup:');
define('CONTACTGROUPS_EDIT_USERS', 'User(s):');
define('CONTACTGROUPS_EDIT_BUTTON', 'Edit group');
define('CONTACTGROUPS_ADD_BUTTON', 'Add group');
define('CONTACTGROUPS_DELETE_BUTTON', 'Delete group');
define('CONTACTGROUPS_ADD_NAME_SHORT', 'New group (short name):');
define('CONTACTGROUPS_ADD_NAME', 'New group (long name):');
define('CONTACTGROUPS_SUBMIT_CHANGES_BUTTON', 'Submit changes');
define('CONTACTGROUPS_HEADING_EDIT', 'Edit contact group:');
define('CONTACTGROUPS_GROUP_ADDED', 'Successfully created new group!');
define('CONTACTGROUPS_ADDING_FAILED', 'Could not add new group!');
define('CONTACTGROUPS_GROUP_UPDATE', 'Group updated!');
define('CONTACTGROUPS_UPDATE_FAILED', 'Could not update group!');
define('CONTACTGROUPS_GROUP_DELETED', 'Group deleted!');
define('CONTACTGROUPS_DELETE_FAILED', 'Could not delete group!');
define('CONTACTGROUPS_EDIT_NAME_SHORT', 'Name (short):');
define('CONTACTGROUPS_EDIT_NAME', 'Name:');
define('CONTACTGROUP_CONFIRM_DEL', 'Do you really want to delete this contactgroup?');
define('CONTACTGROUPS_VIEW_ONLY', 'Do not send notifications to members:');

?>
