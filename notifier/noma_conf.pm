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
			voicecall		=> '/usr/local/nagios/noma/notifier/sendVoice.pl',
			# dummy			=> '/bin/true',
		},
		
		# notifier settings
		notifier => {
			maxAttempts		=> '5',		# how often we try a notification before giving up
			timeToWait		=> '60',	# how many seconds to wait before retries
		},

		# escalation settings
		escalator => {
			internalEscalation	=> 0,		# GLOBAL FLAG: NoMa handles notification escalations
								# and ignores further alerts (including OKs)
								# setting to 0 will enable per rule settings ("let notifier handle")
			timeToWait		=> '120',
		},

		# voice alerting settings
		voice => {
			server			=> '192.168.1.1',	# address of the starface/asterisk server
			callerID		=> '0',			# our caller ID (for point-to-multipoint / Mehrgerätanschlüße)
			starface		=> '1',			# set to 1 to use the starface script, otherwise use the generic asterisk script
			channel			=> 'Zap/g30',		# for Starface light
			#channel		=> 'Srx/g31',		# for standard Starface
			#channel		=> 'SIP',		# for SIP
			message	=> {
				header		=> 'this is a message from nagios ',				# header for all alerts
				host		=> 'the host $host is $status',					# host message
				service		=> 'the service $service on host $host is status $status',	# service message
			},
		},
			
		# email alerting settings
		email => {
			sendmail		=> '/usr/sbin/sendmail -t',					# location of mail binary
			message	=> {
				host => {
					subject	=> 'NoMa: Host $host is $status',				# mail subject
					message	=> 
'***** NoMa *****

Notification Type: $notification_type
Host: $host
State: $status
Address: $host_address
Link: http://localhost/nagios/cgi-bin/extinfo.cgi?type=1&host=$host
Info: $output

Date/Time: $datetime"',							# mail body
				},
				service => {
					subject	=> 'NoMa: Service $service on host $host is $status',				# mail subject
					message	=> 
'***** NoMa *****

Notification Type: $notification_type
Service: $service
Host: $host
State: $status
Address: $host_address
Link: http://localhost/nagios/cgi-bin/extinfo.cgi?type=2&host=$host&service=$service
Info: $output

Date/Time: $datetime"',							# mail body
				},
			},
		},
			

		# miscellaneous settings
		debug => {
			logging			=> '0',		# general debugging
			queries			=> '0',		# log SQL queries
			file			=> '/usr/local/nagios/var/noma_debug.log',	# file to log in
			daemonize		=> '1',		# daemonize process
			paramlog		=> undef,	# '/usr/local/nagios/var/noma_args_log.txt'
			watchdogEnabled		=> '1',		# the watchdog restarts the daemon if too much memory is used
			watchdogMaxRSS		=> 524288,	# real memory
			watchdogMaxVSS		=> 1048576,	# virtual memory
			watchdogMaxRuntime	=> undef,	# restart after this many seconds
			voice			=> undef,	# logging voice alert errors
		},

	};

	return $conf;

}

1;
