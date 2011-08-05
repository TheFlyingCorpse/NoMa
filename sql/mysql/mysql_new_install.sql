SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

CREATE TABLE `contactgroups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name_short` varchar(255) CHARACTER SET latin1 NOT NULL,
  `name` varchar(255) CHARACTER SET latin1 NOT NULL,
  `view_only` tinyint(1) NOT NULL DEFAULT '0',
  `timezone_id` int(11) NOT NULL DEFAULT '0',
  `timeframe_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `name_short` (`name_short`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;

INSERT INTO `contactgroups` VALUES(1, 'group1', 'Group 1', 0, 1);

CREATE TABLE `contactgroups_to_contacts` (
  `contactgroup_id` int(11) NOT NULL,
  `contact_id` int(11) NOT NULL,
  KEY `contactgroup_id` (`contactgroup_id`),
  KEY `contact_id` (`contact_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `contactgroups_to_contacts` VALUES(1, 2);

CREATE TABLE `contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin` tinyint(1) NOT NULL,
  `username` varchar(255) CHARACTER SET latin1 NOT NULL,
  `full_name` varchar(255) CHARACTER SET latin1 NOT NULL,
  `email` varchar(255) CHARACTER SET latin1 NOT NULL,
  `phone` varchar(255) CHARACTER SET latin1 NOT NULL,
  `mobile` varchar(255) CHARACTER SET latin1 NOT NULL,
  `section` varchar(255) NOT NULL,
  `netaddress` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `timeframe_id` int(11) NOT NULL DEFAULT '0',
  `timezone_id` int(11) NOT NULL,
  `restrict_alerts` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;

INSERT INTO `contacts` VALUES(1, 0, '[---]', '', '', '', '', '', '', '', 0, 0, NULL);
INSERT INTO `contacts` VALUES(2, 1, 'nagiosadmin', 'Nagios Administrator', 'root@localhost', '', '', '', '192.168.1.109', '9e2b1592bd13bea759dab1e3011cab7ef47930cd', 1, 305, 1);

CREATE TABLE `escalations_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `notification_id` int(11) NOT NULL,
  `on_ok` tinyint(1) NOT NULL,
  `on_warning` tinyint(1) NOT NULL,
  `on_critical` tinyint(1) NOT NULL,
  `on_unknown` tinyint(1) NOT NULL,
  `on_host_up` tinyint(1) NOT NULL,
  `on_host_unreachable` tinyint(1) NOT NULL,
  `on_host_down` tinyint(1) NOT NULL,
  `on_type_problem` tinyint(1) NOT NULL,
  `on_type_recovery` tinyint(1) NOT NULL,
  `on_type_flappingstart` tinyint(1) NOT NULL,
  `on_type_flappingstop` tinyint(1) NOT NULL,
  `on_type_flappingdisabled` tinyint(1) NOT NULL,
  `on_type_downtimestart` tinyint(1) NOT NULL,
  `on_type_downtimeend` tinyint(1) NOT NULL,
  `on_type_downtimecancelled` tinyint(1) NOT NULL,
  `on_type_acknowledgement` tinyint(1) NOT NULL,
  `on_type_custom` tinyint(1) NOT NULL,
  `notify_after_tries` varchar(255) CHARACTER SET latin1 NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `notification_id` (`notification_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;

