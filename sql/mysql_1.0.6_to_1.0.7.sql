#
# 1.0.6 to 1.0.7
#
IF NOT EXISTS (SELECT  * FROM COLUMNS
WHERE TABLE_NAME='escalation_stati' AND column_name='hostgroups')
BEGIN
ALTER TABLE `escalation_stati` ADD `hostgroups` VARCHAR( 255 ) NOT NULL AFTER `hostgroups`
ALTER TABLE `escalation_stati` ADD `servicegroups` VARCHAR( 255 ) NOT NULL AFTER `service`
ALTER TABLE `tmp_commands` ADD `servicegroups` VARCHAR( 255 ) NOT NULL AFTER `service`
ALTER TABLE `notifications` ADD `servicegroups_include` VARCHAR( 255 ) NOT NULL AFTER `services_exclude`
ALTER TABLE `notifications` ADD `servicegroups_exclude` VARCHAR( 255 ) NOT NULL AFTER `servicegroups_include`
ALTER TABLE `notifications` ADD `hostgroups` VARCHAR( 255 ) NOT NULL AFTER `hosts_exclude`
ALTER TABLE `notifications` ADD `hostgroups` VARCHAR( 255 ) NOT NULL AFTER `hostgroups_include`
END

ALTER TABLE `tmp_commands` ADD `authors` varchar(255) NOT NULL AFTER `notification_type`
ALTER TABLE `tmp_commands` ADD `comments` varchar(255) NOT NULL AFTER `authors`
ALTER TABLE `escalation_stati` ADD `recipients` VARCHAR( 255 ) NOT NULL AFTER `incident_id`;
ALTER TABLE `tmp_commands` ADD `recipients` VARCHAR( 255 ) NOT NULL AFTER `external_id`;
ALTER TABLE `notifications` ADD `recipients_include` VARCHAR( 255 ) NOT NULL AFTER `username`;
ALTER TABLE `notifications` ADD `recipients_exclude` VARCHAR( 255 ) NOT NULL AFTER `recipients_include`;
ALTER TABLE `contacts` ADD `netaddress` VARCHAR( 255 ) NOT NULL AFTER `mobile`

ALTER TABLE `notifications` ADD `on_type_problem` TINYINT( 1 ) NOT NULL AFTER `on_host_down` ,
ADD `on_type_recovery` TINYINT( 1 ) NOT NULL AFTER `on_type_problem` ,
ADD `on_type_flappingstart` TINYINT( 1 ) NOT NULL AFTER `on_type_recovery` ,
ADD `on_type_flappingstop` TINYINT( 1 ) NOT NULL AFTER `on_type_flappingstart` ,
ADD `on_type_flappingdisabled` TINYINT( 1 ) NOT NULL AFTER `on_type_flappingstop` ,
ADD `on_type_downtimestart` TINYINT( 1 ) NOT NULL AFTER `on_type_flappingdisabled` ,
ADD `on_type_downtimeend` TINYINT( 1 ) NOT NULL AFTER `on_type_downtimestart` ,
ADD `on_type_downtimecancelled` TINYINT( 1 ) NOT NULL AFTER `on_type_downtimeend` ,
ADD `on_type_acknowledgement` TINYINT( 1 ) NOT NULL AFTER `on_type_downtimecancelled` ,
ADD `on_type_custom` TINYINT( 1 ) NOT NULL AFTER `on_type_acknowledgement`;

ALTER TABLE `escalations_contacts` ADD `on_type_problem` TINYINT( 1 ) NOT NULL AFTER `on_host_down` ,
ADD `on_type_recovery` TINYINT( 1 ) NOT NULL AFTER `on_type_problem` ,
ADD `on_type_flappingstart` TINYINT( 1 ) NOT NULL AFTER `on_type_recovery` ,
ADD `on_type_flappingstop` TINYINT( 1 ) NOT NULL AFTER `on_type_flappingstart` ,
ADD `on_type_flappingdisabled` TINYINT( 1 ) NOT NULL AFTER `on_type_flappingstop` ,
ADD `on_type_downtimestart` TINYINT( 1 ) NOT NULL AFTER `on_type_flappingdisabled` ,
ADD `on_type_downtimeend` TINYINT( 1 ) NOT NULL AFTER `on_type_downtimestart` ,
ADD `on_type_downtimecancelled` TINYINT( 1 ) NOT NULL AFTER `on_type_downtimeend` ,
ADD `on_type_acknowledgement` TINYINT( 1 ) NOT NULL AFTER `on_type_downtimecancelled`,
ADD `on_type_custom` TINYINT( 1 ) NOT NULL AFTER `on_type_acknowledgement`;

INSERT INTO `notification_methods` (`id`, `method`, `command`, `contact_field`, `from`, `on_fail`, `ack_able`) VALUES (NULL, 'Growl', 'growl', 'netaddress', '', '0', '0');

CREATE INDEX external_id ON tmp_commands (external_id);
CREATE INDEX unique_id ON notification_logs (unique_id);
CREATE INDEX notify_id ON tmp_active (notify_id);
CREATE INDEX incident_id ON escalation_stati (incident_id);

