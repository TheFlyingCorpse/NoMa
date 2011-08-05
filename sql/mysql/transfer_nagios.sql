Down below are some queries to determine existing contacts from an NDO to ease the pain of importing existing Nagios contacts:


select distinct alias,email_address,pager_address from nagios_contacts;

select distinct alias from nagios_contactgroups;

select distinct c.alias contact, c.email_address, c.pager_address, cg.alias contactgroup from nagios_contacts c
inner join nagios_contactgroup_members cgm on cgm.contact_object_id=c.contact_object_id
inner join nagios_contactgroups cg on cg.contactgroup_id=cgm.contactgroup_id;
