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
define('NAVIGATION_OVERVIEW', '&Uuml;bersicht');
define('NAVIGATION_NOTIFICATION', 'Benachrichtigung');
define('NAVIGATION_CONTACTS', 'Kontakte');
define('NAVIGATION_PROFILE', 'Profil');
define('NAVIGATION_CONTACTGROUPS', 'Kontaktgruppen');
define('NAVIGATION_STATUS', 'Status');
define('NAVIGATION_LOGS', 'Log');
define('NAVIGATION_LOGOUT', 'ABMELDEN');


// Uebersicht
define('OVERVIEW_LOGOUT', 'Abmelden');
define('OVERVIEW_ADD_NEW_NOTIFICATION', 'Neue Benarichtigung hinzuf&uuml;gen');
define('OVERVIEW_MANAGE_CONTACTS', 'Kontakte verwalten');
define('OVERVIEW_MANAGE_CONTACTGROUPS', 'Kontaktgruppen verwalten');
define('OVERVIEW_LOG_VIEWER', 'Benachrichtigungsverlauf einsehen');
define('OVERVIEW_EDIT_USER_PROFILE', 'Benutzerprofil ändern');
define('OVERVIEW_HEADING_ACTIONS', 'Aktionen');
define('OVERVIEW_HEADING_HOSTS', 'Hosts');
define('OVERVIEW_HEADING_SERVICES', 'Services');
define('OVERVIEW_HEADING_OWNER', 'Besitzer');
define('OVERVIEW_HEADING_NOTIFICATION_RULE', 'Nr.');
define('OVERVIEW_HEADING_TIMEZONE', 'Zeitzone');
define('OVERVIEW_HEADING_NOTIFY_ON', 'Benachr. bei');
define('OVERVIEW_HEADING_NOTIFY_BY', 'Benachr. durch');
define('OVERVIEW_HEADING_NOTIFY_USERS', 'Zu benachr. Personen');
define('OVERVIEW_LONG_INCLUDE_HEADING', 'Eingeschlossen');
define('OVERVIEW_LONG_EXCLUDE_HEADING', 'Ausgeschlossen');
define('OVERVIEW_TOGGLE_ACTIVE_ALT', 'De-/Aktivieren');
define('OVERVIEW_ACTIVE_TOOLTIP', 'Deaktivieren');
define('OVERVIEW_INACTIVE_TOOLTIP', 'Aktivieren');
define('OVERVIEW_ACTIVE_TOOLTIP_DISABLED', 'UMSCHALTEN DEAKTIVIERT');
define('OVERVIEW_INACTIVE_TOOLTIP_DISABLED', 'UMSCHALTEN DEAKTIVIERT');
define('OVERVIEW_TOGGLE_ACTIVE_ALT_DISABLED', 'UMSCHALTEN DEAKTIVIERT');
define('OVERVIEW_EDIT_ENTRY_ALT_TOOLTIP', 'Eintrag bearbeiten');
define('OVERVIEW_DELETE_ENTRY_ALT_TOOLTIP', 'Eintrag l&ouml;schen');
define('OVERVIEW_NOTIFICATION_UPDATED', 'Benachrichtigung aktualisiert.');
define('OVERVIEW_NOTIFICATION_ADDED', 'Benachrichtigung hinzugef&uuml;gt.');
define('OVERVIEW_NOTIFICATION_ADD_UPDATE_ERROR', 'Fehler w&auml;hrend der Operation!');
define('OVERVIEW_TOGGLE_OK', 'Status wurde ge&auml;ndert.');
define('OVERVIEW_TOGGLE_ERROR', 'Ung&uuml;ltiger Benutzer!');
define('OVERVIEW_CONTACTGROUP_PREFIX', 'Grp:');


