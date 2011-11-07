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
define('NAVIGATION_TIMEFRAMES', 'Zeitplan');
define('NAVIGATION_STATUS', 'Status');
define('NAVIGATION_LOGS', 'Log');
define('NAVIGATION_LOGOUT', 'ABMELDEN');

// generic
define('GENERIC_YES', 'Ja');
define('GENERIC_NO', 'Nein');
define('LINKED_OBJECTS','Verlinkte Objekte zeigen');
define('LINKED_OBJECTS_SHOW','Verlinkte Objekte anzeigen');
define('LINKED_OBJECTS_HIDE','Verlinkte Objekte ausblenden');

// overview
define('OVERVIEW_LOGOUT', 'Abmelden');
define('OVERVIEW_ADD_NEW_NOTIFICATION', 'Neue Benachrichtigung hinzuf&uuml;gen');
define('OVERVIEW_MANAGE_CONTACTS', 'Kontakte verwalten');
define('OVERVIEW_MANAGE_CONTACTGROUPS', 'Kontaktgruppen verwalten');
define('OVERVIEW_MANAGE_RECIPIENTS', 'Empf&auml;nger verwalten');
define('OVERVIEW_LOG_VIEWER', 'Nachrichtenverlauf einsehen');
define('OVERVIEW_EDIT_USER_PROFILE', 'Benutzerprofil &auml;ndern');
define('OVERVIEW_HEADING_NOTIFICATION_NAME', 'Name');
define('OVERVIEW_HEADING_ACTIONS', 'Aktionen');
define('OVERVIEW_HEADING_RECIPIENTS', 'Empf&auml;nger');
define('OVERVIEW_HEADING_HOSTGROUPS', 'Hostgruppen');
define('OVERVIEW_HEADING_HOSTS', 'Hosts');
define('OVERVIEW_HEADING_SERVICEGROUPS', 'Servicegruppen');
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
define('OVERVIEW_DELETE_ENTRY_CONFIRM', 'Diese Benachrichtigung wirklich entfernen?');
define('OVERVIEW_NOTIFICATION_UPDATED', 'Benachrichtigung aktualisiert.');
define('OVERVIEW_NOTIFICATION_ADDED', 'Benachrichtigung hinzugef&uuml;gt.');
define('OVERVIEW_NOTIFICATION_ADD_UPDATE_ERROR', 'Fehler w&auml;hrend der Operation!');
define('OVERVIEW_TOGGLE_OK', 'Status wurde ge&auml;ndert.');
define('OVERVIEW_TOGGLE_ERROR', 'Ung&uuml;ltiger Benutzer!');
define('OVERVIEW_CONTACTGROUP_PREFIX', 'Grp:');


