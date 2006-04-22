#!/bin/sh
if [ "$1" = "--with" -a "$2" = "license_agreement" ]; then
	tmp=$(mktemp -d)
	SPECDIR=`rpm --define "_topdir $tmp" --eval "%{_specdir}"`
	SRPMDIR=`rpm --define "_topdir $tmp" --eval "%{_srcrpmdir}"`
	SOURCEDIR=`rpm --define "_topdir $tmp" --eval "%{_sourcedir}"`
	BUILDDIR=`rpm --define "_topdir $tmp" --eval "%{_builddir}"`
	RPMDIR=`rpm --define "_topdir $tmp" --eval "%{_rpmdir}"`
	mkdir -p $SPECDIR $SRPMDIR $RPMDIR $SRPMDIR $SOURCEDIR $BUILDDIR

	if echo "$3" | grep '\.src\.rpm$' >/dev/null; then
		(
		if echo "$3" | grep '://' >/dev/null; then
			cd $SRPMDIR
			wget --passive-ftp -t0 "$3"
		else
			cp -f "$3" $SRPMDIR
		fi
		rpm2cpio `basename "$3"` | ( cd $SPECDIR; cpio -i @BASE_NAME@.spec )
		if [ '@COPYSOURCES@' != '@'COPYSOURCES'@' ]; then
			rpm2cpio `basename "$3"` | ( cd $SOURCEDIR; cpio -i @COPYSOURCES@ )
		fi
	   	)
	else
		cp -i "$3" $SPECDIR || exit 1
		if [ '@COPYSOURCES@' != '@'COPYSOURCES'@' ]; then
			for i in @COPYSOURCES@; do
				cp -i @DATADIR@/$i $SOURCEDIR/$i || exit 1
			done
		fi
	fi
	( cd $SPECDIR
	/usr/bin/builder --define _topdir $tmp -nm -nc -ncs --with license_agreement --target @TARGET_CPU@ @BASE_NAME@.spec
	if [ "$?" -ne 0 ]; then
		exit 2
	fi
	RPMNAMES="$RPMDIR/@BASE_NAME@-@VERSION@-@RELEASE@wla.@TARGET_CPU@.rpm"
	rpm -Uhv $RPMNAMES || echo -e "Install manually the file(s):\n   $RPMNAMES" )
else
	if [ "@LICENSE@" != '@'LICENSE'@' ]; then
		cat @LICENSE@
		echo "
If you accept the above license rebuild the package using:
"
	else
		echo "
License issues made us not to include inherent files into
this package by default. If you want to create full working
package please build it with the following command:
"
	fi
	echo "$0 --with license_agreement @SPECFILE@"
fi
