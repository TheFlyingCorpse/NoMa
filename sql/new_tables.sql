
DROP TABLE IF EXISTS `tmp_commands`;
CREATE TABLE `tmp_commands` (
  `id` int(11) NOT NULL auto_increment,
  `operation` varchar(255) default NULL,
  `external_id` bigint(20) NOT NULL,
  `host` varchar(255) default NULL,
  `host_alias` varchar(255) default NULL,
  `host_address` varchar(255) default NULL,
  `service` varchar(255) default NULL,
  `check_type` varchar(255) default NULL,
  `status` varchar(255) default NULL,
  `stime` int(11) default 0,
  `notification_type` varchar(255) default NULL,
  `output` varchar(4096) default NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `tmp_active`;
CREATE TABLE `tmp_active` (
  `id` int(11) NOT NULL auto_increment,
  `notify_id` bigint(20) NOT NULL,
  `command_id` int(11) default NULL,
  `dest` varchar(255) default NULL,
  `from_user` varchar(255) default NULL,
  `time_string` varchar(255) default NULL,
  `user` varchar(255) default NULL,
  `method` varchar(255) default NULL,
  `notify_cmd` varchar(255) default NULL,
  `retries` int(11) default 0,
  `rule` int(11) default 0,
  `progress` tinyint(1) default 0,
  `esc_flag` tinyint(1) default 0,
  `bundled` int(11) default 0,
  `stime` int(11) default 0,
  UNIQUE KEY `id` (`id`),
  FOREIGN KEY `command_id` (`command_id`) REFERENCES `tmp_commands`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

alter table notifications add column rollover tinyint(1) default 0 after let_notifier_handle;