// add/edit notification
define('ADD_EDIT_OVERVIEW_LINK', '&Uuml;bersicht');
define('ADD_EDIT_HEADING_NEW', 'Neue Benachrichtigung hinzuf&uuml;gen');
define('ADD_EDIT_HEADING_EDIT', 'Benachrichtigung bearbeiten');
define('ADD_EDIT_HEADING_HOSTS_AND_SERVICES', 'Hosts und Services:');
define('ADD_EDIT_HEADING_TIME', 'Zeit:');
define('ADD_EDIT_HEADING_CONTACTS_METHODS', 'Kontakte und Methoden:');
define('ADD_EDIT_HEADING_NOTIFICATION', 'Benachrichtigungen:');
define('ADD_EDIT_HEADING_OWNER', 'Besitzer:');
define('ADD_EDIT_INCLUDE_HOSTGROUPS', 'Hostgruppen einschlie&szlig;en:');
define('ADD_EDIT_EXCLUDE_HOSTGROUPS', 'Hostgruppen ausschlie&szlig;en:');
define('ADD_EDIT_INCLUDE_HOSTS', 'Hosts einschlie&szlig;en:');
define('ADD_EDIT_EXCLUDE_HOSTS', 'Hosts ausschlie&szlig;en:');
define('ADD_EDIT_INCLUDE_SERVICES', 'Services einschlie&szlig;en:');
define('ADD_EDIT_EXCLUDE_SERVICES', 'Services ausschlie&szlig;en:');
define('ADD_EDIT_INCLUDE_SERVICEGROUPS', 'Servicegruppen einschlie&szlig;en:');
define('ADD_EDIT_EXCLUDE_SERVICEGROUPS', 'Servicegruppen ausschlie&szlig;en:');
define('ADD_EDIT_INCLUDE_RECIPIENTS', 'Empf&auml;nger einschlie&szlig;en:');
define('ADD_EDIT_EXCLUDE_RECIPIENTS', 'Empf&auml;nger ausschlie&szlig;en:');
define('ADD_EDIT_NOTIFICATION_NAME', 'Benachrichtigungsname:');
define('ADD_EDIT_TIMEZONE', 'Zeitzone:');
define('ADD_EDIT_TIMEFRAME', 'Zeitplan:');
define('ADD_EDIT_OWNER', 'Besitzer:');
define('ADD_EDIT_NOTIFY_USERS', 'Zu benachrichtigende Personen:');
define('ADD_EDIT_NOTIFY_GROUPS', 'Zu benachrichtigende Gruppen:');
define('ADD_EDIT_NOTIFY_BY', 'Nachrich per:');
define('ADD_EDIT_NOTIFY_ON', 'Nachricht bei:');
define('ADD_EDIT_SUBMIT', 'Speichern');
define('ADD_EDIT_BUTTON_ADD_ESCALATION', 'Eskalation hinzuf&uuml;gen');
define('ADD_EDIT_CONFIRM_ADD_ESCALATION', 'Alle ungesicherten Daten gehen verloren! Sicher?');
define('ADD_EDIT_BUTTON_REMOVE_ESCALATION', 'Eskalation entfernen');
define('ADD_EDIT_CONFIRM_REMOVE_ESCALATION', 'Diese Eskalation wirklich entfernen?');
define('ADD_EDIT_NOTIFY_AFTER_TRIES', 'Benachrichtigung nach:');
define('ADD_EDIT_LET_NOTIFIER_HANDLE', 'Eskalationsvorgehen an Notifier &uuml;bergeben:');
define('ADD_EDIT_RELOOP_DELAY', 'Verz&ouml;gerung (in s) zwischen Eskalationen:');
define('ADD_EDIT_ROLLOVER', 'Z&auml;hler zur&uuml;cksetzen bei &Uuml;berlauf:');
define('ADD_EDIT_NUM_NOTIFICATIONS', '(Anzahl)');
define('ADD_EDIT_ESCALATION_DELETED', 'Eskalation wurde gel&ouml;scht.');
define('ADD_EDIT_ESCALATION_ERROR', 'Fehler w&auml;hrend der Operation!');
define('ADD_EDIT_NOTIFICATION_ADD_UPDATE_ERROR', 'Fehler w&auml;hrend der Operation!');
define('ADD_EDIT_NOTIFICATION_UPDATED', 'Benachrichtigung aktualisiert.');
define('ADD_EDIT_PREVIEW_NO_RESULTS', 'Nichts gefunden.');
define('ADD_EDIT_HEADING_NOTIFICATION_NAME', 'Benachrichtigungsinformationen');
define('ADD_EDIT_NOTIFICATION_DESC', 'Beschreibung (optional)');

// login
define('LOGIN_HEADING', 'Bitte melden Sie sich an:');
define('LOGIN_USERNAME', 'Benutzername:');
define('LOGIN_PASSWORD', 'Passwort:');
define('LOGIN_SUBMIT', 'Anmelden');
define('LOGIN_FAIL', 'Anmeldung fehlgeschlagen!');
define('LOGIN_LOGOUT', 'Sie wurden abgemeldet.');


