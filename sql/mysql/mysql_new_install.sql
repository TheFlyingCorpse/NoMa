CREATE TABLE IF NOT EXISTS `contactgroups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name_short` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `view_only` tinyint(1) NOT NULL DEFAULT '0',
  `timeframe_id` int(11) NOT NULL DEFAULT '0',
  `timezone_id` int(11) NOT NULL DEFAULT '372',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `name_short` (`name_short`)
);

CREATE TABLE IF NOT EXISTS `contactgroups_to_contacts` (
  `contactgroup_id` int(11) NOT NULL,
  `contact_id` int(11) NOT NULL,
  KEY `contactgroup_id` (`contactgroup_id`),
  KEY `contact_id` (`contact_id`)
);

CREATE TABLE IF NOT EXISTS `contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin` tinyint(1) NOT NULL,
  `username` varchar(255) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `email` varchar(255) NULL,
  `phone` varchar(255) NULL,
  `mobile` varchar(255) NULL,
  `section` varchar(255) NULL,
  `growladdress` varchar(255) NULL,
  `password` varchar(255) NULL,
  `timeframe_id` int(11) NOT NULL DEFAULT '0',
  `timezone_id` int(11) NOT NULL DEFAULT '372',
  `restrict_alerts` tinyint(1) NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
);