// Benachrichtigungen hinzufuegen / bearbeiten
define('ADD_EDIT_OVERVIEW_LINK', '&Uuml;bersicht');
define('ADD_EDIT_HEADING_NEW', 'Neue Benachrichtigung hinzuf&uuml;gen');
define('ADD_EDIT_HEADING_EDIT', 'Benachrichtigung bearbeiten');
define('ADD_EDIT_HEADING_HOSTS_AND_SERVICES', 'Hosts und Services:');
define('ADD_EDIT_HEADING_TIME', 'Zeit:');
define('ADD_EDIT_HEADING_CONTACTS_METHODS', 'Kontakte und Methoden:');
define('ADD_EDIT_HEADING_NOTIFICATION', 'Benachrichtigungen:');
define('ADD_EDIT_HEADING_OWNER', 'Besitzer:');
define('ADD_EDIT_INCLUDE_HOSTGROUPS', 'Einzuschlie&szlig;ende Hostgruppen:');
define('ADD_EDIT_EXCLUDE_HOSTGROUPS', 'Auszuschlie&szlig;ende Hostgruppen:');
define('ADD_EDIT_INCLUDE_HOSTS', 'Einzuschlie&szlig;ende Hosts:');
define('ADD_EDIT_EXCLUDE_HOSTS', 'Auszuschlie&szlig;ende Hosts:');
define('ADD_EDIT_INCLUDE_SERVICES', 'Einzuschlie&szlig;ende Services:');
define('ADD_EDIT_EXCLUDE_SERVICES', 'Auszuschlie&szlig;ende Services:');
define('ADD_EDIT_INCLUDE_SERVICEGROUPS', 'Einzuschlie&szlig;ende Servicegruppen:');
define('ADD_EDIT_EXCLUDE_SERVICEGROUPS', 'Auszuschlie&szlig;ende Servicegruppen:');
define('ADD_EDIT_TIMEZONE', 'Zeitzone:');
define('ADD_EDIT_OWNER', 'Besitzer:');
define('ADD_EDIT_NOTIFY_USERS', 'Zu benachrichtigende Personen:');
define('ADD_EDIT_NOTIFY_GROUPS', 'Zu benachrichtigende Gruppen:');
define('ADD_EDIT_NOTIFY_BY', 'Benachrichtigung durch:');
define('ADD_EDIT_NOTIFY_ON', 'Benachrichtigung bei:');
define('ADD_EDIT_SUBMIT', 'Speichern');
define('ADD_EDIT_BUTTON_ADD_ESCALATION', 'Eskalation hinzuf&uuml;gen');
define('ADD_EDIT_CONFIRM_ADD_ESCALATION', 'Alle ungesicherten Daten gehen verloren! Sicher?');
define('ADD_EDIT_BUTTON_REMOVE_ESCALATION', 'Eskalation entfernen');
define('ADD_EDIT_CONFIRM_REMOVE_ESCALATION', 'Diese Eskalation sicher entfernen?');
define('ADD_EDIT_NOTIFY_AFTER_TRIES', 'Benachrichtigung nach:');
define('ADD_EDIT_LET_NOTIFIER_HANDLE', 'Eskalationsvorgehen an notifier &uuml;bergeben:');
define('ADD_EDIT_RELOOP_DELAY', 'Verz&ouml;gerung (in s) zwischen den Eskalationen:');
define('ADD_EDIT_ROLLOVER', 'Counter zur&uuml;cksetzen beim &Uuml;berlauf:');
define('ADD_EDIT_NUM_NOTIFICATIONS', '(Anzahl der Benachrichtigungen)');
define('ADD_EDIT_ESCALATION_DELETED', 'Eskalation wurde gel&ouml;scht.');
define('ADD_EDIT_ESCALATION_ERROR', 'Fehler w&auml;hrend der Operation!');
define('ADD_EDIT_NOTIFICATION_ADD_UPDATE_ERROR', 'Fehler w&auml;hrend der Operation!');
define('ADD_EDIT_NOTIFICATION_UPDATED', 'Benachrichtigung aktualisiert.');
define('ADD_EDIT_PREVIEW_NO_RESULTS', 'Nichts gefunden.');


