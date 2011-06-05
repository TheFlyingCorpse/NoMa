#
# 1.0.6 to 1.0.7
#
IF NOT EXISTS (SELECT  * FROM noma-master.COLUMNS
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

CREATE INDEX external_id ON tmp_commands (external_id);
CREATE INDEX unique_id ON notification_logs (unique_id);
CREATE INDEX notify_id ON tmp_active (notify_id);
CREATE INDEX incident_id ON escalation_stati (incident_id);

# IF not hotfixed for hostgroups after upgrade to 1.0.6, run this to be sure! (If it already exists, it wont finish!)
ALTER TABLE `tmp_commands` ADD `hostgroups` VARCHAR( 255 ) NOT NULL AFTER `hostgroups`