CREATE TABLE IF NOT EXISTS `escalations_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `notification_id` int(11) NOT NULL,
  `on_ok` tinyint(1) DEFAULT '0',
  `on_warning` tinyint(1) DEFAULT '0',
  `on_critical` tinyint(1) DEFAULT '0',
  `on_unknown` tinyint(1) DEFAULT '0',
  `on_host_up` tinyint(1) DEFAULT '0',
  `on_host_unreachable` tinyint(1) DEFAULT '0',
  `on_host_down` tinyint(1) DEFAULT '0',
  `on_type_problem` tinyint(1) DEFAULT '0',
  `on_type_recovery` tinyint(1) DEFAULT '0',
  `on_type_flappingstart` tinyint(1) DEFAULT '0',
  `on_type_flappingstop` tinyint(1) DEFAULT '0',
  `on_type_flappingdisabled` tinyint(1) DEFAULT '0',
  `on_type_downtimestart` tinyint(1) DEFAULT '0',
  `on_type_downtimeend` tinyint(1) DEFAULT '0',
  `on_type_downtimecancelled` tinyint(1) DEFAULT '0',
  `on_type_acknowledgement` tinyint(1) DEFAULT '0',
  `on_type_custom` tinyint(1) DEFAULT '0',
  `notify_after_tries` varchar(255) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `notification_id` (`notification_id`)
);

CREATE TABLE IF NOT EXISTS `escalations_contacts_to_contactgroups` (
  `escalation_contacts_id` int(11) NOT NULL,
  `contactgroup_id` int(11) NOT NULL,
  KEY `contactgroup_id` (`contactgroup_id`),
  KEY `escalation_contacts_id` (`escalation_contacts_id`)
);

CREATE TABLE IF NOT EXISTS `escalations_contacts_to_contacts` (
  `escalation_contacts_id` int(11) NOT NULL,
  `contacts_id` int(11) NOT NULL,
  KEY `escalation_contacts_id` (`escalation_contacts_id`),
  KEY `contacts_id` (`contacts_id`)
);

CREATE TABLE IF NOT EXISTS `escalations_contacts_to_methods` (
  `escalation_contacts_id` int(11) NOT NULL,
  `method_id` int(11) NOT NULL,
  KEY `escalation_contacts_id` (`escalation_contacts_id`),
  KEY `method_id` (`method_id`)
);

CREATE TABLE IF NOT EXISTS `escalation_stati` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `notification_rule` int(11) NULL,
  `starttime` int(11) NOT NULL,
  `counter` int(11) NOT NULL,
  `incident_id` bigint(20) NULL,
  `recipients` varchar(255) NULL,
  `host` varchar(255) NOT NULL,
  `host_alias` varchar(255) NULL,
  `host_address` varchar(255) NULL,
  `hostgroups` varchar(255) NULL,
  `service` varchar(255) NULL,
  `servicegroups` varchar(255) NULL,
  `check_type` varchar(255) NOT NULL,
  `status` varchar(255) NOT NULL,
  `time_string` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `authors` varchar(255) NULL,
  `comments` varchar(255) NULL,
  `output` varchar(4096) NULL,
  PRIMARY KEY (`id`),
  KEY `incident_id` (`incident_id`)
);

CREATE TABLE IF NOT EXISTS `holidays` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `holiday_name` varchar(255) NULL,
  `timeframe_id` int(11) NULL,
  `contact_id` int(11) NULL,
  `holiday_start` datetime NOT NULL,
  `holiday_end` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `contact_id` (`contact_id`),
  KEY `timeframe_id` (`timeframe_id`)
);

CREATE TABLE IF NOT EXISTS `information` (
  `id` int(11) NOT NULL,
  `type` varchar(20) NOT NULL,
  `content` varchar(20) NOT NULL,
  KEY `id` (`id`)
);

CREATE TABLE IF NOT EXISTS `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `notification_name` varchar(40) NULL,
  `notification_description` varchar(1024) NULL,
  `active` tinyint(1) NOT NULL,
  `username` varchar(255) NOT NULL,
  `recipients_include` varchar(255) NULL,
  `recipients_exclude` varchar(255) NULL,
  `hosts_include` varchar(255) NULL,
  `hosts_exclude` varchar(255) NULL,
  `hostgroups_include` varchar(255) NULL,
  `hostgroups_exclude` varchar(255) NULL,
  `services_include` varchar(255) NULL,
  `services_exclude` varchar(255) NULL,
  `servicegroups_include` varchar(255) NULL,
  `servicegroups_exclude` varchar(255) NULL,
  `notify_after_tries` varchar(10) NOT NULL DEFAULT '0',
  `let_notifier_handle` tinyint(1) DEFAULT '0',
  `rollover` tinyint(1) DEFAULT '0',
  `reloop_delay` int(11) DEFAULT '0',
  `on_ok` tinyint(1) DEFAULT '0',
  `on_warning` tinyint(1) DEFAULT '0',
  `on_unknown` tinyint(1) DEFAULT '0',
  `on_host_unreachable` tinyint(1) DEFAULT '0',
  `on_critical` tinyint(1) DEFAULT '0',
  `on_host_up` tinyint(1) DEFAULT '0',
  `on_host_down` tinyint(1) DEFAULT '0',
  `on_type_problem` tinyint(1) DEFAULT '0',
  `on_type_recovery` tinyint(1) DEFAULT '0',
  `on_type_flappingstart` tinyint(1) DEFAULT '0',
  `on_type_flappingstop` tinyint(1) DEFAULT '0',
  `on_type_flappingdisabled` tinyint(1) DEFAULT '0',
  `on_type_downtimestart` tinyint(1) DEFAULT '0',
  `on_type_downtimeend` tinyint(1) DEFAULT '0',
  `on_type_downtimecancelled` tinyint(1) DEFAULT '0',
  `on_type_acknowledgement` tinyint(1) DEFAULT '0',
  `on_type_custom` tinyint(1) DEFAULT '0',
  `timezone_id` int(11) NOT NULL DEFAULT '372',
  `timeframe_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `time` (`timezone_id`,`timeframe_id`)
);

CREATE TABLE IF NOT EXISTS `notifications_to_contactgroups` (
  `notification_id` int(11) NOT NULL,
  `contactgroup_id` int(11) NOT NULL,
  KEY `notification_id` (`notification_id`),
  KEY `contactgroup_id` (`contactgroup_id`)
);

CREATE TABLE IF NOT EXISTS `notifications_to_contacts` (
  `notification_id` int(11) NOT NULL,
  `contact_id` int(11) NOT NULL,
  KEY `notification_id` (`notification_id`),
  KEY `contact_id` (`contact_id`)
);

CREATE TABLE IF NOT EXISTS `notifications_to_methods` (
  `notification_id` int(11) NOT NULL,
  `method_id` int(11) NOT NULL,
  KEY `notification_id` (`notification_id`),
  KEY `method_id` (`method_id`)
);

CREATE TABLE IF NOT EXISTS `notification_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timestamp` datetime NOT NULL,
  `counter` int(11) NOT NULL,
  `check_type` varchar(10) NOT NULL,
  `check_result` varchar(15) NOT NULL,
  `host` varchar(255) NOT NULL,
  `service` varchar(255) NOT NULL,
  `notification_type` varchar(255) NOT NULL,
  `method` varchar(255) NOT NULL,
  `user` varchar(255) NOT NULL,
  `result` varchar(1023) NOT NULL,
  `unique_id` bigint(20) NULL,
  `incident_id` bigint(20) NULL,
  `notification_rule` int(11) NULL,
  `last_method` int(11) NULL,
  PRIMARY KEY (`id`),
  KEY `unique_id` (`unique_id`),
  KEY `incident_id` (`incident_id`)
);

CREATE TABLE IF NOT EXISTS `notification_methods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `method` varchar(255) NOT NULL,
  `command` varchar(255) NOT NULL,
  `contact_field` varchar(255) NOT NULL,
  `sender` varchar(255) NULL,
  `on_fail` int(11) NOT NULL,
  `ack_able` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `notification_stati` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host` varchar(255) NOT NULL,
  `service` varchar(255) NOT NULL,
  `check_type` varchar(10) NOT NULL,
  `check_result` varchar(15) NOT NULL,
  `counter` int(11) NOT NULL,
  `pid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `timeframes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timeframe_name` varchar(60) NOT NULL,
  `dt_validFrom` datetime NOT NULL,
  `dt_validTo` datetime NOT NULL,
  `day_monday_all` tinyint(1) DEFAULT '0',
  `day_monday_1st` tinyint(1) DEFAULT '0',
  `day_monday_2nd` tinyint(1) DEFAULT '0',
  `day_monday_3rd` tinyint(1) DEFAULT '0',
  `day_monday_4th` tinyint(1) DEFAULT '0',
  `day_monday_5th` tinyint(1) DEFAULT '0',
  `day_monday_last` tinyint(1) DEFAULT '0',
  `day_tuesday_all` tinyint(1) DEFAULT '0',
  `day_tuesday_1st` tinyint(1) DEFAULT '0',
  `day_tuesday_2nd` tinyint(1) DEFAULT '0',
  `day_tuesday_3rd` tinyint(1) DEFAULT '0',
  `day_tuesday_4th` tinyint(1) DEFAULT '0',
  `day_tuesday_5th` tinyint(1) DEFAULT '0',
  `day_tuesday_last` tinyint(1) DEFAULT '0',
  `day_wednesday_all` tinyint(1) DEFAULT '0',
  `day_wednesday_1st` tinyint(1) DEFAULT '0',
  `day_wednesday_2nd` tinyint(1) DEFAULT '0',
  `day_wednesday_3rd` tinyint(1) DEFAULT '0',
  `day_wednesday_4th` tinyint(1) DEFAULT '0',
  `day_wednesday_5th` tinyint(1) DEFAULT '0',
  `day_wednesday_last` tinyint(1) DEFAULT '0',
  `day_thursday_all` tinyint(1) DEFAULT '0',
  `day_thursday_1st` tinyint(1) DEFAULT '0',
  `day_thursday_2nd` tinyint(1) DEFAULT '0',
  `day_thursday_3rd` tinyint(1) DEFAULT '0',
  `day_thursday_4th` tinyint(1) DEFAULT '0',
  `day_thursday_5th` tinyint(1) DEFAULT '0',
  `day_thursday_last` tinyint(1) DEFAULT '0',
  `day_friday_all` tinyint(1) DEFAULT '0',
  `day_friday_1st` tinyint(1) DEFAULT '0',
  `day_friday_2nd` tinyint(1) DEFAULT '0',
  `day_friday_3rd` tinyint(1) DEFAULT '0',
  `day_friday_4th` tinyint(1) DEFAULT '0',
  `day_friday_5th` tinyint(1) DEFAULT '0',
  `day_friday_last` tinyint(1) DEFAULT '0',
  `day_saturday_all` tinyint(1) DEFAULT '0',
  `day_saturday_1st` tinyint(1) DEFAULT '0',
  `day_saturday_2nd` tinyint(1) DEFAULT '0',
  `day_saturday_3rd` tinyint(1) DEFAULT '0',
  `day_saturday_4th` tinyint(1) DEFAULT '0',
  `day_saturday_5th` tinyint(1) DEFAULT '0',
  `day_saturday_last` tinyint(1) DEFAULT '0',
  `day_sunday_all` tinyint(1) DEFAULT '0',
  `day_sunday_1st` tinyint(1) DEFAULT '0',
  `day_sunday_2nd` tinyint(1) DEFAULT '0',
  `day_sunday_3rd` tinyint(1) DEFAULT '0',
  `day_sunday_4th` tinyint(1) DEFAULT '0',
  `day_sunday_5th` tinyint(1) DEFAULT '0',
  `day_sunday_last` tinyint(1) DEFAULT '0',
  `time_monday_start` time DEFAULT '00:00:00',
  `time_monday_stop` time DEFAULT '00:00:00',
  `time_monday_invert` tinyint(1) DEFAULT '0',
  `time_tuesday_start` time DEFAULT '00:00:00',
  `time_tuesday_stop` time DEFAULT '00:00:00',
  `time_tuesday_invert` tinyint(1) DEFAULT '0',
  `time_wednesday_start` time DEFAULT '00:00:00',
  `time_wednesday_stop` time DEFAULT '00:00:00',
  `time_wednesday_invert` tinyint(1) DEFAULT '0',
  `time_thursday_start` time DEFAULT '00:00:00',
  `time_thursday_stop` time DEFAULT '00:00:00',
  `time_thursday_invert` tinyint(1) DEFAULT '0',
  `time_friday_start` time DEFAULT '00:00:00',
  `time_friday_stop` time DEFAULT '00:00:00',
  `time_friday_invert` tinyint(1) DEFAULT '0',
  `time_saturday_start` time DEFAULT '00:00:00',
  `time_saturday_stop` time DEFAULT '00:00:00',
  `time_saturday_invert` tinyint(1) DEFAULT '0',
  `time_sunday_start` time DEFAULT '00:00:00',
  `time_sunday_stop` time DEFAULT '00:00:00',
  `time_sunday_invert` tinyint(1) DEFAULT '0',
  KEY `id` (`id`)
);