// contact manager
define('CONTACTS_OVERVIEW_LINK', '&Uuml;bersicht');
define('CONTACTS_ADD_EDIT_USER', 'Benutzer hinzuf&uuml;gen und &auml;ndern');
define('CONTACTS_EDIT_USER', 'Benutzer &auml;ndern');
define('CONTACTS_SELECT_USER_NEW', 'Neu erstellen');
define('CONTACTS_HEADING_NAME' , 'Name:');
define('CONTACTS_HEADING_CONTACT' , 'Kontakt:');
define('CONTACTS_HEADING_TIME' , 'Zeitangaben:');
define('CONTACTS_HEADING_ADMIN' , 'Administratorenfunktionen:');
define('CONTACTS_HEADING_HOLIDAYS' , 'Urlaub:');
define('CONTACTS_HEADING_MEMBERSHIPS' , 'Mitglieder:');
define('CONTACTS_HEADING_NOTIFICATION_MEMBERSHIPS' , 'Benachrichtigungen (direkte Mitgliedschaft):');
define('CONTACTS_HEADING_CONTACTGROUP_MEMBERSHIPS' , 'Kontaktgruppen:');
define('CONTACTS_HEADING_NOTIFICATION_TO_CONTACTGROUP_MEMBERSHIPS', 'Benachrichtigungen (vererbt):');
define('CONTACTS_HEADING_ESCALATION_MEMBERSHIPS' , 'Eskalationen (direkte Mitgliedschaft):');
define('CONTACTS_HEADING_ESCALATION_TO_CONTACTGROUP_MEMBERSHIPS', 'Eskalationen (vererbt):');

define('CONTACTS_NEW_USERNAME', 'Benutzer neu anlegen (Benutzername):');
define('CONTACTS_FULL_NAME', 'Ganzer Name:');
define('CONTACTS_USERNAME', 'Login:');
define('CONTACTS_PASSWORD', 'Passwort:');
define('CONTACTS_PASSWORD_VERIFY', 'Passwort wiederholen:');
define('CONTACTS_EMAIL', 'E-Mail:');
define('CONTACTS_PHONE', 'Telefon:');
define('CONTACTS_MOBILE', 'Mobiltelefon:');
define('CONTACTS_GROWLADDRESS', 'Growl-Addresse:');
define('CONTACTS_GROWLREGISTER', 'Bei Growl anmelden (Benachrichtigungstest):');
define('CONTACTS_RESTRICT_ALERTS', 'Mehrfachbenachrichtigungen verhindern:');
define('CONTACTS_TIMEFRAME', 'Arbeitszeit:');
define('CONTACTS_TIMEZONE', 'Zeitzone:');
define('CONTACTS_USER', 'Zu &auml;ndernder Benutzer:');
define('CONTACTS_ADMIN', 'Administrator:');
define('CONTACTS_EDIT_BUTTON', 'Benutzer ausw&auml;hlen');
define('CONTACTS_DEL_BUTTON', 'Benutzer l&ouml;schen');
define('CONTACTS_SUBMIT_ADD', 'Benutzer hinzuf&uuml;gen');
define('CONTACTS_SUBMIT_UPDATE', 'Benutzer aktualisieren');
define('CONTACTS_CONFIRM_DEL', 'M&ouml;chten Sie diesen Benutzer wirklich l&ouml;schen?');
define('CONTACTS_HOLIDAYS_DELETE', 'L&ouml;schen');
define('CONTACTS_HOLIDAY_ADD_NEW', 'Neuen Urlaub anlegen:');
define('CONTACTS_HOLIDAY_DESC_NAME','Urlaubsname hinzuf&uuml;gen: ');
define('CONTACTS_HOLIDAY_DESC_START','Urlaubsanfang: ');
define('CONTACTS_HOLIDAY_DESC_END','Urlaubsende: ');
define('CONTACTS_HOLIDAY_DESC_SHORT_START','Beginnt: ');
define('CONTACTS_HOLIDAY_DESC_SHORT_END','Endet: ');
define('CONTACTS_TITLE_GROUP_NAME_SHORT','Kontaktgruppe K&uuml;rzel');
define('CONTACTS_TITLE_GROUP_NAME','Kontaktgruppenname ');
define('CONTACTS_TITLE_GROUP_VIEW_ONLY','Nur Gruppenansicht ');
define('CONTACTS_TITLE_TIMEFRAME_NAME','Zeitplan: ');
define('CONTACTS_TITLE_NOTIFICATION_NAME','Benachrichtigungen');
define('CONTACTS_TITLE_NOTIFICATION_ACTIVE', 'Aktive Regel');
define('CONTACTS_TITLE_NOTIFICATION_NOTIFY_AFTER_TRIES', 'Benachrichtigen nach x Versuchen');
define('CONTACTS_TITLE_ESCALATION_NOTIFY_AFTER_TRIES', 'Benachrichtigen nach x Versuchen');
define('CONTACTS_UPDATED', 'Benutzer aktualisiert.');
define('CONTACTS_ADDED', 'Benutzer hinzugef&uuml;gt.');
define('CONTACTS_DELETED', 'Benutzer gel&ouml;scht.');
define('CONTACTS_ADD_UPDATE_DEL_ERROR', 'Fehler w&auml;hrend der Operation!');
define('CONTACTS_ADD_UPDATE_ERROR_PASSWD_MISMATCH', 'Die eingegebenen Passw&ouml;rter stimmen nicht &uuml;berein!');
define('CONTACTS_ADD_UPDATE_ERROR_INSUFF_RIGHTS', 'Sie besitzen keine ausreichenden Rechte f&uuml;r diese &Auml;nderungen!');
define('CONTACTS_ADD_USER_EXISTS', 'Benutzer existiert bereits!');
define('CONTACTS_ADD_UPDATE_PASSWD_MISSING', 'Kein Passwort gesetzt!');
define('CONTACTS_ADD_ADDED_BUT_NOT_IN_DB', 'Benutzer wurde angelegt, aber Datenbank wurde noch nicht aktualisiert.');

