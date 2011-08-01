# notifier settings

sub conf {
	
	my $conf = {

		# database settings
		'db'	=> {
			host		=> 'localhost',		# database host
			database	=> 'noma',			# database name
			user		=> 'noma',			# database user
			password	=> 'noma',			# database password
		},

		# logging-related settings
		'log'	=> {
			pluginOutput		=> 1,		# log plugin output (0|1)
			hostServiceOutput	=> 1,		# log host- and service output (0|1)
			delimiter		=> ' | ',	# delimiter to separate logging strings
		},
		path	=> {
			cache			=> '/usr/local/nagios/noma/noma.cache',
			pidfile			=> '/usr/local/nagios/noma/noma.pid',

		},
		
		# at least 1 input method must be enabled!
		input	=> {
			pipeEnabled		=> 1,
			pipePath		=> '/usr/local/nagios/noma/noma.pipe',
			socketEnabled		=> 1,
			socketAddress		=> 'localhost',
			socketPort		=> 5670,
			socketMaxConns		=> 10,
		},

		# commands
		command	=> {
			sendemail		=> '/usr/local/nagios/noma/notifier/sendEmail.pl',
			sendsms			=> '/usr/local/nagios/noma/notifier/sendSMS.pl',
			#sendsms			=> '/usr/local/nagios/noma/notifier/sendSMSfinder.pl',		# if you use iMultitech iSMS/SMSfinder
			voicecall		=> '/usr/local/nagios/noma/notifier/sendVoice.pl',
			growl			=> '/usr/local/nagios/noma/notifier/sendGrowl.pl',
			dummy			=> '/bin/true',
		    nagios          => '/usr/local/nagios/noma/notifier/sendToNagios.pl',
		},
		
		# notifier settings
		notifier => {
			timezone		=> 'Europe\Oslo', # TimeZone of NoMa / localhost. Used for proper timezone calculzation. Otherwise will default to UTC.
			locale			=> 'en_GB', 	# Change at your own risk, its for datehandling with sql queries using english names for tables and conversion of dates.
			pattern			=> '%F %T',	# Change at your own risk, might need to be changed if it does not use MySQL standard, see http://search.cpan.org/~drolsky/DateTime-Format-Strptime-1.5000/lib/DateTime/Format/Strptime.pm#STRPTIME_PATTERN_TOKENS for strip pattern tokens.
			maxAttempts		=> '4',		# how often we retry a notification before giving up
			timeToWait		=> '60',	# how many seconds to wait before retries
			delay			=> 0,	    # delay notifications this number of seconds (for bundling)
			bundle			=> 0,       # set to 1 to bundle multiple alerts into a single notification
			ackPipe			=> '/var/log/nagios/rw/nagios.cmd',     #
			sleep_time		=> '1',     # Set the time in seconds that the daemon will sleep for. Can be decimal for shorter than a second, will increase load on database and local server. Ideally lower only against local databases to prevent flooding.
		},

		# escalation settings
		escalator => {
			internalEscalation	=> 0,		# GLOBAL FLAG: NoMa handles notification escalations
								# and ignores further alerts
								# setting to 0 will enable per rule settings ("let notifier handle")
			timeToWait		=> '300',       # wait 5 mins before escalating to next rule
			stopAfter		=> '5400',        # stop escalating after 90 minutes
		},

		# voice alerting settings
		voicecall => {
			return_ack		=> 0,               # set to 1 to feed ACKs back to Icinga/Nagios
			suppression		=> 0,               # add a global suppression menu option (value in minutes)
			server			=> '192.168.1.1',	# address of the starface/asterisk server
			#server			=> ['192.168.1.1', '192.168.1.2'],	# addresses of the starface/asterisk server farm
			callerID		=> '0',			# our caller ID (for point-to-multipoint / Mehrgerätanschlüße)
			starface		=> '1',			# set to 1 to use the starface script, otherwise use the generic asterisk script
			#channel			=> 'Zap/g30',		# for Starface light
			channel 		=> 'Srx/g31',		# for standard Starface
			#channel			=> ['Srx/g31', 'Srx/g31'],	# for standard Starface (array if more than one server, same order as servers above)
			#channel		=> 'SIP',		# for SIP
            #international_prefix   => '',    # Replace + with this prefix. Defaults to 00 if not defined
			check_command		=> '/usr/local/nagios/libexec/check_snmp -H $server -u $channel -l Starface -R "ISDN Channels: OK:1" -t 1 -o .1.3.6.1.4.1.32354.1.2.999.4.1.2.9.98.117.108.107.99.104.101.99.107.1',		# check_command must return 0 if the appliance is ok, 1st ok appliance is chosen.
            suffix          => '',          # channel suffix
			message	=> {
				header		=> 'this is a message from nagios ',				# header for all alerts
				host		=> 'the host $host is $status',					# host message
				service		=> 'the service $service on host $host is status $status',	# service message
			},
			bundled_message	=> {
				header		=> 'this is a message from nagios ',				# header for all alerts
				host		=> 'there are $count alerts. $output.',			# all messages
			},
		},

		# sms alerting settings
		sendsms => {
			#return_ack		=> 0,               # set to 1 to feed ACKs back to Icinga/Nagios
			suppression		=> 0,               # add a global suppression menu option (value in minutes)
			#server			=> '192.168.1.1',	# address of the SMS server
			#server			=> ['192.168.1.1', '192.168.1.2'],	# addresses of the SMS server farm
			#user			=> ['nagios', 'nagios'],	# user for iSMS/SMSfinder
			#pass			=> ['nagios', 'nagios'],	# pass for iSMS/SMSfinder
			check_command		=> '/usr/local/nagios/libexec/check_smsfinder.pl -H $server -u admin -p admin -w 2 -c 1',		# check_command must return 0 if the appliance is ok, 1st ok appliance is chosen.
			message	=> {
				host            => '$incident_id: $notification_type on host $host. State is $status. Alias: $host_alias. $output Time: $datetime',
				service         => '$incident_id: $notification_type for service $service on host $host. State is $status. Info: $output Time: $datetime',
			},

                        ackmessage => {
				host            => '$incident_id: $notification_type on host $host. State is $status. Alias: $host_alias. Time: $datetime',
				service         => '$incident_id: $notification_type for service $service on host $host. State is $status. Author $authors Comment $comments. Time: $datetime',
                        },
		},
			
		# email alerting settings
		sendemail => {
			sendmail		=> '/usr/sbin/sendmail -t',					# location of mail binary
			message	=> {
				host => {
					subject	=> 'NoMa: Host $host is $status',				# mail subject
					message	=> 
'***** NoMa *****

ID: $incident_id
Notification Type: $notification_type
Host: $host
Host Alias: $host_alias
State: $status
Address: $host_address
Link: http://localhost/nagios/cgi-bin/extinfo.cgi?type=1&host=$host
Info: $output

Date/Time: $datetime',							# mail body
                                        ackmessage =>
'***** NoMa *****

ID: $incident_id
Notification Type: $notification_type
Host: $host
Author: $authors
Comment: $comments
State: $status
Link: http://localhost/nagios/cgi-bin/extinfo.cgi?type=1&host=$host
Info: $output

Date/Time: $datetime',  
                    # filename => '/tmp/message_for_$host.txt',           # optionally include contents of filename (as variable $file in message). WARNING: avoid _ directly after a variable name.
				},
				service => {
					subject	=> 'NoMa: Service $service on host $host is $status',				# mail subject
					message	=> 
'***** NoMa *****

ID: $incident_id
Notification Type: $notification_type
Service: $service
Host: $host
Host Alias: $host_alias
State: $status
Address: $host_address
Link: http://localhost/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=$service
Info: $output

Date/Time: $datetime',							# mail body
					ackmessage =>
'***** NoMa *****

ID: $incident_id
Notification Type: $notification_type
Author: $authors
Comment: $comments
Service: $service
Host: $host
State: $status

Link: http://localhost/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=$service
Info: $output

Date/Time: $datetime',
                    # filename => '',           # optionally include contents of filename (as variable $file in message). WARNING: avoid _ directly after a variable name.
				},
			},
		},

                # growl  alerting settings
                growl => {
                        return_ack             => 0,               # set to 1 to feed ACKs back to Icinga/Nagios
			application_name	=> 'NoMa',
			password		=> 'somepassw0rd',
                        subject_host            => 'NoMa - $notification_type: Host $host is $status',
			subject_service		=> 'NoMa - $notification_type: Service $service on host $host is $status',
                        message => {
                                host            => '$incident_id: $notification_type on host $host. State is $status. Alias: $host_alias. $output Time: $datetime',
                                service         => '$incident_id: $notification_type for service $service on host $host. State is $status. Info: $output Time: $datetime',
                        },

                        ackmessage => {
                                host            => '$incident_id: $notification_type on host $host. State is $status. Alias: $host_alias. Time: $datetime',
                                service         => '$incident_id: $notification_type for service $service on host $host. State is $status. Author $authors Comment $comments. Time: $datetime',
                        },
                },
			

		# miscellaneous settings
		debug => {
			logging			=> '1',		# general debugging
			queries			=> '1',		# log SQL queries
			file			=> '/usr/local/nagios/var/noma_debug.log',	# file to log in
			daemonize		=> '0',		# daemonize process
			paramlog		=> undef,	# '/usr/local/nagios/var/noma_args_log.txt'
			watchdogEnabled		=> '1',		# the watchdog restarts the daemon if too much memory is used
			watchdogMaxRSS		=> 524288,	# real memory
			watchdogMaxVSS		=> 1048576,	# virtual memory
			watchdogMaxRuntime	=> undef,	# restart after this many seconds
			voice			=> undef,	# logging voice alert errors
			#voice			=> '/usr/local/nagios/var/voice_debug.log',	# logging voice alert errors
			sms				=> undef,	# dont log sms alert errors
			#sms				=> '/usr/local/nagios/var/sms_debug.log',	# logging sms alert errors
		},

	};

	return $conf;

}

1;