CREATE TABLE IF NOT EXISTS `timezones` (
  `id` int(11) NOT NULL,
  `timezone` varchar(255) NOT NULL,
  `time_diff` tinyint(11) NOT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `tmp_active` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `notify_id` bigint(20) NOT NULL,
  `command_id` int(11) NULL,
  `dest` varchar(255) NULL,
  `from_user` varchar(255) NULL,
  `time_string` varchar(255) NULL,
  `user` varchar(255) NULL,
  `method` varchar(255) NULL,
  `notify_cmd` varchar(255) NULL,
  `retries` int(11) DEFAULT '0',
  `rule` int(11) DEFAULT '0',
  `progress` tinyint(1) DEFAULT '0',
  `esc_flag` tinyint(1) DEFAULT '0',
  `bundled` bigint(20) DEFAULT '0',
  `stime` int(11) DEFAULT '0',
  UNIQUE KEY `id` (`id`),
  KEY `command_id` (`command_id`),
  KEY `notify_id` (`notify_id`)
);

CREATE TABLE IF NOT EXISTS `tmp_commands` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `operation` varchar(255) NULL,
  `external_id` bigint(20) NOT NULL,
  `recipients` varchar(255) NOT NULL,
  `host` varchar(255) NULL,
  `host_alias` varchar(255) NULL,
  `host_address` varchar(255) NULL,
  `hostgroups` varchar(255) NOT NULL,
  `service` varchar(255) NULL,
  `servicegroups` varchar(255) NULL,
  `check_type` varchar(255) NULL,
  `status` varchar(255) NULL,
  `stime` int(11) DEFAULT '0',
  `notification_type` varchar(255) NULL,
  `authors` varchar(255) NULL,
  `comments` varchar(255) NULL,
  `output` varchar(4096) NULL,
  UNIQUE KEY `id` (`id`),
  KEY `external_id` (`external_id`)
);


ALTER TABLE `tmp_active`
  ADD CONSTRAINT `tmp_active_ibfk_1` FOREIGN KEY (`command_id`) REFERENCES `tmp_commands` (`id`) ON DELETE CASCADE;

INSERT INTO `contactgroups` (`id`, `name_short`, `name`, `view_only`, `timeframe_id`, `timezone_id`) VALUES(1, 'group1', 'Group 1', 0, 1, 305);

INSERT INTO `contactgroups_to_contacts` (`contactgroup_id`, `contact_id`) VALUES(1, 2);