CREATE TABLE `escalations_contacts_to_contactgroups` (
  `escalation_contacts_id` int(11) NOT NULL,
  `contactgroup_id` int(11) NOT NULL,
  KEY `contactgroup_id` (`contactgroup_id`),
  KEY `escalation_contacts_id` (`escalation_contacts_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `escalations_contacts_to_contacts` (
  `escalation_contacts_id` int(11) NOT NULL,
  `contacts_id` int(11) NOT NULL,
  KEY `escalation_contacts_id` (`escalation_contacts_id`),
  KEY `contacts_id` (`contacts_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `escalations_contacts_to_methods` (
  `escalation_contacts_id` int(11) NOT NULL,
  `method_id` int(11) NOT NULL,
  KEY `escalation_contacts_id` (`escalation_contacts_id`),
  KEY `method_id` (`method_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `escalation_stati` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `notification_rule` int(11) DEFAULT NULL,
  `starttime` int(11) NOT NULL,
  `counter` int(11) NOT NULL,
  `incident_id` bigint(20) NOT NULL,
  `recipients` varchar(255) NOT NULL,
  `host` varchar(255) CHARACTER SET latin1 NOT NULL,
  `host_alias` varchar(255) DEFAULT NULL,
  `host_address` varchar(255) DEFAULT NULL,
  `hostgroups` varchar(255) NOT NULL,
  `service` varchar(255) CHARACTER SET latin1 NOT NULL,
  `servicegroups` varchar(255) NOT NULL,
  `check_type` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `time_string` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `output` varchar(4096) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `incident_id` (`incident_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;

CREATE TABLE `holidays` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contact_id` int(11) NOT NULL,
  `start` datetime NOT NULL,
  `end` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `active` tinyint(1) NOT NULL,
  `username` varchar(255) CHARACTER SET latin1 NOT NULL,
  `recipients_include` varchar(255) NOT NULL,
  `recipients_exclude` varchar(255) NOT NULL,
  `hosts_include` varchar(255) CHARACTER SET latin1 NOT NULL,
  `hosts_exclude` varchar(255) CHARACTER SET latin1 NOT NULL,
  `hostgroups_include` varchar(255) CHARACTER SET latin1 NOT NULL,
  `hostgroups_exclude` varchar(255) CHARACTER SET latin1 NOT NULL,
  `services_include` varchar(255) CHARACTER SET latin1 NOT NULL,
  `services_exclude` varchar(255) CHARACTER SET latin1 NOT NULL,
  `servicegroups_include` varchar(255) CHARACTER SET latin1 NOT NULL,
  `servicegroups_exclude` varchar(255) CHARACTER SET latin1 NOT NULL,
  `notify_after_tries` varchar(10) CHARACTER SET latin1 NOT NULL DEFAULT '0',
  `let_notifier_handle` tinyint(1) NOT NULL,
  `rollover` tinyint(1) DEFAULT '0',
  `reloop_delay` int(11) NOT NULL DEFAULT '0',
  `on_ok` tinyint(1) NOT NULL,
  `on_warning` tinyint(1) NOT NULL,
  `on_unknown` tinyint(1) NOT NULL,
  `on_host_unreachable` tinyint(1) NOT NULL,
  `on_critical` tinyint(1) NOT NULL,
  `on_host_up` tinyint(1) NOT NULL,
  `on_host_down` tinyint(1) NOT NULL,
  `on_type_problem` tinyint(1) NOT NULL,
  `on_type_recovery` tinyint(1) NOT NULL,
  `on_type_flappingstart` tinyint(1) NOT NULL,
  `on_type_flappingstop` tinyint(1) NOT NULL,
  `on_type_flappingdisabled` tinyint(1) NOT NULL,
  `on_type_downtimestart` tinyint(1) NOT NULL,
  `on_type_downtimeend` tinyint(1) NOT NULL,
  `on_type_downtimecancelled` tinyint(1) NOT NULL,
  `on_type_acknowledgement` tinyint(1) NOT NULL,
  `on_type_custom` tinyint(1) NOT NULL,
  `timezone_id` int(11) NOT NULL DEFAULT '372',
  `timeframe_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;

INSERT INTO `notifications` VALUES(1, 1, 'nagiosadmin', '', '', '*', '', '*', '', '*', '', '*', '', '1', 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 234, 1);

CREATE TABLE `notifications_to_contactgroups` (
  `notification_id` int(11) NOT NULL,
  `contactgroup_id` int(11) NOT NULL,
  KEY `notification_id` (`notification_id`),
  KEY `contactgroup_id` (`contactgroup_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `notifications_to_contacts` (
  `notification_id` int(11) NOT NULL,
  `contact_id` int(11) NOT NULL,
  KEY `notification_id` (`notification_id`),
  KEY `contact_id` (`contact_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `notifications_to_contacts` VALUES(1, 2);

CREATE TABLE `notifications_to_methods` (
  `notification_id` int(11) NOT NULL,
  `method_id` int(11) NOT NULL,
  KEY `notification_id` (`notification_id`),
  KEY `method_id` (`method_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `notifications_to_methods` VALUES(1, 1);
INSERT INTO `notifications_to_methods` VALUES(1, 6);

CREATE TABLE `notification_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timestamp` datetime NOT NULL,
  `counter` int(11) NOT NULL,
  `check_type` varchar(10) CHARACTER SET latin1 NOT NULL,
  `check_result` varchar(15) CHARACTER SET latin1 NOT NULL,
  `host` varchar(255) CHARACTER SET latin1 NOT NULL,
  `service` varchar(255) CHARACTER SET latin1 NOT NULL,
  `notification_type` varchar(255) CHARACTER SET latin1 NOT NULL,
  `method` varchar(255) NOT NULL,
  `user` varchar(255) CHARACTER SET latin1 NOT NULL,
  `result` varchar(1023) NOT NULL,
  `unique_id` bigint(20) DEFAULT NULL,
  `incident_id` bigint(20) DEFAULT NULL,
  `notification_rule` int(11) DEFAULT NULL,
  `last_method` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `unique_id` (`unique_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;

INSERT INTO `notification_logs` VALUES(1, '2011-08-03 22:19:45', 1, 'Service', 'CRITICAL', 'loaaalh3', '', '', 'Growl', 'nagiosadmin', 'processing notification, single alert successful', 131240278599445, 131240278589190, 1, 6);
INSERT INTO `notification_logs` VALUES(2, '2011-08-03 22:19:45', 1, 'Service', 'CRITICAL', 'loaaalh3', '', '', 'E-Mail', 'nagiosadmin', 'processing notification, single alert successful', 131240278531579, 131240278589190, 1, 1);

CREATE TABLE `notification_methods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `method` varchar(255) NOT NULL,
  `command` varchar(255) NOT NULL,
  `contact_field` varchar(255) NOT NULL,
  `from` varchar(255) NOT NULL,
  `on_fail` int(11) NOT NULL,
  `ack_able` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1;

INSERT INTO `notification_methods` VALUES(5, 'Voice + SMS fallback', 'voicecall', 'phone', '', 2, 1);
INSERT INTO `notification_methods` VALUES(6, 'Growl', 'growl', 'netaddress', '', 0, 0);
INSERT INTO `notification_methods` VALUES(4, 'Voice + E-Mail fallback', 'voicecall', 'phone', '', 1, 1);
INSERT INTO `notification_methods` VALUES(3, 'Voice', 'voicecall', 'phone', '', 0, 1);
INSERT INTO `notification_methods` VALUES(2, 'SMS', 'sendsms', 'mobile', '', 0, 0);
INSERT INTO `notification_methods` VALUES(1, 'E-Mail', 'sendemail', 'email', 'noma@netways.de', 0, 0);
INSERT INTO `notification_methods` VALUES(7, 'Growl + E-Mail fallback', 'growl', 'netaddress', '', 1, 1);
INSERT INTO `notification_methods` VALUES(8, 'Growl + SMS fallback', 'growl', 'netaddress', '', 2, 1);

CREATE TABLE `notification_stati` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host` varchar(255) CHARACTER SET latin1 NOT NULL,
  `service` varchar(255) CHARACTER SET latin1 NOT NULL,
  `check_type` varchar(10) CHARACTER SET latin1 NOT NULL,
  `check_result` varchar(15) CHARACTER SET latin1 NOT NULL,
  `counter` int(11) NOT NULL,
  `pid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;

CREATE TABLE `timeframes` (
  `id` int(11) NOT NULL,
  `timeframe_name` varchar(60) COLLATE utf8_unicode_ci NOT NULL,
  `dt_validFrom` datetime NOT NULL,
  `dt_validTo` datetime NOT NULL,
  `day_monday_all` tinyint(1) DEFAULT '1',
  `day_monday_1st` tinyint(1) DEFAULT '0',
  `day_monday_2nd` tinyint(1) DEFAULT '0',
  `day_monday_3rd` tinyint(1) DEFAULT '0',
  `day_monday_4th` tinyint(1) DEFAULT '0',
  `day_monday_5th` tinyint(1) DEFAULT '0',
  `day_monday_last` tinyint(1) DEFAULT '0',
  `day_tuesday_all` tinyint(1) DEFAULT '1',
  `day_tuesday_1st` tinyint(1) DEFAULT '0',
  `day_tuesday_2nd` tinyint(1) DEFAULT '0',
  `day_tuesday_3rd` tinyint(1) DEFAULT '0',
  `day_tuesday_4th` tinyint(1) DEFAULT '0',
  `day_tuesday_5th` tinyint(1) DEFAULT '0',
  `day_tuesday_last` tinyint(1) DEFAULT '0',
  `day_wednesday_all` tinyint(1) DEFAULT '1',
  `day_wednesday_1st` tinyint(1) DEFAULT '0',
  `day_wednesday_2nd` tinyint(1) DEFAULT '0',
  `day_wednesday_3rd` tinyint(1) DEFAULT '0',
  `day_wednesday_4th` tinyint(1) DEFAULT '0',
  `day_wednesday_5th` tinyint(1) DEFAULT '0',
  `day_wednesday_last` tinyint(1) DEFAULT '0',
  `day_thursday_all` tinyint(1) DEFAULT '1',
  `day_thursday_1st` tinyint(1) DEFAULT '0',
  `day_thursday_2nd` tinyint(1) DEFAULT '0',
  `day_thursday_3rd` tinyint(1) DEFAULT '0',
  `day_thursday_4th` tinyint(1) DEFAULT '0',
  `day_thursday_5th` tinyint(1) DEFAULT '0',
  `day_thursday_last` tinyint(1) DEFAULT '0',
  `day_friday_all` tinyint(1) DEFAULT '1',
  `day_friday_1st` tinyint(1) DEFAULT '0',
  `day_friday_2nd` tinyint(1) DEFAULT '0',
  `day_friday_3rd` tinyint(1) DEFAULT '0',
  `day_friday_4th` tinyint(1) DEFAULT '0',
  `day_friday_5th` tinyint(1) DEFAULT '0',
  `day_friday_last` tinyint(1) DEFAULT '0',
  `day_saturday_all` tinyint(1) DEFAULT '1',
  `day_saturday_1st` tinyint(1) DEFAULT '0',
  `day_saturday_2nd` tinyint(1) DEFAULT '0',
  `day_saturday_3rd` tinyint(1) DEFAULT '0',
  `day_saturday_4th` tinyint(1) DEFAULT '0',
  `day_saturday_5th` tinyint(1) DEFAULT '0',
  `day_saturday_last` tinyint(1) DEFAULT '0',
  `day_sunday_all` tinyint(1) DEFAULT '1',
  `day_sunday_1st` tinyint(1) DEFAULT '0',
  `day_sunday_2nd` tinyint(1) DEFAULT '0',
  `day_sunday_3rd` tinyint(1) DEFAULT '0',
  `day_sunday_4th` tinyint(1) DEFAULT '0',
  `day_sunday_5th` tinyint(1) DEFAULT '0',
  `day_sunday_last` tinyint(1) DEFAULT '0',
  `time_monday_start` time DEFAULT NULL,
  `time_monday_stop` time DEFAULT NULL,
  `time_monday_invert` tinyint(1) DEFAULT '0',
  `time_tuesday_start` time DEFAULT NULL,
  `time_tuesday_stop` time DEFAULT NULL,
  `time_tuesday_invert` tinyint(1) DEFAULT '0',
  `time_wednesday_start` time DEFAULT NULL,
  `time_wednesday_stop` time DEFAULT NULL,
  `time_wednesday_invert` tinyint(1) DEFAULT '0',
  `time_thursday_start` time DEFAULT NULL,
  `time_thursday_stop` time DEFAULT NULL,
  `time_thursday_invert` tinyint(1) DEFAULT '0',
  `time_friday_start` time DEFAULT NULL,
  `time_friday_stop` time DEFAULT NULL,
  `time_friday_invert` tinyint(1) DEFAULT '0',
  `time_saturday_start` time DEFAULT NULL,
  `time_saturday_stop` time DEFAULT NULL,
  `time_saturday_invert` tinyint(1) DEFAULT '0',
  `time_sunday_start` time DEFAULT NULL,
  `time_sunday_stop` time DEFAULT NULL,
  `time_sunday_invert` tinyint(1) DEFAULT '0',
  KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `timeframes` VALUES(1, '24x7', '0000-00-00 00:00:00', '2011-08-31 00:00:00', 290, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, '00:00:00', '00:00:00', 1, '00:00:00', '00:00:00', 1, '00:00:00', '00:00:00', 1, '00:00:00', '00:00:00', 1, '00:00:00', '00:00:00', 1, '00:00:00', '00:00:00', 1, '00:00:00', '00:00:00', 1);
INSERT INTO `timeframes` VALUES(0, '[---]', '2001-01-01 00:00:00', '2001-01-01 00:00:00', 305, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '00:00:00', '00:00:00', 0, '00:00:00', '00:00:00', 0, '00:00:00', '00:00:00', 0, '00:00:00', '00:00:00', 0, '00:00:00', '00:00:00', 0, '00:00:00', '00:00:00', 0, '00:00:00', '00:00:00', 0);
INSERT INTO `timeframes` VALUES(2, 'workhours', '2011-08-01 00:00:00', '2021-08-31 00:00:00', 208, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '08:00:00', '16:00:00', 0, '08:00:00', '16:00:00', 0, '08:00:00', '16:00:00', 0, '08:00:00', '16:00:00', 0, '08:00:00', '16:00:00', 0, '00:00:00', '00:00:00', 0, '00:00:00', '00:00:00', 0);

CREATE TABLE `timezones` (
  `id` int(11) NOT NULL,
  `timezone` varchar(255) CHARACTER SET latin1 NOT NULL,
  `time_diff` tinyint(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `timezones` VALUES(1, 'Africa/Abidjan', 0);
INSERT INTO `timezones` VALUES(2, 'Africa/Accra', 0);
INSERT INTO `timezones` VALUES(3, 'Africa/Addis_Ababa', 3);
INSERT INTO `timezones` VALUES(4, 'Africa/Algiers', 1);
INSERT INTO `timezones` VALUES(5, 'Africa/Asmera', 3);
INSERT INTO `timezones` VALUES(6, 'Africa/Bamako', 0);
INSERT INTO `timezones` VALUES(7, 'Africa/Bangui', 1);
INSERT INTO `timezones` VALUES(8, 'Africa/Banjul', 0);
INSERT INTO `timezones` VALUES(9, 'Africa/Bissau', 0);
INSERT INTO `timezones` VALUES(10, 'Africa/Blantyre', 2);
INSERT INTO `timezones` VALUES(11, 'Africa/Brazzaville', 1);
INSERT INTO `timezones` VALUES(12, 'Africa/Bujumbura', 2);
INSERT INTO `timezones` VALUES(13, 'Africa/Cairo', 2);
INSERT INTO `timezones` VALUES(14, 'Africa/Casablanca', 0);
INSERT INTO `timezones` VALUES(15, 'Africa/Ceuta', 1);
INSERT INTO `timezones` VALUES(16, 'Africa/Conakry', 0);
INSERT INTO `timezones` VALUES(17, 'Africa/Dakar', 0);
INSERT INTO `timezones` VALUES(18, 'Africa/Dar_es_Salaam', 3);
INSERT INTO `timezones` VALUES(19, 'Africa/Djibouti', 3);
INSERT INTO `timezones` VALUES(20, 'Africa/Douala', 1);
INSERT INTO `timezones` VALUES(21, 'Africa/El_Aaiun', 0);
INSERT INTO `timezones` VALUES(22, 'Africa/Freetown', 0);
INSERT INTO `timezones` VALUES(23, 'Africa/Gaborone', 2);
INSERT INTO `timezones` VALUES(24, 'Africa/Harare', 2);
INSERT INTO `timezones` VALUES(25, 'Africa/Johannesburg', 2);
INSERT INTO `timezones` VALUES(26, 'Africa/Kampala', 3);
INSERT INTO `timezones` VALUES(27, 'Africa/Khartoum', 3);
INSERT INTO `timezones` VALUES(28, 'Africa/Kigali', 2);
INSERT INTO `timezones` VALUES(29, 'Africa/Kinshasa', 1);
INSERT INTO `timezones` VALUES(30, 'Africa/Lagos', 1);
INSERT INTO `timezones` VALUES(31, 'Africa/Libreville', 1);
INSERT INTO `timezones` VALUES(32, 'Africa/Lome', 0);
INSERT INTO `timezones` VALUES(33, 'Africa/Luanda', 1);
INSERT INTO `timezones` VALUES(34, 'Africa/Lubumbashi', 2);
INSERT INTO `timezones` VALUES(35, 'Africa/Lusaka', 2);
INSERT INTO `timezones` VALUES(36, 'Africa/Malabo', 1);
INSERT INTO `timezones` VALUES(37, 'Africa/Maputo', 2);
INSERT INTO `timezones` VALUES(38, 'Africa/Maseru', 2);
INSERT INTO `timezones` VALUES(39, 'Africa/Mbabane', 2);
INSERT INTO `timezones` VALUES(40, 'Africa/Mogadishu', 3);
INSERT INTO `timezones` VALUES(41, 'Africa/Monrovia', 0);
INSERT INTO `timezones` VALUES(42, 'Africa/Nairobi', 3);
INSERT INTO `timezones` VALUES(43, 'Africa/Ndjamena', 1);
INSERT INTO `timezones` VALUES(44, 'Africa/Niamey', 1);
INSERT INTO `timezones` VALUES(45, 'Africa/Nouakchott', 0);
INSERT INTO `timezones` VALUES(46, 'Africa/Ouagadougou', 0);
INSERT INTO `timezones` VALUES(47, 'Africa/Porto-Novo', 1);
INSERT INTO `timezones` VALUES(48, 'Africa/Sao_Tome', 0);
INSERT INTO `timezones` VALUES(49, 'Africa/Tripoli', 2);
INSERT INTO `timezones` VALUES(50, 'Africa/Tunis', 1);
INSERT INTO `timezones` VALUES(51, 'Africa/Windhoek', 2);
INSERT INTO `timezones` VALUES(52, 'America/Adak', -10);
INSERT INTO `timezones` VALUES(53, 'America/Anchorage', -9);
INSERT INTO `timezones` VALUES(54, 'America/Anguilla', -4);
INSERT INTO `timezones` VALUES(55, 'America/Antigua', -4);
INSERT INTO `timezones` VALUES(56, 'America/Araguaina', -3);
INSERT INTO `timezones` VALUES(57, 'America/Argentina/Buenos_Aires', -3);
INSERT INTO `timezones` VALUES(58, 'America/Argentina/Catamarca', -3);
INSERT INTO `timezones` VALUES(59, 'America/Argentina/Cordoba', -3);
INSERT INTO `timezones` VALUES(60, 'America/Argentina/Jujuy', -3);
INSERT INTO `timezones` VALUES(61, 'America/Argentina/La_Rioja', -3);
INSERT INTO `timezones` VALUES(62, 'America/Argentina/Mendoza', -3);
INSERT INTO `timezones` VALUES(63, 'America/Argentina/Rio_Gallegos', -3);
INSERT INTO `timezones` VALUES(64, 'America/Argentina/San_Juan', -3);
INSERT INTO `timezones` VALUES(65, 'America/Argentina/Tucuman', -3);
INSERT INTO `timezones` VALUES(66, 'America/Argentina/Ushuaia', -3);
INSERT INTO `timezones` VALUES(67, 'America/Aruba', -4);
INSERT INTO `timezones` VALUES(68, 'America/Asuncion', -3);
INSERT INTO `timezones` VALUES(69, 'America/Bahia', -3);
INSERT INTO `timezones` VALUES(70, 'America/Barbados', -4);
INSERT INTO `timezones` VALUES(71, 'America/Belem', -3);
INSERT INTO `timezones` VALUES(72, 'America/Belize', -6);
INSERT INTO `timezones` VALUES(73, 'America/Boa_Vista', -4);
INSERT INTO `timezones` VALUES(74, 'America/Bogota', -5);
INSERT INTO `timezones` VALUES(75, 'America/Boise', -7);
INSERT INTO `timezones` VALUES(76, 'America/Cambridge_Bay', -7);
INSERT INTO `timezones` VALUES(77, 'America/Campo_Grande', -3);
INSERT INTO `timezones` VALUES(78, 'America/Cancun', -6);
INSERT INTO `timezones` VALUES(79, 'America/Caracas', -4);
INSERT INTO `timezones` VALUES(80, 'America/Cayenne', -3);
INSERT INTO `timezones` VALUES(81, 'America/Cayman', -5);
INSERT INTO `timezones` VALUES(82, 'America/Chicago', -6);
INSERT INTO `timezones` VALUES(83, 'America/Chihuahua', -7);
INSERT INTO `timezones` VALUES(84, 'America/Coral_Harbour', -5);
INSERT INTO `timezones` VALUES(85, 'America/Costa_Rica', -6);
INSERT INTO `timezones` VALUES(86, 'America/Cuiaba', -3);
INSERT INTO `timezones` VALUES(87, 'America/Curacao', -4);
INSERT INTO `timezones` VALUES(88, 'America/Danmarkshavn', 0);
INSERT INTO `timezones` VALUES(89, 'America/Dawson', -8);
INSERT INTO `timezones` VALUES(90, 'America/Dawson_Creek', -7);
INSERT INTO `timezones` VALUES(91, 'America/Denver', -7);
INSERT INTO `timezones` VALUES(92, 'America/Detroit', -5);
INSERT INTO `timezones` VALUES(93, 'America/Dominica', -4);
INSERT INTO `timezones` VALUES(94, 'America/Edmonton', -7);
INSERT INTO `timezones` VALUES(95, 'America/Eirunepe', -5);
INSERT INTO `timezones` VALUES(96, 'America/El_Salvador', -6);
INSERT INTO `timezones` VALUES(97, 'America/Fortaleza', -3);
INSERT INTO `timezones` VALUES(98, 'America/Glace_Bay', -4);
INSERT INTO `timezones` VALUES(99, 'America/Godthab', -3);
INSERT INTO `timezones` VALUES(100, 'America/Goose_Bay', -4);
INSERT INTO `timezones` VALUES(101, 'America/Grand_Turk', -5);
INSERT INTO `timezones` VALUES(102, 'America/Grenada', -4);
INSERT INTO `timezones` VALUES(103, 'America/Guadeloupe', -4);
INSERT INTO `timezones` VALUES(104, 'America/Guatemala', -6);
INSERT INTO `timezones` VALUES(105, 'America/Guayaquil', -5);
INSERT INTO `timezones` VALUES(106, 'America/Guyana', -4);
INSERT INTO `timezones` VALUES(107, 'America/Halifax', -4);
INSERT INTO `timezones` VALUES(108, 'America/Havana', -5);
INSERT INTO `timezones` VALUES(109, 'America/Hermosillo', -7);
INSERT INTO `timezones` VALUES(110, 'America/Indiana/Indianapolis', -5);
INSERT INTO `timezones` VALUES(111, 'America/Indiana/Knox', -6);
INSERT INTO `timezones` VALUES(112, 'America/Indiana/Marengo', -5);
INSERT INTO `timezones` VALUES(113, 'America/Indiana/Vevay', -5);
INSERT INTO `timezones` VALUES(114, 'America/Inuvik', -7);
INSERT INTO `timezones` VALUES(115, 'America/Iqaluit', -5);
INSERT INTO `timezones` VALUES(116, 'America/Jamaica', -5);
INSERT INTO `timezones` VALUES(117, 'America/Juneau', -9);
INSERT INTO `timezones` VALUES(118, 'America/Kentucky/Louisville', -5);
INSERT INTO `timezones` VALUES(119, 'America/Kentucky/Monticello', -5);
INSERT INTO `timezones` VALUES(120, 'America/La_Paz', -4);
INSERT INTO `timezones` VALUES(121, 'America/Lima', -5);
INSERT INTO `timezones` VALUES(122, 'America/Los_Angeles', -8);
INSERT INTO `timezones` VALUES(123, 'America/Maceio', -3);
INSERT INTO `timezones` VALUES(124, 'America/Managua', -6);
INSERT INTO `timezones` VALUES(125, 'America/Manaus', -4);
INSERT INTO `timezones` VALUES(126, 'America/Martinique', -4);
INSERT INTO `timezones` VALUES(127, 'America/Mazatlan', -7);
INSERT INTO `timezones` VALUES(128, 'America/Menominee', -6);
INSERT INTO `timezones` VALUES(129, 'America/Merida', -6);
INSERT INTO `timezones` VALUES(130, 'America/Mexico_City', -6);
INSERT INTO `timezones` VALUES(131, 'America/Miquelon', -3);
INSERT INTO `timezones` VALUES(132, 'America/Monterrey', -6);
INSERT INTO `timezones` VALUES(133, 'America/Montevideo', -2);
INSERT INTO `timezones` VALUES(134, 'America/Montreal', -5);
INSERT INTO `timezones` VALUES(135, 'America/Montserrat', -4);
INSERT INTO `timezones` VALUES(136, 'America/Nassau', -5);
INSERT INTO `timezones` VALUES(137, 'America/New_York', -5);
INSERT INTO `timezones` VALUES(138, 'America/Nipigon', -5);
INSERT INTO `timezones` VALUES(139, 'America/Nome', -9);
INSERT INTO `timezones` VALUES(140, 'America/Noronha', -2);
INSERT INTO `timezones` VALUES(141, 'America/North_Dakota/Center', -6);
INSERT INTO `timezones` VALUES(142, 'America/Panama', -5);
INSERT INTO `timezones` VALUES(143, 'America/Pangnirtung', -5);
INSERT INTO `timezones` VALUES(144, 'America/Paramaribo', -3);
INSERT INTO `timezones` VALUES(145, 'America/Phoenix', -7);
INSERT INTO `timezones` VALUES(146, 'America/Port-au-Prince', -5);
INSERT INTO `timezones` VALUES(147, 'America/Port_of_Spain', -4);
INSERT INTO `timezones` VALUES(148, 'America/Porto_Velho', -4);
INSERT INTO `timezones` VALUES(149, 'America/Puerto_Rico', -4);
INSERT INTO `timezones` VALUES(150, 'America/Rainy_River', -6);
INSERT INTO `timezones` VALUES(151, 'America/Rankin_Inlet', -6);
INSERT INTO `timezones` VALUES(152, 'America/Recife', -3);
INSERT INTO `timezones` VALUES(153, 'America/Regina', -6);
INSERT INTO `timezones` VALUES(154, 'America/Rio_Branco', -5);
INSERT INTO `timezones` VALUES(155, 'America/Santiago', -3);
INSERT INTO `timezones` VALUES(156, 'America/Santo_Domingo', -4);
INSERT INTO `timezones` VALUES(157, 'America/Sao_Paulo', -2);
INSERT INTO `timezones` VALUES(158, 'America/Scoresbysund', -1);
INSERT INTO `timezones` VALUES(159, 'America/St_Johns', -3);
INSERT INTO `timezones` VALUES(160, 'America/St_Kitts', -4);
INSERT INTO `timezones` VALUES(161, 'America/St_Lucia', -4);
INSERT INTO `timezones` VALUES(162, 'America/St_Thomas', -4);
INSERT INTO `timezones` VALUES(163, 'America/St_Vincent', -4);
INSERT INTO `timezones` VALUES(164, 'America/Swift_Current', -6);
INSERT INTO `timezones` VALUES(165, 'America/Tegucigalpa', -6);
INSERT INTO `timezones` VALUES(166, 'America/Thule', -4);
INSERT INTO `timezones` VALUES(167, 'America/Thunder_Bay', -5);
INSERT INTO `timezones` VALUES(168, 'America/Tijuana', -8);
INSERT INTO `timezones` VALUES(169, 'America/Toronto', -5);
INSERT INTO `timezones` VALUES(170, 'America/Tortola', -4);
INSERT INTO `timezones` VALUES(171, 'America/Vancouver', -8);
INSERT INTO `timezones` VALUES(172, 'America/Whitehorse', -8);
INSERT INTO `timezones` VALUES(173, 'America/Winnipeg', -6);
INSERT INTO `timezones` VALUES(174, 'America/Yakutat', -9);
INSERT INTO `timezones` VALUES(175, 'America/Yellowknife', -7);
INSERT INTO `timezones` VALUES(176, 'Antarctica/Casey', 8);
INSERT INTO `timezones` VALUES(177, 'Antarctica/Davis', 7);
INSERT INTO `timezones` VALUES(178, 'Antarctica/DumontDUrville', 10);
INSERT INTO `timezones` VALUES(179, 'Antarctica/Mawson', 6);
INSERT INTO `timezones` VALUES(180, 'Antarctica/McMurdo', 13);
INSERT INTO `timezones` VALUES(181, 'Antarctica/Palmer', -3);
INSERT INTO `timezones` VALUES(182, 'Antarctica/Rothera', -3);
INSERT INTO `timezones` VALUES(183, 'Antarctica/Syowa', 3);
INSERT INTO `timezones` VALUES(184, 'Antarctica/Vostok', 6);
INSERT INTO `timezones` VALUES(185, 'Asia/Aden', 3);
INSERT INTO `timezones` VALUES(186, 'Asia/Almaty', 6);
INSERT INTO `timezones` VALUES(187, 'Asia/Amman', 2);
INSERT INTO `timezones` VALUES(188, 'Asia/Anadyr', 12);
INSERT INTO `timezones` VALUES(189, 'Asia/Aqtau', 5);
INSERT INTO `timezones` VALUES(190, 'Asia/Aqtobe', 5);
INSERT INTO `timezones` VALUES(191, 'Asia/Ashgabat', 5);
INSERT INTO `timezones` VALUES(192, 'Asia/Baghdad', 3);
INSERT INTO `timezones` VALUES(193, 'Asia/Bahrain', 3);
INSERT INTO `timezones` VALUES(194, 'Asia/Baku', 4);
INSERT INTO `timezones` VALUES(195, 'Asia/Bangkok', 7);
INSERT INTO `timezones` VALUES(196, 'Asia/Beirut', 2);
INSERT INTO `timezones` VALUES(197, 'Asia/Bishkek', 6);
INSERT INTO `timezones` VALUES(198, 'Asia/Brunei', 8);
INSERT INTO `timezones` VALUES(199, 'Asia/Calcutta', 5);
INSERT INTO `timezones` VALUES(200, 'Asia/Choibalsan', 9);
INSERT INTO `timezones` VALUES(201, 'Asia/Chongqing', 8);
INSERT INTO `timezones` VALUES(202, 'Asia/Colombo', 5);
INSERT INTO `timezones` VALUES(203, 'Asia/Damascus', 2);
INSERT INTO `timezones` VALUES(204, 'Asia/Dhaka', 6);
INSERT INTO `timezones` VALUES(205, 'Asia/Dili', 9);
INSERT INTO `timezones` VALUES(206, 'Asia/Dubai', 4);
INSERT INTO `timezones` VALUES(207, 'Asia/Dushanbe', 5);
INSERT INTO `timezones` VALUES(208, 'Asia/Gaza', 2);
INSERT INTO `timezones` VALUES(209, 'Asia/Harbin', 8);
INSERT INTO `timezones` VALUES(210, 'Asia/Hong_Kong', 8);
INSERT INTO `timezones` VALUES(211, 'Asia/Hovd', 7);
INSERT INTO `timezones` VALUES(212, 'Asia/Irkutsk', 8);
INSERT INTO `timezones` VALUES(213, 'Asia/Jakarta', 7);
INSERT INTO `timezones` VALUES(214, 'Asia/Jayapura', 9);
INSERT INTO `timezones` VALUES(215, 'Asia/Jerusalem', 2);
INSERT INTO `timezones` VALUES(216, 'Asia/Kabul', 4);
INSERT INTO `timezones` VALUES(217, 'Asia/Kamchatka', 12);
INSERT INTO `timezones` VALUES(218, 'Asia/Karachi', 5);
INSERT INTO `timezones` VALUES(219, 'Asia/Kashgar', 8);
INSERT INTO `timezones` VALUES(220, 'Asia/Katmandu', 5);
INSERT INTO `timezones` VALUES(221, 'Asia/Krasnoyarsk', 7);
INSERT INTO `timezones` VALUES(222, 'Asia/Kuala_Lumpur', 8);
INSERT INTO `timezones` VALUES(223, 'Asia/Kuching', 8);
INSERT INTO `timezones` VALUES(224, 'Asia/Kuwait', 3);
INSERT INTO `timezones` VALUES(225, 'Asia/Macau', 8);
INSERT INTO `timezones` VALUES(226, 'Asia/Magadan', 11);
INSERT INTO `timezones` VALUES(227, 'Asia/Makassar', 8);
INSERT INTO `timezones` VALUES(228, 'Asia/Manila', 8);
INSERT INTO `timezones` VALUES(229, 'Asia/Muscat', 4);
INSERT INTO `timezones` VALUES(230, 'Asia/Nicosia', 2);
INSERT INTO `timezones` VALUES(231, 'Asia/Novosibirsk', 6);
INSERT INTO `timezones` VALUES(232, 'Asia/Omsk', 6);
INSERT INTO `timezones` VALUES(233, 'Asia/Oral', 5);
INSERT INTO `timezones` VALUES(234, 'Asia/Phnom_Penh', 7);
INSERT INTO `timezones` VALUES(235, 'Asia/Pontianak', 7);
INSERT INTO `timezones` VALUES(236, 'Asia/Pyongyang', 9);
INSERT INTO `timezones` VALUES(237, 'Asia/Qatar', 3);
INSERT INTO `timezones` VALUES(238, 'Asia/Qyzylorda', 6);
INSERT INTO `timezones` VALUES(239, 'Asia/Rangoon', 6);
INSERT INTO `timezones` VALUES(240, 'Asia/Riyadh', 3);
INSERT INTO `timezones` VALUES(241, 'Asia/Saigon', 7);
INSERT INTO `timezones` VALUES(242, 'Asia/Sakhalin', 10);
INSERT INTO `timezones` VALUES(243, 'Asia/Samarkand', 5);
INSERT INTO `timezones` VALUES(244, 'Asia/Seoul', 9);
INSERT INTO `timezones` VALUES(245, 'Asia/Shanghai', 8);
INSERT INTO `timezones` VALUES(246, 'Asia/Singapore', 8);
INSERT INTO `timezones` VALUES(247, 'Asia/Taipei', 8);
INSERT INTO `timezones` VALUES(248, 'Asia/Tashkent', 5);
INSERT INTO `timezones` VALUES(249, 'Asia/Tbilisi', 4);
INSERT INTO `timezones` VALUES(250, 'Asia/Tehran', 3);
INSERT INTO `timezones` VALUES(251, 'Asia/Thimphu', 6);
INSERT INTO `timezones` VALUES(252, 'Asia/Tokyo', 9);
INSERT INTO `timezones` VALUES(253, 'Asia/Ulaanbaatar', 8);
INSERT INTO `timezones` VALUES(254, 'Asia/Urumqi', 8);
INSERT INTO `timezones` VALUES(255, 'Asia/Vientiane', 7);
INSERT INTO `timezones` VALUES(256, 'Asia/Vladivostok', 10);
INSERT INTO `timezones` VALUES(257, 'Asia/Yakutsk', 9);
INSERT INTO `timezones` VALUES(258, 'Asia/Yekaterinburg', 5);
INSERT INTO `timezones` VALUES(259, 'Asia/Yerevan', 4);
INSERT INTO `timezones` VALUES(260, 'Atlantic/Azores', -1);
INSERT INTO `timezones` VALUES(261, 'Atlantic/Bermuda', -4);
INSERT INTO `timezones` VALUES(262, 'Atlantic/Canary', 0);
INSERT INTO `timezones` VALUES(263, 'Atlantic/Cape_Verde', -1);
INSERT INTO `timezones` VALUES(264, 'Atlantic/Faeroe', 0);
INSERT INTO `timezones` VALUES(265, 'Atlantic/Madeira', 0);
INSERT INTO `timezones` VALUES(266, 'Atlantic/Reykjavik', 0);
INSERT INTO `timezones` VALUES(267, 'Atlantic/South_Georgia', -2);
INSERT INTO `timezones` VALUES(268, 'Atlantic/St_Helena', 0);
INSERT INTO `timezones` VALUES(269, 'Atlantic/Stanley', -3);
INSERT INTO `timezones` VALUES(270, 'Australia/Adelaide', 10);
INSERT INTO `timezones` VALUES(271, 'Australia/Brisbane', 10);
INSERT INTO `timezones` VALUES(272, 'Australia/Broken_Hill', 10);
INSERT INTO `timezones` VALUES(273, 'Australia/Currie', 11);
INSERT INTO `timezones` VALUES(274, 'Australia/Darwin', 9);
INSERT INTO `timezones` VALUES(275, 'Australia/Hobart', 11);
INSERT INTO `timezones` VALUES(276, 'Australia/Lindeman', 10);
INSERT INTO `timezones` VALUES(277, 'Australia/Lord_Howe', 11);
INSERT INTO `timezones` VALUES(278, 'Australia/Melbourne', 11);
INSERT INTO `timezones` VALUES(279, 'Australia/Perth', 8);
INSERT INTO `timezones` VALUES(280, 'Australia/Sydney', 11);
INSERT INTO `timezones` VALUES(281, 'Europe/Amsterdam', 1);
INSERT INTO `timezones` VALUES(282, 'Europe/Andorra', 1);
INSERT INTO `timezones` VALUES(283, 'Europe/Athens', 2);
INSERT INTO `timezones` VALUES(284, 'Europe/Belgrade', 1);
INSERT INTO `timezones` VALUES(285, 'Europe/Berlin', 1);
INSERT INTO `timezones` VALUES(286, 'Europe/Brussels', 1);
INSERT INTO `timezones` VALUES(287, 'Europe/Bucharest', 2);
INSERT INTO `timezones` VALUES(288, 'Europe/Budapest', 1);
INSERT INTO `timezones` VALUES(289, 'Europe/Chisinau', 2);
INSERT INTO `timezones` VALUES(290, 'Europe/Copenhagen', 1);
INSERT INTO `timezones` VALUES(291, 'Europe/Dublin', 0);
INSERT INTO `timezones` VALUES(292, 'Europe/Gibraltar', 1);
INSERT INTO `timezones` VALUES(293, 'Europe/Helsinki', 2);
INSERT INTO `timezones` VALUES(294, 'Europe/Istanbul', 2);
INSERT INTO `timezones` VALUES(295, 'Europe/Kaliningrad', 2);
INSERT INTO `timezones` VALUES(296, 'Europe/Kiev', 2);
INSERT INTO `timezones` VALUES(297, 'Europe/Lisbon', 0);
INSERT INTO `timezones` VALUES(298, 'Europe/London', 0);
INSERT INTO `timezones` VALUES(299, 'Europe/Luxembourg', 1);
INSERT INTO `timezones` VALUES(300, 'Europe/Madrid', 1);
INSERT INTO `timezones` VALUES(301, 'Europe/Malta', 1);
INSERT INTO `timezones` VALUES(302, 'Europe/Minsk', 2);
INSERT INTO `timezones` VALUES(303, 'Europe/Monaco', 1);
INSERT INTO `timezones` VALUES(304, 'Europe/Moscow', 3);
INSERT INTO `timezones` VALUES(305, 'Europe/Oslo', 1);
INSERT INTO `timezones` VALUES(306, 'Europe/Paris', 1);
INSERT INTO `timezones` VALUES(307, 'Europe/Prague', 1);
INSERT INTO `timezones` VALUES(308, 'Europe/Riga', 2);
INSERT INTO `timezones` VALUES(309, 'Europe/Rome', 1);
INSERT INTO `timezones` VALUES(310, 'Europe/Samara', 4);
INSERT INTO `timezones` VALUES(311, 'Europe/Simferopol', 2);
INSERT INTO `timezones` VALUES(312, 'Europe/Sofia', 2);
INSERT INTO `timezones` VALUES(313, 'Europe/Stockholm', 1);
INSERT INTO `timezones` VALUES(314, 'Europe/Tallinn', 2);
INSERT INTO `timezones` VALUES(315, 'Europe/Tirane', 1);
INSERT INTO `timezones` VALUES(316, 'Europe/Uzhgorod', 2);
INSERT INTO `timezones` VALUES(317, 'Europe/Vaduz', 1);
INSERT INTO `timezones` VALUES(318, 'Europe/Vienna', 1);
INSERT INTO `timezones` VALUES(319, 'Europe/Vilnius', 2);
INSERT INTO `timezones` VALUES(320, 'Europe/Warsaw', 1);
INSERT INTO `timezones` VALUES(321, 'Europe/Zaporozhye', 2);
INSERT INTO `timezones` VALUES(322, 'Europe/Zurich', 1);
INSERT INTO `timezones` VALUES(323, 'Indian/Antananarivo', 3);
INSERT INTO `timezones` VALUES(324, 'Indian/Chagos', 6);
INSERT INTO `timezones` VALUES(325, 'Indian/Christmas', 7);
INSERT INTO `timezones` VALUES(326, 'Indian/Cocos', 6);
INSERT INTO `timezones` VALUES(327, 'Indian/Comoro', 3);
INSERT INTO `timezones` VALUES(328, 'Indian/Kerguelen', 5);
INSERT INTO `timezones` VALUES(329, 'Indian/Mahe', 4);
INSERT INTO `timezones` VALUES(330, 'Indian/Maldives', 5);
INSERT INTO `timezones` VALUES(331, 'Indian/Mauritius', 4);
INSERT INTO `timezones` VALUES(332, 'Indian/Mayotte', 3);
INSERT INTO `timezones` VALUES(333, 'Indian/Reunion', 4);
INSERT INTO `timezones` VALUES(334, 'Pacific/Apia', -11);
INSERT INTO `timezones` VALUES(335, 'Pacific/Auckland', 13);
INSERT INTO `timezones` VALUES(336, 'Pacific/Chatham', 13);
INSERT INTO `timezones` VALUES(337, 'Pacific/Easter', -5);
INSERT INTO `timezones` VALUES(338, 'Pacific/Efate', 11);
INSERT INTO `timezones` VALUES(339, 'Pacific/Enderbury', 13);
INSERT INTO `timezones` VALUES(340, 'Pacific/Fakaofo', -10);
INSERT INTO `timezones` VALUES(341, 'Pacific/Fiji', 12);
INSERT INTO `timezones` VALUES(342, 'Pacific/Funafuti', 12);
INSERT INTO `timezones` VALUES(343, 'Pacific/Galapagos', -6);
INSERT INTO `timezones` VALUES(344, 'Pacific/Gambier', -9);
INSERT INTO `timezones` VALUES(345, 'Pacific/Guadalcanal', 11);
INSERT INTO `timezones` VALUES(346, 'Pacific/Guam', 10);
INSERT INTO `timezones` VALUES(347, 'Pacific/Honolulu', -10);
INSERT INTO `timezones` VALUES(348, 'Pacific/Johnston', -10);
INSERT INTO `timezones` VALUES(349, 'Pacific/Kiritimati', 14);
INSERT INTO `timezones` VALUES(350, 'Pacific/Kosrae', 11);
INSERT INTO `timezones` VALUES(351, 'Pacific/Kwajalein', 12);
INSERT INTO `timezones` VALUES(352, 'Pacific/Majuro', 12);
INSERT INTO `timezones` VALUES(353, 'Pacific/Marquesas', -9);
INSERT INTO `timezones` VALUES(354, 'Pacific/Midway', -11);
INSERT INTO `timezones` VALUES(355, 'Pacific/Nauru', 12);
INSERT INTO `timezones` VALUES(356, 'Pacific/Niue', -11);
INSERT INTO `timezones` VALUES(357, 'Pacific/Norfolk', 11);
INSERT INTO `timezones` VALUES(358, 'Pacific/Noumea', 11);
INSERT INTO `timezones` VALUES(359, 'Pacific/Pago_Pago', -11);
INSERT INTO `timezones` VALUES(360, 'Pacific/Palau', 9);
INSERT INTO `timezones` VALUES(361, 'Pacific/Pitcairn', -8);
INSERT INTO `timezones` VALUES(362, 'Pacific/Ponape', 11);
INSERT INTO `timezones` VALUES(363, 'Pacific/Port_Moresby', 10);
INSERT INTO `timezones` VALUES(364, 'Pacific/Rarotonga', -10);
INSERT INTO `timezones` VALUES(365, 'Pacific/Saipan', 10);
INSERT INTO `timezones` VALUES(366, 'Pacific/Tahiti', -10);
INSERT INTO `timezones` VALUES(367, 'Pacific/Tarawa', 12);
INSERT INTO `timezones` VALUES(368, 'Pacific/Tongatapu', 13);
INSERT INTO `timezones` VALUES(369, 'Pacific/Truk', 10);
INSERT INTO `timezones` VALUES(370, 'Pacific/Wake', 12);
INSERT INTO `timezones` VALUES(371, 'Pacific/Wallis', 12);
INSERT INTO `timezones` VALUES(372, 'GMT', 0);

CREATE TABLE `tmp_active` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `notify_id` bigint(20) NOT NULL,
  `command_id` int(11) DEFAULT NULL,
  `dest` varchar(255) DEFAULT NULL,
  `from_user` varchar(255) DEFAULT NULL,
  `time_string` varchar(255) DEFAULT NULL,
  `user` varchar(255) DEFAULT NULL,
  `method` varchar(255) DEFAULT NULL,
  `notify_cmd` varchar(255) DEFAULT NULL,
  `retries` int(11) DEFAULT '0',
  `rule` int(11) DEFAULT '0',
  `progress` tinyint(1) DEFAULT '0',
  `esc_flag` tinyint(1) DEFAULT '0',
  `bundled` bigint(20) DEFAULT '0',
  `stime` int(11) DEFAULT '0',
  UNIQUE KEY `id` (`id`),
  KEY `command_id` (`command_id`),
  KEY `notify_id` (`notify_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

CREATE TABLE `tmp_commands` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `operation` varchar(255) DEFAULT NULL,
  `external_id` bigint(20) NOT NULL,
  `recipients` varchar(255) NOT NULL,
  `host` varchar(255) DEFAULT NULL,
  `host_alias` varchar(255) DEFAULT NULL,
  `host_address` varchar(255) DEFAULT NULL,
  `hostgroups` varchar(255) NOT NULL,
  `service` varchar(255) DEFAULT NULL,
  `servicegroups` varchar(255) DEFAULT NULL,
  `check_type` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `stime` int(11) DEFAULT '0',
  `notification_type` varchar(255) DEFAULT NULL,
  `authors` varchar(255) DEFAULT NULL,
  `comments` varchar(255) DEFAULT NULL,
  `output` varchar(4096) DEFAULT NULL,
  UNIQUE KEY `id` (`id`),
  KEY `external_id` (`external_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;


ALTER TABLE `tmp_active`
  ADD CONSTRAINT `tmp_active_ibfk_1` FOREIGN KEY (`command_id`) REFERENCES `tmp_commands` (`id`) ON DELETE CASCADE;
