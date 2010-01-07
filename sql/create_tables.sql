

DROP TABLE IF EXISTS `contactgroups`;
CREATE TABLE `contactgroups` (
  `id` int(11) NOT NULL auto_increment,
  `name_short` varchar(255) character set latin1 NOT NULL,
  `name` varchar(255) character set latin1 NOT NULL,
  `view_only` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `name_short` (`name_short`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


INSERT INTO `contactgroups` VALUES (1,'group1','Group 1',0);


DROP TABLE IF EXISTS `contactgroups_to_contacts`;
CREATE TABLE `contactgroups_to_contacts` (
  `contactgroup_id` int(11) NOT NULL,
  `contact_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `contactgroups_to_contacts` VALUES
(1,2);


DROP TABLE IF EXISTS `contacts`;
CREATE TABLE `contacts` (
  `id` int(11) NOT NULL auto_increment,
  `admin` tinyint(1) NOT NULL,
  `username` varchar(255) character set latin1 NOT NULL,
  `first_name` varchar(255) character set latin1 NOT NULL,
  `last_name` varchar(255) character set latin1 NOT NULL,
  `email` varchar(255) character set latin1 NOT NULL,
  `phone` varchar(255) character set latin1 NOT NULL,
  `mobile` varchar(255) character set latin1 NOT NULL,
  `section` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `time_period_id` int(11) NOT NULL,
  `timezone_id` int(11) NOT NULL,
  `restrict_alerts` tinyint(1) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


INSERT INTO `contacts` VALUES 
(1,0,'[---]','','','','','','','',0,0,NULL),
(2,1,'nagiosadmin','Nagios','Administrator','admin@localhost','','','','fe2d0a7a5b34951b6ec3c46184f1ed3eae19459d',1,285,NULL);


DROP TABLE IF EXISTS `escalations_contacts`;
CREATE TABLE `escalations_contacts` (
  `id` int(11) NOT NULL auto_increment,
  `notification_id` int(11) NOT NULL,
  `on_ok` tinyint(1) NOT NULL,
  `on_warning` tinyint(1) NOT NULL,
  `on_critical` tinyint(1) NOT NULL,
  `on_unknown` tinyint(1) NOT NULL,
  `on_host_up` tinyint(1) NOT NULL,
  `on_host_unreachable` tinyint(1) NOT NULL,
  `on_host_down` tinyint(1) NOT NULL,
  `notify_after_tries` varchar(255) character set latin1 NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `escalations_contacts_to_contactgroups`;
CREATE TABLE `escalations_contacts_to_contactgroups` (
  `escalation_contacts_id` int(11) NOT NULL,
  `contactgroup_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `escalations_contacts_to_contacts`;
CREATE TABLE `escalations_contacts_to_contacts` (
  `escalation_contacts_id` int(11) NOT NULL,
  `contacts_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `escalations_contacts_to_methods`;
CREATE TABLE `escalations_contacts_to_methods` (
  `escalation_contacts_id` int(11) NOT NULL,
  `method_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `holidays`;
CREATE TABLE `holidays` (
  `id` int(11) NOT NULL auto_increment,
  `contact_id` int(11) NOT NULL,
  `start` datetime NOT NULL,
  `end` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `notification_logs`;
CREATE TABLE `notification_logs` (
  `id` int(11) NOT NULL auto_increment,
  `timestamp` datetime NOT NULL,
  `counter` int(11) NOT NULL,
  `check_type` varchar(10) character set latin1 NOT NULL,
  `check_result` varchar(15) character set latin1 NOT NULL,
  `host` varchar(255) character set latin1 NOT NULL,
  `service` varchar(255) character set latin1 NOT NULL,
  `method` varchar(255) NOT NULL,
  `user` varchar(255) character set latin1 NOT NULL,
  `result` varchar(255) NOT NULL,
  `unique_id` bigint(20) default NULL,
  `incident_id` bigint(20) default NULL,
  `notification_rule` int(11) default NULL,
  `last_method` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


INSERT INTO `notification_logs` VALUES
(1,now(),1,'(internal)','OK','localhost','NoMa','(none)','(none)','NoMa successfully installed',123565999600001,123565999600001,0,1);


DROP TABLE IF EXISTS `notification_methods`;
CREATE TABLE `notification_methods` (
  `id` int(11) NOT NULL auto_increment,
  `method` varchar(255) NOT NULL,
  `command` varchar(255) NOT NULL,
  `contact_field` varchar(255) NOT NULL,
  `from` varchar(255) NOT NULL,
  `on_fail` int(11) NOT NULL,
  `ack_able` tinyint(1) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


INSERT INTO `notification_methods` VALUES 
(1,'E-Mail','sendemail','email','noma@netways.de',0,0),
(2,'SMS','sendsms','mobile','',0,0),
(3,'Voice','voicecall','phone','',0,0),
(4,'Voice + E-Mail fallback','voicecall','phone','',1,0),
(5,'Voice + SMS fallback','voicecall','phone','',2,0);


DROP TABLE IF EXISTS `notification_stati`;
CREATE TABLE `notification_stati` (
  `host` varchar(255) character set latin1 NOT NULL,
  `service` varchar(255) character set latin1 NOT NULL,
  `check_type` varchar(10) character set latin1 NOT NULL,
  `check_result` varchar(15) character set latin1 NOT NULL,
  `counter` int(11) NOT NULL,
  `pid` int(11) NOT NULL default '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
  `id` int(11) NOT NULL auto_increment,
  `active` tinyint(1) NOT NULL,
  `username` varchar(255) character set latin1 NOT NULL,
  `hosts_include` varchar(255) character set latin1 NOT NULL,
  `hosts_exclude` varchar(255) character set latin1 NOT NULL,
  `services_include` varchar(255) character set latin1 NOT NULL,
  `services_exclude` varchar(255) character set latin1 NOT NULL,
  `notify_after_tries` varchar(10) character set latin1 NOT NULL default '0',
  `let_notifier_handle` tinyint(1) NOT NULL,
  `reloop_delay` int(11) NOT NULL default '0',
  `on_ok` tinyint(1) NOT NULL,
  `on_warning` tinyint(1) NOT NULL,
  `on_unknown` tinyint(1) NOT NULL,
  `on_host_unreachable` tinyint(1) NOT NULL,
  `on_critical` tinyint(1) NOT NULL,
  `on_host_up` tinyint(1) NOT NULL,
  `on_host_down` tinyint(1) NOT NULL,
  `timezone_id` int(11) NOT NULL default 372,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


INSERT INTO `notifications` VALUES (1,1,'nagiosadmin','*','','*','','1',0,0,1,1,1,1,1,1,1,285);


DROP TABLE IF EXISTS `notifications_to_contactgroups`;
CREATE TABLE `notifications_to_contactgroups` (
  `notification_id` int(11) NOT NULL,
  `contactgroup_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `notifications_to_contacts`;
CREATE TABLE `notifications_to_contacts` (
  `notification_id` int(11) NOT NULL,
  `contact_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


INSERT INTO `notifications_to_contacts` VALUES (1,2);


DROP TABLE IF EXISTS `notifications_to_methods`;
CREATE TABLE `notifications_to_methods` (
  `notification_id` int(11) NOT NULL,
  `method_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


INSERT INTO `notifications_to_methods` VALUES (1,1);

DROP TABLE IF EXISTS `time_periods`;
CREATE TABLE `time_periods` (
	  `id` int(10) unsigned NOT NULL auto_increment,
	  `description` varchar(255) NOT NULL,
	  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


INSERT INTO `time_periods` VALUES 
(1,'24x7'),
(2,'\"normal\" working hours'),
(3,'out of hours');


DROP TABLE IF EXISTS `time_slices`;
CREATE TABLE `time_slices` (
	  `id` int(10) unsigned NOT NULL auto_increment,
	  `time_period_id` int(10) unsigned NOT NULL,
	  `days` tinyint(4) NOT NULL default '127',
	  `starttime` time NOT NULL default '00:00:00',
	  `endtime` time NOT NULL default '24:00:00',
	  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


INSERT INTO `time_slices` VALUES 
(1,1,127,'00:00:00','24:00:00'),
(2,2,62,'08:00:00','18:00:00'),
(3,3,65,'00:00:00','24:00:00'),
(4,3,62,'00:00:00','08:00:00'),
(5,3,62,'18:00:00','24:00:00');


DROP TABLE IF EXISTS `timezones`;
CREATE TABLE `timezones` (
  `id` int(11) NOT NULL,
  `timezone` varchar(255) character set latin1 NOT NULL,
  `time_diff` tinyint(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


INSERT INTO `timezones` VALUES
(1,'Africa/Abidjan',0),
(2,'Africa/Accra',0),
(3,'Africa/Addis_Ababa',3),
(4,'Africa/Algiers',1),
(5,'Africa/Asmera',3),
(6,'Africa/Bamako',0),
(7,'Africa/Bangui',1),
(8,'Africa/Banjul',0),
(9,'Africa/Bissau',0),
(10,'Africa/Blantyre',2),
(11,'Africa/Brazzaville',1),
(12,'Africa/Bujumbura',2),
(13,'Africa/Cairo',2),
(14,'Africa/Casablanca',0),
(15,'Africa/Ceuta',1),
(16,'Africa/Conakry',0),
(17,'Africa/Dakar',0),
(18,'Africa/Dar_es_Salaam',3),
(19,'Africa/Djibouti',3),
(20,'Africa/Douala',1),
(21,'Africa/El_Aaiun',0),
(22,'Africa/Freetown',0),
(23,'Africa/Gaborone',2),
(24,'Africa/Harare',2),
(25,'Africa/Johannesburg',2),
(26,'Africa/Kampala',3),
(27,'Africa/Khartoum',3),
(28,'Africa/Kigali',2),
(29,'Africa/Kinshasa',1),
(30,'Africa/Lagos',1),
(31,'Africa/Libreville',1),
(32,'Africa/Lome',0),
(33,'Africa/Luanda',1),
(34,'Africa/Lubumbashi',2),
(35,'Africa/Lusaka',2),
(36,'Africa/Malabo',1),
(37,'Africa/Maputo',2),
(38,'Africa/Maseru',2),
(39,'Africa/Mbabane',2),
(40,'Africa/Mogadishu',3),
(41,'Africa/Monrovia',0),
(42,'Africa/Nairobi',3),
(43,'Africa/Ndjamena',1),
(44,'Africa/Niamey',1),
(45,'Africa/Nouakchott',0),
(46,'Africa/Ouagadougou',0),
(47,'Africa/Porto-Novo',1),
(48,'Africa/Sao_Tome',0),
(49,'Africa/Tripoli',2),
(50,'Africa/Tunis',1),
(51,'Africa/Windhoek',2),
(52,'America/Adak',-10),
(53,'America/Anchorage',-9),
(54,'America/Anguilla',-4),
(55,'America/Antigua',-4),
(56,'America/Araguaina',-3),
(57,'America/Argentina/Buenos_Aires',-3),
(58,'America/Argentina/Catamarca',-3),
(59,'America/Argentina/Cordoba',-3),
(60,'America/Argentina/Jujuy',-3),
(61,'America/Argentina/La_Rioja',-3),
(62,'America/Argentina/Mendoza',-3),
(63,'America/Argentina/Rio_Gallegos',-3),
(64,'America/Argentina/San_Juan',-3),
(65,'America/Argentina/Tucuman',-3),
(66,'America/Argentina/Ushuaia',-3),
(67,'America/Aruba',-4),
(68,'America/Asuncion',-3),
(69,'America/Bahia',-3),
(70,'America/Barbados',-4),
(71,'America/Belem',-3),
(72,'America/Belize',-6),
(73,'America/Boa_Vista',-4),
(74,'America/Bogota',-5),
(75,'America/Boise',-7),
(76,'America/Cambridge_Bay',-7),
(77,'America/Campo_Grande',-3),
(78,'America/Cancun',-6),
(79,'America/Caracas',-4),
(80,'America/Cayenne',-3),
(81,'America/Cayman',-5),
(82,'America/Chicago',-6),
(83,'America/Chihuahua',-7),
(84,'America/Coral_Harbour',-5),
(85,'America/Costa_Rica',-6),
(86,'America/Cuiaba',-3),
(87,'America/Curacao',-4),
(88,'America/Danmarkshavn',0),
(89,'America/Dawson',-8),
(90,'America/Dawson_Creek',-7),
(91,'America/Denver',-7),
(92,'America/Detroit',-5),
(93,'America/Dominica',-4),
(94,'America/Edmonton',-7),
(95,'America/Eirunepe',-5),
(96,'America/El_Salvador',-6),
(97,'America/Fortaleza',-3),
(98,'America/Glace_Bay',-4),
(99,'America/Godthab',-3),
(100,'America/Goose_Bay',-4),
(101,'America/Grand_Turk',-5),
(102,'America/Grenada',-4),
(103,'America/Guadeloupe',-4),
(104,'America/Guatemala',-6),
(105,'America/Guayaquil',-5),
(106,'America/Guyana',-4),
(107,'America/Halifax',-4),
(108,'America/Havana',-5),
(109,'America/Hermosillo',-7),
(110,'America/Indiana/Indianapolis',-5),
(111,'America/Indiana/Knox',-6),
(112,'America/Indiana/Marengo',-5),
(113,'America/Indiana/Vevay',-5),
(114,'America/Inuvik',-7),
(115,'America/Iqaluit',-5),
(116,'America/Jamaica',-5),
(117,'America/Juneau',-9),
(118,'America/Kentucky/Louisville',-5),
(119,'America/Kentucky/Monticello',-5),
(120,'America/La_Paz',-4),
(121,'America/Lima',-5),
(122,'America/Los_Angeles',-8),
(123,'America/Maceio',-3),
(124,'America/Managua',-6),
(125,'America/Manaus',-4),
(126,'America/Martinique',-4),
(127,'America/Mazatlan',-7),
(128,'America/Menominee',-6),
(129,'America/Merida',-6),
(130,'America/Mexico_City',-6),
(131,'America/Miquelon',-3),
(132,'America/Monterrey',-6),
(133,'America/Montevideo',-2),
(134,'America/Montreal',-5),
(135,'America/Montserrat',-4),
(136,'America/Nassau',-5),
(137,'America/New_York',-5),
(138,'America/Nipigon',-5),
(139,'America/Nome',-9),
(140,'America/Noronha',-2),
(141,'America/North_Dakota/Center',-6),
(142,'America/Panama',-5),
(143,'America/Pangnirtung',-5),
(144,'America/Paramaribo',-3),
(145,'America/Phoenix',-7),
(146,'America/Port-au-Prince',-5),
(147,'America/Port_of_Spain',-4),
(148,'America/Porto_Velho',-4),
(149,'America/Puerto_Rico',-4),
(150,'America/Rainy_River',-6),
(151,'America/Rankin_Inlet',-6),
(152,'America/Recife',-3),
(153,'America/Regina',-6),
(154,'America/Rio_Branco',-5),
(155,'America/Santiago',-3),
(156,'America/Santo_Domingo',-4),
(157,'America/Sao_Paulo',-2),
(158,'America/Scoresbysund',-1),
(159,'America/St_Johns',-3),
(160,'America/St_Kitts',-4),
(161,'America/St_Lucia',-4),
(162,'America/St_Thomas',-4),
(163,'America/St_Vincent',-4),
(164,'America/Swift_Current',-6),
(165,'America/Tegucigalpa',-6),
(166,'America/Thule',-4),
(167,'America/Thunder_Bay',-5),
(168,'America/Tijuana',-8),
(169,'America/Toronto',-5),
(170,'America/Tortola',-4),
(171,'America/Vancouver',-8),
(172,'America/Whitehorse',-8),
(173,'America/Winnipeg',-6),
(174,'America/Yakutat',-9),
(175,'America/Yellowknife',-7),
(176,'Antarctica/Casey',8),
(177,'Antarctica/Davis',7),
(178,'Antarctica/DumontDUrville',10),
(179,'Antarctica/Mawson',6),
(180,'Antarctica/McMurdo',13),
(181,'Antarctica/Palmer',-3),
(182,'Antarctica/Rothera',-3),
(183,'Antarctica/Syowa',3),
(184,'Antarctica/Vostok',6),
(185,'Asia/Aden',3),
(186,'Asia/Almaty',6),
(187,'Asia/Amman',2),
(188,'Asia/Anadyr',12),
(189,'Asia/Aqtau',5),
(190,'Asia/Aqtobe',5),
(191,'Asia/Ashgabat',5),
(192,'Asia/Baghdad',3),
(193,'Asia/Bahrain',3),
(194,'Asia/Baku',4),
(195,'Asia/Bangkok',7),
(196,'Asia/Beirut',2),
(197,'Asia/Bishkek',6),
(198,'Asia/Brunei',8),
(199,'Asia/Calcutta',5),
(200,'Asia/Choibalsan',9),
(201,'Asia/Chongqing',8),
(202,'Asia/Colombo',5),
(203,'Asia/Damascus',2),
(204,'Asia/Dhaka',6),
(205,'Asia/Dili',9),
(206,'Asia/Dubai',4),
(207,'Asia/Dushanbe',5),
(208,'Asia/Gaza',2),
(209,'Asia/Harbin',8),
(210,'Asia/Hong_Kong',8),
(211,'Asia/Hovd',7),
(212,'Asia/Irkutsk',8),
(213,'Asia/Jakarta',7),
(214,'Asia/Jayapura',9),
(215,'Asia/Jerusalem',2),
(216,'Asia/Kabul',4),
(217,'Asia/Kamchatka',12),
(218,'Asia/Karachi',5),
(219,'Asia/Kashgar',8),
(220,'Asia/Katmandu',5),
(221,'Asia/Krasnoyarsk',7),
(222,'Asia/Kuala_Lumpur',8),
(223,'Asia/Kuching',8),
(224,'Asia/Kuwait',3),
(225,'Asia/Macau',8),
(226,'Asia/Magadan',11),
(227,'Asia/Makassar',8),
(228,'Asia/Manila',8),
(229,'Asia/Muscat',4),
(230,'Asia/Nicosia',2),
(231,'Asia/Novosibirsk',6),
(232,'Asia/Omsk',6),
(233,'Asia/Oral',5),
(234,'Asia/Phnom_Penh',7),
(235,'Asia/Pontianak',7),
(236,'Asia/Pyongyang',9),
(237,'Asia/Qatar',3),
(238,'Asia/Qyzylorda',6),
(239,'Asia/Rangoon',6),
(240,'Asia/Riyadh',3),
(241,'Asia/Saigon',7),
(242,'Asia/Sakhalin',10),
(243,'Asia/Samarkand',5),
(244,'Asia/Seoul',9),
(245,'Asia/Shanghai',8),
(246,'Asia/Singapore',8),
(247,'Asia/Taipei',8),
(248,'Asia/Tashkent',5),
(249,'Asia/Tbilisi',4),
(250,'Asia/Tehran',3),
(251,'Asia/Thimphu',6),
(252,'Asia/Tokyo',9),
(253,'Asia/Ulaanbaatar',8),
(254,'Asia/Urumqi',8),
(255,'Asia/Vientiane',7),
(256,'Asia/Vladivostok',10),
(257,'Asia/Yakutsk',9),
(258,'Asia/Yekaterinburg',5),
(259,'Asia/Yerevan',4),
(260,'Atlantic/Azores',-1),
(261,'Atlantic/Bermuda',-4),
(262,'Atlantic/Canary',0),
(263,'Atlantic/Cape_Verde',-1),
(264,'Atlantic/Faeroe',0),
(265,'Atlantic/Madeira',0),
(266,'Atlantic/Reykjavik',0),
(267,'Atlantic/South_Georgia',-2),
(268,'Atlantic/St_Helena',0),
(269,'Atlantic/Stanley',-3),
(270,'Australia/Adelaide',10),
(271,'Australia/Brisbane',10),
(272,'Australia/Broken_Hill',10),
(273,'Australia/Currie',11),
(274,'Australia/Darwin',9),
(275,'Australia/Hobart',11),
(276,'Australia/Lindeman',10),
(277,'Australia/Lord_Howe',11),
(278,'Australia/Melbourne',11),
(279,'Australia/Perth',8),
(280,'Australia/Sydney',11),
(281,'Europe/Amsterdam',1),
(282,'Europe/Andorra',1),
(283,'Europe/Athens',2),
(284,'Europe/Belgrade',1),
(285,'Europe/Berlin',1),
(286,'Europe/Brussels',1),
(287,'Europe/Bucharest',2),
(288,'Europe/Budapest',1),
(289,'Europe/Chisinau',2),
(290,'Europe/Copenhagen',1),
(291,'Europe/Dublin',0),
(292,'Europe/Gibraltar',1),
(293,'Europe/Helsinki',2),
(294,'Europe/Istanbul',2),
(295,'Europe/Kaliningrad',2),
(296,'Europe/Kiev',2),
(297,'Europe/Lisbon',0),
(298,'Europe/London',0),
(299,'Europe/Luxembourg',1),
(300,'Europe/Madrid',1),
(301,'Europe/Malta',1),
(302,'Europe/Minsk',2),
(303,'Europe/Monaco',1),
(304,'Europe/Moscow',3),
(305,'Europe/Oslo',1),
(306,'Europe/Paris',1),
(307,'Europe/Prague',1),
(308,'Europe/Riga',2),
(309,'Europe/Rome',1),
(310,'Europe/Samara',4),
(311,'Europe/Simferopol',2),
(312,'Europe/Sofia',2),
(313,'Europe/Stockholm',1),
(314,'Europe/Tallinn',2),
(315,'Europe/Tirane',1),
(316,'Europe/Uzhgorod',2),
(317,'Europe/Vaduz',1),
(318,'Europe/Vienna',1),
(319,'Europe/Vilnius',2),
(320,'Europe/Warsaw',1),
(321,'Europe/Zaporozhye',2),
(322,'Europe/Zurich',1),
(323,'Indian/Antananarivo',3),
(324,'Indian/Chagos',6),
(325,'Indian/Christmas',7),
(326,'Indian/Cocos',6),
(327,'Indian/Comoro',3),
(328,'Indian/Kerguelen',5),
(329,'Indian/Mahe',4),
(330,'Indian/Maldives',5),
(331,'Indian/Mauritius',4),
(332,'Indian/Mayotte',3),
(333,'Indian/Reunion',4),
(334,'Pacific/Apia',-11),
(335,'Pacific/Auckland',13),
(336,'Pacific/Chatham',13),
(337,'Pacific/Easter',-5),
(338,'Pacific/Efate',11),
(339,'Pacific/Enderbury',13),
(340,'Pacific/Fakaofo',-10),
(341,'Pacific/Fiji',12),
(342,'Pacific/Funafuti',12),
(343,'Pacific/Galapagos',-6),
(344,'Pacific/Gambier',-9),
(345,'Pacific/Guadalcanal',11),
(346,'Pacific/Guam',10),
(347,'Pacific/Honolulu',-10),
(348,'Pacific/Johnston',-10),
(349,'Pacific/Kiritimati',14),
(350,'Pacific/Kosrae',11),
(351,'Pacific/Kwajalein',12),
(352,'Pacific/Majuro',12),
(353,'Pacific/Marquesas',-9),
(354,'Pacific/Midway',-11),
(355,'Pacific/Nauru',12),
(356,'Pacific/Niue',-11),
(357,'Pacific/Norfolk',11),
(358,'Pacific/Noumea',11),
(359,'Pacific/Pago_Pago',-11),
(360,'Pacific/Palau',9),
(361,'Pacific/Pitcairn',-8),
(362,'Pacific/Ponape',11),
(363,'Pacific/Port_Moresby',10),
(364,'Pacific/Rarotonga',-10),
(365,'Pacific/Saipan',10),
(366,'Pacific/Tahiti',-10),
(367,'Pacific/Tarawa',12),
(368,'Pacific/Tongatapu',13),
(369,'Pacific/Truk',10),
(370,'Pacific/Wake',12),
(371,'Pacific/Wallis',12),
(372,'GMT',0);


DROP TABLE IF EXISTS `tmp_active`;
CREATE TABLE `tmp_active` (
  `id` int(11) NOT NULL auto_increment,
  `start` datetime NOT NULL,
  `notify_id` bigint(20) NOT NULL,
  `command` varchar(255) default NULL,
  `dest` varchar(255) default NULL,
  `from_user` varchar(255) default NULL,
  `check_type` varchar(255) default NULL,
  `status` varchar(255) default NULL,
  `type` varchar(255) default NULL,
  `host` varchar(255) default NULL,
  `host_alias` varchar(255) default NULL,
  `host_address` varchar(255) default NULL,
  `service` varchar(255) default NULL,
  `time_string` varchar(255) default NULL,
  `output` varchar(4096) default NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=MEMORY DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `escalation_stati`;
CREATE TABLE `escalation_stati` (
  `id` int(11) NOT NULL auto_increment,
  `notification_rule` int(11) default NULL,
  `starttime` int(11) NOT NULL,
  `counter` int(11) NOT NULL,
  /* the following fields directly map to the original command */
  `incident_id` bigint(20) not NULL,
  `host` varchar(255) character set latin1 NOT NULL,
  `host_alias` varchar(255) default NULL,
  `host_address` varchar(255) default NULL,
  `service` varchar(255) character set latin1 NOT NULL,
  `check_type` varchar(255) default NULL,
  `status` varchar(255) default NULL,
  `time_string` varchar(255) default NULL,
  `type` varchar(255) default NULL,
  `output` varchar(4096) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