// Anmelden
define('LOGIN_HEADING', 'Bitte melden Sie sich an:');
define('LOGIN_USERNAME', 'Benutzername:');
define('LOGIN_PASSWORD', 'Passwort:');
define('LOGIN_SUBMIT', 'Anmelden');
define('LOGIN_FAIL', 'Anmeldung fehlgeschlagen!');
define('LOGIN_LOGOUT', 'Sie wurden abgemeldet.');


// Kontakte verwalten
define('CONTACTS_OVERVIEW_LINK', '&Uuml;bersicht');
define('CONTACTS_ADD_EDIT_USER', 'Benutzer anlegen und bearbeiten');
define('CONTACTS_EDIT_USER', 'Benutzer bearbeiten');
define('CONTACTS_SELECT_USER_NEW', 'neu erstellen');
define('CONTACTS_HEADING_NAME' , 'Name:');
define('CONTACTS_HEADING_CONTACT' , 'Kontakt:');
define('CONTACTS_HEADING_TIME' , 'Zeitangaben:');
define('CONTACTS_HEADING_ADMIN' , 'Administratorenfunktionen:');
define('CONTACTS_HEADING_HOLIDAYS' , 'Urlaub:');
define('CONTACTS_NEW_USERNAME', 'Benutzer neu anlegen (username):');
define('CONTACTS_FIRST_NAME', 'Vorname:');
define('CONTACTS_LAST_NAME', 'Nachname:');
define('CONTACTS_USERNAME', 'Login:');
define('CONTACTS_PASSWORD', 'Passwort:');
define('CONTACTS_PASSWORD_VERIFY', 'Passwort (Wiederholung):');
define('CONTACTS_EMAIL', 'E-Mail:');
define('CONTACTS_PHONE', 'Telefon:');
define('CONTACTS_MOBILE', 'Mobiltelefon:');
define('CONTACTS_RESTRICT_ALERTS', 'Mehrfachbenachrichtigungen unterdr&uuml;cken:');
define('CONTACTS_TIMEPERIOD', 'Arbeitszeit:');
define('CONTACTS_TIMEZONE', 'Zeitzone:');
define('CONTACTS_USER', 'Benutzerauswahl:');
define('CONTACTS_ADMIN', 'Administrator:');
define('CONTACTS_EDIT_BUTTON', 'Benutzer ausw&auml;hlen');
define('CONTACTS_DEL_BUTTON', 'Benutzer l&ouml;schen');
define('CONTACTS_SUBMIT_ADD', 'Benutzer hinzuf&uuml;gen');
define('CONTACTS_SUBMIT_UPDATE', 'Benutzer aktualisieren');
define('CONTACTS_CONFIRM_DEL', 'M&ouml;chten Sie diesen Benutzer wirklich l&ouml;schen?');
define('CONTACTS_HOLIDAYS_START', 'Beginn (yyyy-mm-dd hh:ii):');
define('CONTACTS_HOLIDAYS_END', 'Ende (yyyy-mm-dd hh:ii):');
define('CONTACTS_HOLIDAYS_DELETE', 'L&ouml;schen');
define('CONTACTS_UPDATED', 'Benutzer wurde aktualisiert.');
define('CONTACTS_ADDED', 'Benutzer wurde hinzugef&uuml;gt.');
define('CONTACTS_DELETED', 'Benutzer wurde gel&ouml;scht.');
define('CONTACTS_ADD_UPDATE_DEL_ERROR', 'Fehler w&auml;hrend der Operation!');
define('CONTACTS_ADD_UPDATE_ERROR_PASSWD_MISMATCH', 'Die eingegebenen Passw&ouml;rter stimmen nicht &uuml;berein!');
define('CONTACTS_ADD_UPDATE_ERROR_INSUFF_RIGHTS', 'Sie besitzen keine ausreichenden Rechte f&uuml;r diese &Auml;nderungen!');
define('CONTACTS_ADD_USER_EXISTS', 'Benutzer existiert bereits!');
define('CONTACTS_ADD_UPDATE_PASSWD_MISSING', 'Kein Passwort gesetzt!');
define('CONTACTS_ADD_ADDED_BUT_NOT_IN_DB', 'Benutzer wurde angelegt aber Datenbank wurde noch nicht aktualisiert.');