INSERT INTO `contacts` (`id`, `admin`, `username`, `full_name`, `email`, `phone`, `mobile`, `section`, `growladdress`, `password`, `timeframe_id`, `timezone_id`, `restrict_alerts`) VALUES(1, 0, '[---]', '', '', '', '', '', '', '', 0, 0, NULL);
INSERT INTO `contacts` (`id`, `admin`, `username`, `full_name`, `email`, `phone`, `mobile`, `section`, `growladdress`, `password`, `timeframe_id`, `timezone_id`, `restrict_alerts`) VALUES(2, 1, 'nagiosadmin', 'Nagios Administrator', 'nagios@localhost', '', '', '', '192.168.1.109', '9e2b1592bd13bea759dab1e3011cab7ef47930cd', 1, 0, 0);

INSERT INTO `information` (`id`, `type`, `content`) VALUES(0, 'dbversion', '2000');

INSERT INTO `notifications` (`id`, `notification_name`, `notification_description`, `active`, `username`, `recipients_include`, `recipients_exclude`, `hosts_include`, `hosts_exclude`, `hostgroups_include`, `hostgroups_exclude`, `services_include`, `services_exclude`, `servicegroups_include`, `servicegroups_exclude`, `notify_after_tries`, `let_notifier_handle`, `rollover`, `reloop_delay`, `on_ok`, `on_warning`, `on_unknown`, `on_host_unreachable`, `on_critical`, `on_host_up`, `on_host_down`, `on_type_problem`, `on_type_recovery`, `on_type_flappingstart`, `on_type_flappingstop`, `on_type_flappingdisabled`, `on_type_downtimestart`, `on_type_downtimeend`, `on_type_downtimecancelled`, `on_type_acknowledgement`, `on_type_custom`, `timezone_id`, `timeframe_id`) VALUES(1, 'default', 'default rule', 1, 'nagiosadmin', '', '', '*', '', '*', '', '*', '', '*', '', '1', 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1);

INSERT INTO `notifications_to_contacts` (`notification_id`, `contact_id`) VALUES(1, 2);

INSERT INTO `notifications_to_methods` (`notification_id`, `method_id`) VALUES(1, 1);

INSERT INTO `notification_methods` (`id`, `method`, `command`, `contact_field`, `sender`, `on_fail`, `ack_able`) VALUES(5, 'Voice + SMS fallback', 'voicecall', 'phone', '', 2, 1);
INSERT INTO `notification_methods` (`id`, `method`, `command`, `contact_field`, `sender`, `on_fail`, `ack_able`) VALUES(6, 'Growl', 'growl', 'growladdress', '', 0, 0);
INSERT INTO `notification_methods` (`id`, `method`, `command`, `contact_field`, `sender`, `on_fail`, `ack_able`) VALUES(4, 'Voice + E-Mail fallback', 'voicecall', 'phone', '', 1, 1);
INSERT INTO `notification_methods` (`id`, `method`, `command`, `contact_field`, `sender`, `on_fail`, `ack_able`) VALUES(3, 'Voice', 'voicecall', 'phone', '', 0, 1);
INSERT INTO `notification_methods` (`id`, `method`, `command`, `contact_field`, `sender`, `on_fail`, `ack_able`) VALUES(2, 'SMS', 'sendsms', 'mobile', '', 0, 0);
INSERT INTO `notification_methods` (`id`, `method`, `command`, `contact_field`, `sender`, `on_fail`, `ack_able`) VALUES(1, 'E-Mail', 'sendemail', 'email', 'root@localhost', 0, 0);


