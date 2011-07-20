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

CREATE TABLE IF NOT EXISTS `time_frames` (
  `id` tinyint(11) NOT NULL,
  `notification_id` int(11) NOT NULL,
  `validFrom` datetime DEFAULT NULL,
  `validTo` datetime DEFAULT NULL,
  `day_monday` int(3) DEFAULT NULL,
  `day_tuesday` int(3) DEFAULT NULL,
  `day_wednesday` int(3) DEFAULT NULL,
  `day_thursday` int(3) DEFAULT NULL,
  `day_friday` int(3) DEFAULT NULL,
  `day_saturday` int(3) DEFAULT NULL,
  `day_sunday` int(3) DEFAULT NULL,
  `time_monday_start` time DEFAULT NULL,
  `time_monday_stop` time DEFAULT NULL,
  `time_monday_invert` tinyint(1) DEFAULT NULL,
  `time_tuesday_start` time DEFAULT NULL,
  `time_tuesday_stop` time DEFAULT NULL,
  `time_tuesday_invert` tinyint(1) DEFAULT NULL,
  `time_wednesday_start` time DEFAULT NULL,
  `time_wednesday_stop` time DEFAULT NULL,
  `time_wednesday_invert` tinyint(1) DEFAULT NULL,
  `time_thursday_start` time DEFAULT NULL,
  `time_thursday_stop` time DEFAULT NULL,
  `time_thursday_invert` tinyint(1) DEFAULT NULL,
  `time_friday_start` time DEFAULT NULL,
  `time_friday_stop` time DEFAULT NULL,
  `time_friday_invert` tinyint(1) DEFAULT NULL,
  `time_saturday_start` time DEFAULT NULL,
  `time_saturday_stop` time DEFAULT NULL,
  `time_saturday_invert` tinyint(1) DEFAULT NULL,
  `time_sunday_start` time DEFAULT NULL,
  `time_sunday_stop` time DEFAULT NULL,
  `time_sunday_invert` tinyint(1) DEFAULT NULL,
  UNIQUE KEY `notification_id` (`notification_id`),
  KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

# IF not hotfixed for hostgroups after upgrade to 1.0.6, run this to be sure! (If it already exists, it wont finish!)
ALTER TABLE `tmp_commands` ADD `hostgroups` VARCHAR( 255 ) NOT NULL AFTER `hostgroups`