// Benachrichtigungsverlauf
define('LOG_VIEWER_OVERVIEW_LINK', '&Uuml;bersicht');
define('LOG_VIEWER_HEADING', 'Benachrichtigungsverlauf');
define('LOG_VIEWER_FIND', 'Suche:');
define('LOG_VIEWER_NUM_RESULTS', 'Anzahl der Resultate pro Seite:');
define('LOG_VIEWER_HEADING_NOTIFICATION_RULE', 'Regel');
define('LOG_VIEWER_HEADING_TIMESTAMP', 'Zeit');
define('LOG_VIEWER_HEADING_CHECK_TYPE', 'Art des checks');
define('LOG_VIEWER_HEADING_HOST', 'Host');
define('LOG_VIEWER_HEADING_SERVICE', 'Service');
define('LOG_VIEWER_HEADING_CHECK_RESULT', 'Check status');
define('LOG_VIEWER_HEADING_METHOD', 'Benachrichtigungsmethode');
define('LOG_VIEWER_HEADING_USER', 'Empf&auml;nger');
define('LOG_VIEWER_HEADING_RESULT', 'Benachrichtigungsresultat');
define('LOG_VIEWER_FIND_SUBMIT', 'Abschicken');


// Kontaktgruppen verwalten
define('CONTACTGROUPS_OVERVIEW_LINK', '&Uuml;bersicht');
define('CONTACTGROUPS_HEADING', 'Kontaktgruppen verwalten');
define('CONTACTGROUPS_HEADING_SELECT', 'Kontaktgruppe ausw&auml;hlen:');
define('CONTACTGROUPS_HEADING_ADD', 'Kontaktgruppe hinzuf&uuml;gen:');
define('CONTACTGROUPS_SELECT_GROUP_NEW', 'neu erstellen');
define('CONTACTGROUPS_EDIT_GROUPS', 'Kontaktgruppe:');
define('CONTACTGROUPS_EDIT_USERS', 'Kontakt(e):');
define('CONTACTGROUPS_EDIT_BUTTON', 'Bearbeiten');
define('CONTACTGROUPS_ADD_BUTTON', 'Hinzuf&uuml;gen');
define('CONTACTGROUPS_DELETE_BUTTON', 'L&ouml;schen');
define('CONTACTGROUPS_ADD_NAME_SHORT', 'Neue Gruppe (K&uuml;rzel):');
define('CONTACTGROUPS_ADD_NAME', 'Neue Gruppe (lange Form):');
define('CONTACTGROUPS_SUBMIT_CHANGES_BUTTON', '&Auml;nderungen best&auml;tigen');
define('CONTACTGROUPS_HEADING_EDIT', 'Kontaktgruppe bearbeiten:');
define('CONTACTGROUPS_GROUP_ADDED', 'Erfolgreich neue Kontaktgruppe angelegt!');
define('CONTACTGROUPS_ADDING_FAILED', 'Konnte keine neue Kontaktgruppe anlegen!');
define('CONTACTGROUPS_GROUP_UPDATE', 'Kontaktgruppe aktualisiert!');
define('CONTACTGROUPS_UPDATE_FAILED', 'Konnte Kontaktgruppe nicht aktualisieren!');
define('CONTACTGROUPS_GROUP_DELETED', 'Kontaktgruppe gel&ouml;scht!');
define('CONTACTGROUPS_DELETE_FAILED', 'Konnte Kontaktgruppe nicht l&ouml;schen!');
define('CONTACTGROUPS_EDIT_NAME_SHORT', 'Name (K&uuml;rzel):');
define('CONTACTGROUPS_EDIT_NAME', 'Name:');
define('CONTACTGROUP_CONFIRM_DEL', 'M&ouml;chten Sie diese Kontaktgruppe wirklich l&ouml;schen?');
define('CONTACTGROUPS_VIEW_ONLY', 'Keine Benachrichtigungen an Mitglieder versenden:');

?>