INSERT INTO `timeframes` (`id`, `timeframe_name`, `dt_validFrom`, `dt_validTo`, `day_monday_all`, `day_monday_1st`, `day_monday_2nd`, `day_monday_3rd`, `day_monday_4th`, `day_monday_5th`, `day_monday_last`, `day_tuesday_all`, `day_tuesday_1st`, `day_tuesday_2nd`, `day_tuesday_3rd`, `day_tuesday_4th`, `day_tuesday_5th`, `day_tuesday_last`, `day_wednesday_all`, `day_wednesday_1st`, `day_wednesday_2nd`, `day_wednesday_3rd`, `day_wednesday_4th`, `day_wednesday_5th`, `day_wednesday_last`, `day_thursday_all`, `day_thursday_1st`, `day_thursday_2nd`, `day_thursday_3rd`, `day_thursday_4th`, `day_thursday_5th`, `day_thursday_last`, `day_friday_all`, `day_friday_1st`, `day_friday_2nd`, `day_friday_3rd`, `day_friday_4th`, `day_friday_5th`, `day_friday_last`, `day_saturday_all`, `day_saturday_1st`, `day_saturday_2nd`, `day_saturday_3rd`, `day_saturday_4th`, `day_saturday_5th`, `day_saturday_last`, `day_sunday_all`, `day_sunday_1st`, `day_sunday_2nd`, `day_sunday_3rd`, `day_sunday_4th`, `day_sunday_5th`, `day_sunday_last`, `time_monday_start`, `time_monday_stop`, `time_monday_invert`, `time_tuesday_start`, `time_tuesday_stop`, `time_tuesday_invert`, `time_wednesday_start`, `time_wednesday_stop`, `time_wednesday_invert`, `time_thursday_start`, `time_thursday_stop`, `time_thursday_invert`, `time_friday_start`, `time_friday_stop`, `time_friday_invert`, `time_saturday_start`, `time_saturday_stop`, `time_saturday_invert`, `time_sunday_start`, `time_sunday_stop`, `time_sunday_invert`) VALUES(0, 'inactive', '2001-01-01 00:00:00', '2001-01-01 00:00:00', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '00:00:00', '00:00:00', 0, '00:00:00', '00:00:00', 0, '00:00:00', '00:00:00', 0, '00:00:00', '00:00:00', 0, '00:00:00', '00:00:00', 0, '00:00:00', '00:00:00', 0, '00:00:00', '00:00:00', 0);
INSERT INTO `timeframes` (`id`, `timeframe_name`, `dt_validFrom`, `dt_validTo`, `day_monday_all`, `day_monday_1st`, `day_monday_2nd`, `day_monday_3rd`, `day_monday_4th`, `day_monday_5th`, `day_monday_last`, `day_tuesday_all`, `day_tuesday_1st`, `day_tuesday_2nd`, `day_tuesday_3rd`, `day_tuesday_4th`, `day_tuesday_5th`, `day_tuesday_last`, `day_wednesday_all`, `day_wednesday_1st`, `day_wednesday_2nd`, `day_wednesday_3rd`, `day_wednesday_4th`, `day_wednesday_5th`, `day_wednesday_last`, `day_thursday_all`, `day_thursday_1st`, `day_thursday_2nd`, `day_thursday_3rd`, `day_thursday_4th`, `day_thursday_5th`, `day_thursday_last`, `day_friday_all`, `day_friday_1st`, `day_friday_2nd`, `day_friday_3rd`, `day_friday_4th`, `day_friday_5th`, `day_friday_last`, `day_saturday_all`, `day_saturday_1st`, `day_saturday_2nd`, `day_saturday_3rd`, `day_saturday_4th`, `day_saturday_5th`, `day_saturday_last`, `day_sunday_all`, `day_sunday_1st`, `day_sunday_2nd`, `day_sunday_3rd`, `day_sunday_4th`, `day_sunday_5th`, `day_sunday_last`, `time_monday_start`, `time_monday_stop`, `time_monday_invert`, `time_tuesday_start`, `time_tuesday_stop`, `time_tuesday_invert`, `time_wednesday_start`, `time_wednesday_stop`, `time_wednesday_invert`, `time_thursday_start`, `time_thursday_stop`, `time_thursday_invert`, `time_friday_start`, `time_friday_stop`, `time_friday_invert`, `time_saturday_start`, `time_saturday_stop`, `time_saturday_invert`, `time_sunday_start`, `time_sunday_stop`, `time_sunday_invert`) VALUES(1, '24x7', '2011-08-01 00:00:00', '2021-12-31 23:59:59', 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, '00:00:00', '00:00:00', 1, '00:00:00', '00:00:00', 1, '00:00:00', '00:00:00', 1, '00:00:00', '00:00:00', 1, '00:00:00', '00:00:00', 1, '00:00:00', '00:00:00', 1, '00:00:00', '00:00:00', 1);
INSERT INTO `timeframes` (`id`, `timeframe_name`, `dt_validFrom`, `dt_validTo`, `day_monday_all`, `day_monday_1st`, `day_monday_2nd`, `day_monday_3rd`, `day_monday_4th`, `day_monday_5th`, `day_monday_last`, `day_tuesday_all`, `day_tuesday_1st`, `day_tuesday_2nd`, `day_tuesday_3rd`, `day_tuesday_4th`, `day_tuesday_5th`, `day_tuesday_last`, `day_wednesday_all`, `day_wednesday_1st`, `day_wednesday_2nd`, `day_wednesday_3rd`, `day_wednesday_4th`, `day_wednesday_5th`, `day_wednesday_last`, `day_thursday_all`, `day_thursday_1st`, `day_thursday_2nd`, `day_thursday_3rd`, `day_thursday_4th`, `day_thursday_5th`, `day_thursday_last`, `day_friday_all`, `day_friday_1st`, `day_friday_2nd`, `day_friday_3rd`, `day_friday_4th`, `day_friday_5th`, `day_friday_last`, `day_saturday_all`, `day_saturday_1st`, `day_saturday_2nd`, `day_saturday_3rd`, `day_saturday_4th`, `day_saturday_5th`, `day_saturday_last`, `day_sunday_all`, `day_sunday_1st`, `day_sunday_2nd`, `day_sunday_3rd`, `day_sunday_4th`, `day_sunday_5th`, `day_sunday_last`, `time_monday_start`, `time_monday_stop`, `time_monday_invert`, `time_tuesday_start`, `time_tuesday_stop`, `time_tuesday_invert`, `time_wednesday_start`, `time_wednesday_stop`, `time_wednesday_invert`, `time_thursday_start`, `time_thursday_stop`, `time_thursday_invert`, `time_friday_start`, `time_friday_stop`, `time_friday_invert`, `time_saturday_start`, `time_saturday_stop`, `time_saturday_invert`, `time_sunday_start`, `time_sunday_stop`, `time_sunday_invert`) VALUES(2, 'workhours', '2011-08-01 00:00:00', '2021-12-31 23:59:59', 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '08:00:00', '16:00:00', 0, '08:00:00', '16:00:00', 0, '08:00:00', '16:00:00', 0, '08:00:00', '16:00:00', 0, '08:00:00', '16:00:00', 0, '00:00:00', '00:00:00', 0, '00:00:00', '00:00:00', 0);
INSERT INTO `timeframes` (`id`, `timeframe_name`, `dt_validFrom`, `dt_validTo`, `day_monday_all`, `day_monday_1st`, `day_monday_2nd`, `day_monday_3rd`, `day_monday_4th`, `day_monday_5th`, `day_monday_last`, `day_tuesday_all`, `day_tuesday_1st`, `day_tuesday_2nd`, `day_tuesday_3rd`, `day_tuesday_4th`, `day_tuesday_5th`, `day_tuesday_last`, `day_wednesday_all`, `day_wednesday_1st`, `day_wednesday_2nd`, `day_wednesday_3rd`, `day_wednesday_4th`, `day_wednesday_5th`, `day_wednesday_last`, `day_thursday_all`, `day_thursday_1st`, `day_thursday_2nd`, `day_thursday_3rd`, `day_thursday_4th`, `day_thursday_5th`, `day_thursday_last`, `day_friday_all`, `day_friday_1st`, `day_friday_2nd`, `day_friday_3rd`, `day_friday_4th`, `day_friday_5th`, `day_friday_last`, `day_saturday_all`, `day_saturday_1st`, `day_saturday_2nd`, `day_saturday_3rd`, `day_saturday_4th`, `day_saturday_5th`, `day_saturday_last`, `day_sunday_all`, `day_sunday_1st`, `day_sunday_2nd`, `day_sunday_3rd`, `day_sunday_4th`, `day_sunday_5th`, `day_sunday_last`, `time_monday_start`, `time_monday_stop`, `time_monday_invert`, `time_tuesday_start`, `time_tuesday_stop`, `time_tuesday_invert`, `time_wednesday_start`, `time_wednesday_stop`, `time_wednesday_invert`, `time_thursday_start`, `time_thursday_stop`, `time_thursday_invert`, `time_friday_start`, `time_friday_stop`, `time_friday_invert`, `time_saturday_start`, `time_saturday_stop`, `time_saturday_invert`, `time_sunday_start`, `time_sunday_stop`, `time_sunday_invert`) VALUES(3, 'outside workhours', '2011-08-01 00:00:00', '2021-12-31 23:59:59', 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, '08:00:00', '16:00:00', 1, '08:00:00', '16:00:00', 1, '08:00:00', '16:00:00', 1, '08:00:00', '16:00:00', 1, '08:00:00', '16:00:00', 1, '00:00:00', '00:00:00', 1, '00:00:00', '00:00:00', 1);