// timeframe manager
define('TIMEFRAME_OVERVIEW_LINK', '&Uuml;bersicht');
define('TIMEFRAME_HEADING', 'Zeitplan verwalten');
define('TIMEFRAME_HEADING_SELECT', 'Zeitplan w&auml;hlen:');
define('TIMEFRAME_HEADING_ADD', 'Zeitplan hinzuf&uuml;gen:');
define('TIMEFRAME_HEADING_NAME' , 'Zeitplan');
define('TIMEFRAME_HEADING_EDIT', 'Zeitplan &auml;ndern:');
define('TIMEFRAME_HEADING_HOLIDAYS' , 'Urlaub:');
define('TIMEFRAME_HEADING_MEMBERSHIPS' , 'Mitglieder:');
define('TIMEFRAME_HEADING_NOTIFICATION_MEMBERSHIPS' , 'Benachrichtigungen:');
define('TIMEFRAME_HEADING_CONTACTGROUP_MEMBERSHIPS' , 'Kontaktgruppen:');
define('TIMEFRAME_HEADING_CONTACT_MEMBERSHIPS' , 'Kontakte:');

define('TIMEFRAME_TITLE_GROUP_NAME_SHORT','Kontaktgruppe (K&uuml;rzel)');
define('TIMEFRAME_TITLE_GROUP_NAME','Kontaktgruppenname ');
define('TIMEFRAME_TITLE_GROUP_VIEW_ONLY','Nur Gruppenansicht ');
define('TIMEFRAME_TITLE_NOTIFICATION_NAME','Benachrichtigung ');
define('TIMEFRAME_TITLE_NOTIFICATION_ACTIVE', 'Aktive Regeln ');
define('TIMEFRAME_TITLE_CONTACT_USERNAME', 'Benutzername');
define('TIMEFRAME_TITLE_CONTACT_FULL_NAME', 'Name');
define('TIMEFRAME_TITLE_SUPPRESS_MULTIPLE', 'Mehrfachalarme vermeiden');
define('TIMEFRAME_TITLE_TIMEZONE','Zeitzone');
define('TIMEFRAME_SELECT_FRAME_NEW', 'Neu erstellen');
define('TIMEFRAME_EDIT_FRAMES', 'Zeitplan &auml;ndern:');
define('TIMEFRAME_EDIT_USERS', 'Benutzer:');
define('TIMEFRAME_EDIT_BUTTON', 'Zeitplan &auml;ndern');
define('TIMEFRAME_ADD_BUTTON', 'Zeitplan hinzuf&uuml;gen');
define('TIMEFRAME_DELETE_BUTTON', 'Zeitplan l&ouml;schen');
define('TIMEFRAME_ADD_FRAME', 'Neuer Zeitplan:');
define('TIMEFRAME_SUBMIT_CHANGES_BUTTON', '&Auml;nderungen &uuml;bernehmen');
define('TIMEFRAME_FRAME_ADDED', 'Neuen Zeitplan erfolgreich erstellt');
define('TIMEFRAME_ADDING_FAILED', 'Konnte neuen Zeitplan nicht erstellen');
define('TIMEFRAME_FRAME_UPDATE', 'Zeitplan aktualisiert!');
define('TIMEFRAME_UPDATE_FAILED', 'Konnte Zeitplan nicht aktualisieren!');
define('TIMEFRAME_FRAME_DELETED', 'Zeitplan gel&ouml;scht!');
define('TIMEFRAME_DELETE_FAILED', 'Konnte Zeitplan nicht l&ouml;schen;');
define('TIMEFRAME_EDIT_NAME_SHORT', 'Name (k&uuml;rzel):');
define('TIMEFRAME_EDIT_NAME', 'Name:');
define('TIMEFRAME_CONFIRM_DEL', 'Zeitplan wirklich l&ouml;schen?');
define('TIMEFRAME_TIMEFRAME', 'Benachrichtigungszeiten:');