CREATE INDEX contactgroup_id ON contactgroups_to_contacts (contactgroup_id);
CREATE INDEX contact_id ON contactgroups_to_contacts (contact_id);

CREATE INDEX escalation_contacts_id ON escalations_contacts_to_contacts (escalation_contacts_id);
CREATE INDEX contactgroup_id ON escalations_contacts_to_contactgroups (contactgroup_id);
CREATE INDEX escalation_contacts_id ON escalations_contacts_to_contacts (escalation_contacts_id);
CREATE INDEX contacts_id ON escalations_contacts_to_contacts (contacts_id);
CREATE INDEX escalation_contacts_id ON escalations_contacts_to_methods (escalation_contacts_id);
CREATE INDEX method_id ON escalations_contacts_to_methods (method_id);

CREATE INDEX notification_id ON notifications_to_contacts (notification_id);
CREATE INDEX contactgroup_id ON notifications_to_contactgroups (contactgroup_id);
CREATE INDEX notification_id ON notifications_to_contacts (notification_id);
CREATE INDEX contact_id ON notifications_to_contacts (contact_id);
CREATE INDEX notification_id ON notifications_to_methods (notification_id);
CREATE INDEX method_id ON notifications_to_methods (method_id);

CREATE TABLE IF NOT EXISTS `timeframes` (
  `id` tinyint(3) NOT NULL,
  `dt_validFrom` datetime NOT NULL,
  `dt_validTo` datetime DEFAULT NULL,
  `timezone_id` int(3) NOT NULL,
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
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

INSERT INTO `timeframes` (`id`, `dt_validFrom`, `dt_validTo`, `timezone_id`, `day_monday_all`, `day_monday_1st`, `day_monday_2nd`, `day_monday_3rd`, `day_monday_4th`, `day_monday_5th`, `day_monday_last`, `day_tuesday_all`, `day_tuesday_1st`, `day_tuesday_2nd`, `day_tuesday_3rd`, `day_tuesday_4th`, `day_tuesday_5th`, `day_tuesday_last`, `day_wednesday_all`, `day_wednesday_1st`, `day_wednesday_2nd`, `day_wednesday_3rd`, `day_wednesday_4th`, `day_wednesday_5th`, `day_wednesday_last`, `day_thursday_all`, `day_thursday_1st`, `day_thursday_2nd`, `day_thursday_3rd`, `day_thursday_4th`, `day_thursday_5th`, `day_thursday_last`, `day_friday_all`, `day_friday_1st`, `day_friday_2nd`, `day_friday_3rd`, `day_friday_4th`, `day_friday_5th`, `day_friday_last`, `day_saturday_all`, `day_saturday_1st`, `day_saturday_2nd`, `day_saturday_3rd`, `day_saturday_4th`, `day_saturday_5th`, `day_saturday_last`, `day_sunday_all`, `day_sunday_1st`, `day_sunday_2nd`, `day_sunday_3rd`, `day_sunday_4th`, `day_sunday_5th`, `day_sunday_last`, `time_monday_start`, `time_monday_stop`, `time_monday_invert`, `time_tuesday_start`, `time_tuesday_stop`, `time_tuesday_invert`, `time_wednesday_start`, `time_wednesday_stop`, `time_wednesday_invert`, `time_thursday_start`, `time_thursday_stop`, `time_thursday_invert`, `time_friday_start`, `time_friday_stop`, `time_friday_invert`, `time_saturday_start`, `time_saturday_stop`, `time_saturday_invert`, `time_sunday_start`, `time_sunday_stop`, `time_sunday_invert`) VALUES
(1, '2011-07-31 11:29:00', '2020-12-31 23:59:30', 305, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, '00:00:00', '23:59:59', 0, '00:00:00', '23:59:59', 0, '00:00:00', '23:59:59', 0, '00:00:00', '23:59:59', 0, '00:00:00', '23:59:59', 0, '00:00:00', '23:59:59', 0, '00:00:00', '23:59:59', 0);

CREATE TABLE IF NOT EXISTS `timeframes_to_contactgroups` (
  `timeframe_id` int(11) NOT NULL,
  `contactgroup_id` int(11) NOT NULL,
  PRIMARY KEY (`timeframe_id`),
  KEY `contactgroup_id` (`contactgroup_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `timeframes_to_contacts` (
  `timeframe_id` int(11) NOT NULL,
  `contact_id` int(11) NOT NULL,
  PRIMARY KEY (`timeframe_id`),
  KEY `contact_id` (`contact_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `timeframes_to_notifications` (
  `timeframe_id` int(11) NOT NULL,
  `notification_id` int(11) NOT NULL,
  PRIMARY KEY (`timeframe_id`),
  KEY `notification_id` (`notification_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


# IF not hotfixed for hostgroups after upgrade to 1.0.6, run this to be sure! (If it already exists, it wont finish!)
ALTER TABLE `tmp_commands` ADD `hostgroups` VARCHAR( 255 ) NOT NULL AFTER `hostgroups`

