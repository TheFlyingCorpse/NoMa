AC_DEFUN([AX_CHECK_USER],[

_userresult=""
for usertest in $2; do
	AC_MSG_CHECKING([for user $usertest])

	if getent passwd $usertest > /dev/null; then
			_userresult=$usertest
			break
	fi
done
if test "x$_userresult" != "x"; then
	$1=$_userresult
	AC_MSG_RESULT([yes])
else
	$1=$3
	AC_MSG_RESULT([no])
fi
dnl
])