define('TIMEFRAME_HEADING_ADMIN' , 'Admin-Funktionen:');
define('TIMEFRAME_ADD_EDIT_FRAME', 'Zeitplan hinzuf&uuml;gen und &auml;ndern');
define('TIMEFRAME_DEL_BUTTON', 'Zeitplan l&ouml;schen');
define('TIMEFRAME_SUBMIT_ADD', 'Zeitplan anlegen');
define('TIMEFRAME_SUBMIT_UPDATE', 'Zeitplan aktualisieren'); 
define('TIMEFRAME_HOLIDAYS_DELETE', 'L&ouml;schen');
define('TIMEFRAME_HOLIDAY_ADD_NEW', 'Urlaub hinzuf&uuml;gen:');
define('TIMEFRAME_HOLIDAY_DESC_NAME','Urlaub hinzuf&uuml;gen:');
define('TIMEFRAME_HOLIDAY_DESC_START','Urlaubsbeginn: ');
define('TIMEFRAME_HOLIDAY_DESC_END','Urlaubsende: ');
define('TIMEFRAME_HOLIDAY_DESC_SHORT_START','Beginnt: ');
define('TIMEFRAME_HOLIDAY_DESC_SHORT_END','Endet: ');
define('TIMEFRAME_ADMIN', 'Administrator:');
define('TIMEFRAME_FRAMES', 'Zeitpl&auml;ne:');
define('TIMEFRAME_FRAME_VALID_FROM', 'G&uuml;ltig von:');
define('TIMEFRAME_FRAME_VALID_TO', 'G&uuml;ltig bis:');
define('TIMEFRAME_FRAME' , 'Zeitplan:');
					      
define('TIMEFRAME_TIME_FROM', 'Von (hh:mm:ss)');
define('TIMEFRAME_TIME_TO', 'Bis (hh:mm:ss)');
define('TIMEFRAME_TIME_INVERT', 'Zeit umkehren');
define('TIMEFRAME_DAYS_ALL', 'Alle');
define('TIMEFRAME_DAYS_1ST', '1.');
define('TIMEFRAME_DAYS_2ND', '2.');
define('TIMEFRAME_DAYS_3RD', '3.');
define('TIMEFRAME_DAYS_4TH', '4.');
define('TIMEFRAME_DAYS_5TH', '5.');
define('TIMEFRAME_DAYS_LAST', 'Letzter');
define('TIMEFRAME_DAYS_OF_WEEK', 'Wochentag');
define('TIMEFRAME_DAY_MONDAY', 'Mo');
define('TIMEFRAME_DAY_TUESDAY', 'Di');
define('TIMEFRAME_DAY_WEDNESDAY', 'Mi');
define('TIMEFRAME_DAY_THURSDAY', 'Do');
define('TIMEFRAME_DAY_FRIDAY', 'Fr');
define('TIMEFRAME_DAY_SATURDAY', 'Sa');
define('TIMEFRAME_DAY_SUNDAY', 'So');