INSERT INTO `notification_logs` (`id`, `timestamp`, `counter`, `check_type`, `check_result`, `host`, `service`, `notification_type`, `method`, `user`, `result`, `unique_id`, `incident_id`, `notification_rule`, `last_method`) VALUES ('1', now(), '1', '(internal)', 'OK', 'localhost', 'NoMa', '(none)', '(none)', 'NoMa', 'NoMa successfully installed', '123565999600001', '123565999600001', '0', '1');

INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(0, 'GMT', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(1, 'Africa/Abidjan', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(2, 'Africa/Accra', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(3, 'Africa/Addis_Ababa', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(4, 'Africa/Algiers', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(5, 'Africa/Asmera', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(6, 'Africa/Bamako', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(7, 'Africa/Bangui', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(8, 'Africa/Banjul', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(9, 'Africa/Bissau', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(10, 'Africa/Blantyre', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(11, 'Africa/Brazzaville', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(12, 'Africa/Bujumbura', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(13, 'Africa/Cairo', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(14, 'Africa/Casablanca', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(15, 'Africa/Ceuta', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(16, 'Africa/Conakry', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(17, 'Africa/Dakar', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(18, 'Africa/Dar_es_Salaam', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(19, 'Africa/Djibouti', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(20, 'Africa/Douala', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(21, 'Africa/El_Aaiun', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(22, 'Africa/Freetown', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(23, 'Africa/Gaborone', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(24, 'Africa/Harare', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(25, 'Africa/Johannesburg', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(26, 'Africa/Kampala', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(27, 'Africa/Khartoum', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(28, 'Africa/Kigali', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(29, 'Africa/Kinshasa', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(30, 'Africa/Lagos', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(31, 'Africa/Libreville', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(32, 'Africa/Lome', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(33, 'Africa/Luanda', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(34, 'Africa/Lubumbashi', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(35, 'Africa/Lusaka', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(36, 'Africa/Malabo', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(37, 'Africa/Maputo', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(38, 'Africa/Maseru', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(39, 'Africa/Mbabane', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(40, 'Africa/Mogadishu', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(41, 'Africa/Monrovia', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(42, 'Africa/Nairobi', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(43, 'Africa/Ndjamena', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(44, 'Africa/Niamey', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(45, 'Africa/Nouakchott', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(46, 'Africa/Ouagadougou', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(47, 'Africa/Porto-Novo', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(48, 'Africa/Sao_Tome', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(49, 'Africa/Tripoli', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(50, 'Africa/Tunis', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(51, 'Africa/Windhoek', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(52, 'America/Adak', -10);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(53, 'America/Anchorage', -9);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(54, 'America/Anguilla', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(55, 'America/Antigua', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(56, 'America/Araguaina', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(57, 'America/Argentina/Buenos_Aires', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(58, 'America/Argentina/Catamarca', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(59, 'America/Argentina/Cordoba', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(60, 'America/Argentina/Jujuy', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(61, 'America/Argentina/La_Rioja', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(62, 'America/Argentina/Mendoza', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(63, 'America/Argentina/Rio_Gallegos', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(64, 'America/Argentina/San_Juan', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(65, 'America/Argentina/Tucuman', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(66, 'America/Argentina/Ushuaia', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(67, 'America/Aruba', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(68, 'America/Asuncion', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(69, 'America/Bahia', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(70, 'America/Barbados', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(71, 'America/Belem', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(72, 'America/Belize', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(73, 'America/Boa_Vista', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(74, 'America/Bogota', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(75, 'America/Boise', -7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(76, 'America/Cambridge_Bay', -7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(77, 'America/Campo_Grande', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(78, 'America/Cancun', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(79, 'America/Caracas', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(80, 'America/Cayenne', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(81, 'America/Cayman', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(82, 'America/Chicago', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(83, 'America/Chihuahua', -7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(84, 'America/Coral_Harbour', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(85, 'America/Costa_Rica', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(86, 'America/Cuiaba', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(87, 'America/Curacao', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(88, 'America/Danmarkshavn', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(89, 'America/Dawson', -8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(90, 'America/Dawson_Creek', -7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(91, 'America/Denver', -7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(92, 'America/Detroit', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(93, 'America/Dominica', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(94, 'America/Edmonton', -7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(95, 'America/Eirunepe', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(96, 'America/El_Salvador', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(97, 'America/Fortaleza', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(98, 'America/Glace_Bay', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(99, 'America/Godthab', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(100, 'America/Goose_Bay', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(101, 'America/Grand_Turk', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(102, 'America/Grenada', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(103, 'America/Guadeloupe', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(104, 'America/Guatemala', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(105, 'America/Guayaquil', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(106, 'America/Guyana', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(107, 'America/Halifax', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(108, 'America/Havana', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(109, 'America/Hermosillo', -7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(110, 'America/Indiana/Indianapolis', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(111, 'America/Indiana/Knox', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(112, 'America/Indiana/Marengo', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(113, 'America/Indiana/Vevay', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(114, 'America/Inuvik', -7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(115, 'America/Iqaluit', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(116, 'America/Jamaica', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(117, 'America/Juneau', -9);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(118, 'America/Kentucky/Louisville', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(119, 'America/Kentucky/Monticello', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(120, 'America/La_Paz', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(121, 'America/Lima', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(122, 'America/Los_Angeles', -8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(123, 'America/Maceio', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(124, 'America/Managua', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(125, 'America/Manaus', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(126, 'America/Martinique', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(127, 'America/Mazatlan', -7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(128, 'America/Menominee', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(129, 'America/Merida', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(130, 'America/Mexico_City', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(131, 'America/Miquelon', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(132, 'America/Monterrey', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(133, 'America/Montevideo', -2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(134, 'America/Montreal', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(135, 'America/Montserrat', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(136, 'America/Nassau', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(137, 'America/New_York', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(138, 'America/Nipigon', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(139, 'America/Nome', -9);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(140, 'America/Noronha', -2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(141, 'America/North_Dakota/Center', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(142, 'America/Panama', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(143, 'America/Pangnirtung', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(144, 'America/Paramaribo', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(145, 'America/Phoenix', -7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(146, 'America/Port-au-Prince', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(147, 'America/Port_of_Spain', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(148, 'America/Porto_Velho', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(149, 'America/Puerto_Rico', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(150, 'America/Rainy_River', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(151, 'America/Rankin_Inlet', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(152, 'America/Recife', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(153, 'America/Regina', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(154, 'America/Rio_Branco', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(155, 'America/Santiago', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(156, 'America/Santo_Domingo', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(157, 'America/Sao_Paulo', -2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(158, 'America/Scoresbysund', -1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(159, 'America/St_Johns', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(160, 'America/St_Kitts', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(161, 'America/St_Lucia', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(162, 'America/St_Thomas', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(163, 'America/St_Vincent', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(164, 'America/Swift_Current', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(165, 'America/Tegucigalpa', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(166, 'America/Thule', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(167, 'America/Thunder_Bay', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(168, 'America/Tijuana', -8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(169, 'America/Toronto', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(170, 'America/Tortola', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(171, 'America/Vancouver', -8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(172, 'America/Whitehorse', -8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(173, 'America/Winnipeg', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(174, 'America/Yakutat', -9);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(175, 'America/Yellowknife', -7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(176, 'Antarctica/Casey', 8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(177, 'Antarctica/Davis', 7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(178, 'Antarctica/DumontDUrville', 10);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(179, 'Antarctica/Mawson', 6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(180, 'Antarctica/McMurdo', 13);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(181, 'Antarctica/Palmer', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(182, 'Antarctica/Rothera', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(183, 'Antarctica/Syowa', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(184, 'Antarctica/Vostok', 6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(185, 'Asia/Aden', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(186, 'Asia/Almaty', 6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(187, 'Asia/Amman', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(188, 'Asia/Anadyr', 12);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(189, 'Asia/Aqtau', 5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(190, 'Asia/Aqtobe', 5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(191, 'Asia/Ashgabat', 5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(192, 'Asia/Baghdad', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(193, 'Asia/Bahrain', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(194, 'Asia/Baku', 4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(195, 'Asia/Bangkok', 7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(196, 'Asia/Beirut', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(197, 'Asia/Bishkek', 6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(198, 'Asia/Brunei', 8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(199, 'Asia/Calcutta', 5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(200, 'Asia/Choibalsan', 9);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(201, 'Asia/Chongqing', 8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(202, 'Asia/Colombo', 5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(203, 'Asia/Damascus', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(204, 'Asia/Dhaka', 6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(205, 'Asia/Dili', 9);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(206, 'Asia/Dubai', 4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(207, 'Asia/Dushanbe', 5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(208, 'Asia/Gaza', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(209, 'Asia/Harbin', 8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(210, 'Asia/Hong_Kong', 8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(211, 'Asia/Hovd', 7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(212, 'Asia/Irkutsk', 8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(213, 'Asia/Jakarta', 7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(214, 'Asia/Jayapura', 9);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(215, 'Asia/Jerusalem', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(216, 'Asia/Kabul', 4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(217, 'Asia/Kamchatka', 12);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(218, 'Asia/Karachi', 5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(219, 'Asia/Kashgar', 8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(220, 'Asia/Katmandu', 5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(221, 'Asia/Krasnoyarsk', 7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(222, 'Asia/Kuala_Lumpur', 8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(223, 'Asia/Kuching', 8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(224, 'Asia/Kuwait', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(225, 'Asia/Macau', 8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(226, 'Asia/Magadan', 11);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(227, 'Asia/Makassar', 8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(228, 'Asia/Manila', 8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(229, 'Asia/Muscat', 4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(230, 'Asia/Nicosia', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(231, 'Asia/Novosibirsk', 6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(232, 'Asia/Omsk', 6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(233, 'Asia/Oral', 5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(234, 'Asia/Phnom_Penh', 7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(235, 'Asia/Pontianak', 7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(236, 'Asia/Pyongyang', 9);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(237, 'Asia/Qatar', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(238, 'Asia/Qyzylorda', 6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(239, 'Asia/Rangoon', 6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(240, 'Asia/Riyadh', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(241, 'Asia/Saigon', 7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(242, 'Asia/Sakhalin', 10);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(243, 'Asia/Samarkand', 5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(244, 'Asia/Seoul', 9);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(245, 'Asia/Shanghai', 8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(246, 'Asia/Singapore', 8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(247, 'Asia/Taipei', 8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(248, 'Asia/Tashkent', 5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(249, 'Asia/Tbilisi', 4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(250, 'Asia/Tehran', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(251, 'Asia/Thimphu', 6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(252, 'Asia/Tokyo', 9);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(253, 'Asia/Ulaanbaatar', 8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(254, 'Asia/Urumqi', 8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(255, 'Asia/Vientiane', 7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(256, 'Asia/Vladivostok', 10);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(257, 'Asia/Yakutsk', 9);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(258, 'Asia/Yekaterinburg', 5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(259, 'Asia/Yerevan', 4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(260, 'Atlantic/Azores', -1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(261, 'Atlantic/Bermuda', -4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(262, 'Atlantic/Canary', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(263, 'Atlantic/Cape_Verde', -1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(264, 'Atlantic/Faeroe', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(265, 'Atlantic/Madeira', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(266, 'Atlantic/Reykjavik', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(267, 'Atlantic/South_Georgia', -2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(268, 'Atlantic/St_Helena', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(269, 'Atlantic/Stanley', -3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(270, 'Australia/Adelaide', 10);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(271, 'Australia/Brisbane', 10);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(272, 'Australia/Broken_Hill', 10);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(273, 'Australia/Currie', 11);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(274, 'Australia/Darwin', 9);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(275, 'Australia/Hobart', 11);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(276, 'Australia/Lindeman', 10);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(277, 'Australia/Lord_Howe', 11);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(278, 'Australia/Melbourne', 11);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(279, 'Australia/Perth', 8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(280, 'Australia/Sydney', 11);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(281, 'Europe/Amsterdam', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(282, 'Europe/Andorra', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(283, 'Europe/Athens', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(284, 'Europe/Belgrade', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(285, 'Europe/Berlin', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(286, 'Europe/Brussels', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(287, 'Europe/Bucharest', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(288, 'Europe/Budapest', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(289, 'Europe/Chisinau', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(290, 'Europe/Copenhagen', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(291, 'Europe/Dublin', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(292, 'Europe/Gibraltar', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(293, 'Europe/Helsinki', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(294, 'Europe/Istanbul', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(295, 'Europe/Kaliningrad', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(296, 'Europe/Kiev', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(297, 'Europe/Lisbon', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(298, 'Europe/London', 0);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(299, 'Europe/Luxembourg', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(300, 'Europe/Madrid', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(301, 'Europe/Malta', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(302, 'Europe/Minsk', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(303, 'Europe/Monaco', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(304, 'Europe/Moscow', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(305, 'Europe/Oslo', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(306, 'Europe/Paris', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(307, 'Europe/Prague', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(308, 'Europe/Riga', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(309, 'Europe/Rome', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(310, 'Europe/Samara', 4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(311, 'Europe/Simferopol', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(312, 'Europe/Sofia', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(313, 'Europe/Stockholm', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(314, 'Europe/Tallinn', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(315, 'Europe/Tirane', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(316, 'Europe/Uzhgorod', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(317, 'Europe/Vaduz', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(318, 'Europe/Vienna', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(319, 'Europe/Vilnius', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(320, 'Europe/Warsaw', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(321, 'Europe/Zaporozhye', 2);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(322, 'Europe/Zurich', 1);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(323, 'Indian/Antananarivo', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(324, 'Indian/Chagos', 6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(325, 'Indian/Christmas', 7);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(326, 'Indian/Cocos', 6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(327, 'Indian/Comoro', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(328, 'Indian/Kerguelen', 5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(329, 'Indian/Mahe', 4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(330, 'Indian/Maldives', 5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(331, 'Indian/Mauritius', 4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(332, 'Indian/Mayotte', 3);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(333, 'Indian/Reunion', 4);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(334, 'Pacific/Apia', -11);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(335, 'Pacific/Auckland', 13);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(336, 'Pacific/Chatham', 13);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(337, 'Pacific/Easter', -5);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(338, 'Pacific/Efate', 11);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(339, 'Pacific/Enderbury', 13);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(340, 'Pacific/Fakaofo', -10);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(341, 'Pacific/Fiji', 12);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(342, 'Pacific/Funafuti', 12);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(343, 'Pacific/Galapagos', -6);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(344, 'Pacific/Gambier', -9);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(345, 'Pacific/Guadalcanal', 11);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(346, 'Pacific/Guam', 10);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(347, 'Pacific/Honolulu', -10);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(348, 'Pacific/Johnston', -10);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(349, 'Pacific/Kiritimati', 14);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(350, 'Pacific/Kosrae', 11);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(351, 'Pacific/Kwajalein', 12);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(352, 'Pacific/Majuro', 12);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(353, 'Pacific/Marquesas', -9);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(354, 'Pacific/Midway', -11);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(355, 'Pacific/Nauru', 12);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(356, 'Pacific/Niue', -11);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(357, 'Pacific/Norfolk', 11);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(358, 'Pacific/Noumea', 11);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(359, 'Pacific/Pago_Pago', -11);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(360, 'Pacific/Palau', 9);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(361, 'Pacific/Pitcairn', -8);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(362, 'Pacific/Ponape', 11);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(363, 'Pacific/Port_Moresby', 10);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(364, 'Pacific/Rarotonga', -10);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(365, 'Pacific/Saipan', 10);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(366, 'Pacific/Tahiti', -10);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(367, 'Pacific/Tarawa', 12);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(368, 'Pacific/Tongatapu', 13);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(369, 'Pacific/Truk', 10);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(370, 'Pacific/Wake', 12);
INSERT INTO `timezones` (`id`, `timezone`, `time_diff`) VALUES(371, 'Pacific/Wallis', 12);

