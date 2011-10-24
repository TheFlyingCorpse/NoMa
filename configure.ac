AC_PREREQ([2.61])
AC_INIT(noma, 1.0)
AC_PROG_INSTALL
AC_PATH_PROG(PERL, perl, no)
AC_PATH_PROG(SED, sed, no)
AC_PATH_PROG(SENDMAIL, SENDMAIL, /usr/bin/sendmail)
AC_PREFIX_DEFAULT(/usr/local/noma)

AC_CONFIG_MACRO_DIR([m4])

dnl look for icinga user or fall back to nagios user
AX_CHECK_USER(USER, [icinga])
	if test x$USER != xicinga; then
		USER=nagios
	fi

AC_ARG_WITH(user,
	AC_HELP_STRING([--with-user=<user>],[user name to run NoMa as (default autodetect)]),
	RUNAS=$withval,
	RUNAS=$USER)
AC_ARG_WITH(group,
	AC_HELP_STRING([--with-group=<group>],[group name to run NoMa as (default same as user)]),
	RUNASGRP=$withval,
	RUNASGRP=$USER)

INSTALLOPTS="-o $RUNAS -g $RUNASGRP"

AC_ARG_WITH(cmdpipe,
	AC_HELP_STRING([--with-cmdpipe=<path to pipe>],[location of nagios/icinga command pipe]),
	NAGIOSPIPE=$withval,
	NAGIOSPIPE=/usr/local/$USER/var/rw/$USER.cmd)

AC_ARG_WITH(plugindir,
	AC_HELP_STRING([--with-plugindir=<dir>],[location of nagios/icinga plugins]),
	NAGIOSLIBEXEC=$withval,
	NAGIOSLIBEXEC=/usr/local/$USER/libexec)

AC_SUBST(RUNAS)
AC_SUBST(RUNASGRP)
AC_SUBST(INSTALLOPTS)
AC_SUBST(NAGIOSPIPE)
AC_SUBST(NAGIOSLIBEXEC)

AX_PROG_PERL_MODULES([YAML::Syck Getopt::Long Pod::Usage Digest::MD5 POSIX Data::Dumper Thread::Queue IO::Select IO::Socket Fcntl FindBin DBI DateTime::TimeZone DateTime::Format::Strptime Date::Calc], , )

dnl MAKEFILES=`find . -name Makefile.in`
dnl for makefile in $MAKEFILES
dnl do
dnl 	basefile=`basename $makefile .in`
dnl 	AC_CONFIG_FILES($basefile)
dnl done
MAKEFILES="var/Makefile
contrib/Makefile
doc/Makefile
share/Makefile
share/config/Makefile
etc/Makefile
sql/Makefile
Makefile
notifier/Makefile"

AC_CONFIG_FILES($MAKEFILES)
AC_CONFIG_FILES([subst.sh],[chmod +x subst.sh])

AC_OUTPUT

echo ""
AC_MSG_RESULT([ Configuration Options])
AC_MSG_RESULT([])
AC_MSG_RESULT([ Install directory: $prefix])
AC_MSG_RESULT([ NoMa user/group:   $RUNAS/$RUNASGRP])
AC_MSG_RESULT([ Command pipe:      $NAGIOSPIPE])
AC_MSG_RESULT([ Plugin directory:  $NAGIOSLIBEXEC])