// log viewer
define('LOG_VIEWER_OVERVIEW_LINK', '&Uuml;bersicht');
define('LOG_VIEWER_HEADING', 'Nachrichtenverlauf');
define('LOG_VIEWER_FIND', 'Suche:');
define('LOG_VIEWER_NUM_RESULTS', 'Resultate pro Seite:');
define('LOG_VIEWER_HEADING_NOTIFICATION_RULE', 'Regel');
define('LOG_VIEWER_HEADING_TIMESTAMP', 'Zeit');
define('LOG_VIEWER_HEADING_CHECK_TYPE', 'Art des Checks');
define('LOG_VIEWER_HEADING_HOSTGROUP', 'Hostgruppe');
define('LOG_VIEWER_HEADING_HOST', 'Host');
define('LOG_VIEWER_HEADING_SERVICE', 'Service');
define('LOG_VIEWER_HEADING_SERVICEGROUP', 'Servicegruppe');
define('LOG_VIEWER_HEADING_CHECK_RESULT', 'Status pr&uuml;fen');
define('LOG_VIEWER_HEADING_METHOD', 'Benachrichtigungsmethode');
define('LOG_VIEWER_HEADING_USER', 'Empf&auml;nger');
define('LOG_VIEWER_HEADING_RESULT', 'Benachrichtigungsresultat');
define('LOG_VIEWER_FIND_SUBMIT', 'Abschicken');


// Kontaktgruppen verwalten
define('CONTACTGROUPS_OVERVIEW_LINK', '&Uuml;bersicht');
define('CONTACTGROUPS_HEADING', 'Kontaktgruppen verwalten');
define('CONTACTGROUPS_HEADING_SELECT', 'Kontaktgruppe ausw&auml;hlen:');
define('CONTACTGROUPS_HEADING_ADD', 'Kontaktgruppe hinzuf&uuml;gen:');
define('CONTACTGROUPS_HEADING_MEMBERSHIPS' , 'Zugeh&ouml;rigkeit:');
define('CONTACTGROUPS_HEADING_NOTIFICATION_MEMBERSHIPS' , 'Benachrichtigung (direkte Zugeh&ouml;rigkeit):');
define('CONTACTGROUPS_HEADING_ESCALATION_MEMBERSHIPS' , 'Eskalationen (direct Zugeh&ouml;rigkeit):');
define('CONTACTGROUPS_SELECT_GROUP_NEW', 'Neu erstellen');
define('CONTACTGROUPS_EDIT_GROUPS', 'Kontaktgruppe:');
define('CONTACTGROUPS_EDIT_USERS', 'Kontakt(e):');
define('CONTACTGROUPS_EDIT_BUTTON', 'Bearbeiten');
define('CONTACTGROUPS_ADD_BUTTON', 'Hinzuf&uuml;gen');
define('CONTACTGROUPS_DELETE_BUTTON', 'L&ouml;schen');
define('CONTACTGROUPS_ADD_NAME_SHORT', 'Neue Gruppe (K&uuml;rzel):');
define('CONTACTGROUPS_ADD_NAME', 'Neue Gruppe:');
define('CONTACTGROUPS_SUBMIT_CHANGES_BUTTON', '&Auml;nderungen &uuml;bernehmen');
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
define('CONTACTGROUPS_TIMEFRAME', 'Benachrichtigungszeiten:');
define('CONTACTGROUPS_TIMEZONE', 'Gruppen-Zeitzone:');
define('CONTACTGROUPS_TITLE_NOTIFICATION_NAME','Benachrichtigung');
define('CONTACTGROUPS_TITLE_NOTIFICATION_ACTIVE', 'Aktive Regel');
define('CONTACTGROUPS_TITLE_NOTIFICATION_NOTIFY_AFTER_TRIES', 'Nach x Versuchen benachrichtigen');
define('CONTACTGROUPS_TITLE_ESCALATION_NOTIFY_AFTER_TRIES', 'Nach x Versuchen benachrichtigen');
define('CONTACTGROUPS_TITLE_TIMEFRAME_NAME', 'Name des Zeitplans');

?>
