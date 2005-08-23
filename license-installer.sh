#!/bin/sh
if [ "$1" = "--with" -a "$2" = "license_agreement" ]; then
	TMPDIR=`rpm --eval "%{tmpdir}"`; export TMPDIR
	SPECDIR=`rpm --eval "%{_specdir}"`; export SPECDIR
	SRPMDIR=`rpm --eval "%{_srcrpmdir}"`; export SRPMDIR
	SOURCEDIR=`rpm --eval "%{_sourcedir}"`; export SOURCEDIR
	BUILDDIR=`rpm --eval "%{_builddir}"`; export BUILDDIR
	RPMDIR=`rpm --eval "%{_rpmdir}"`; export RPMDIR
	BACKUP=0
	mkdir -p $TMPDIR $SPECDIR $SRPMDIR $RPMDIR $SRPMDIR $SOURCEDIR $BUILDDIR
	if [ -f $SPECDIR/@BASE_NAME@.spec ]; then
		BACKUP=1
		mv -f $SPECDIR/@BASE_NAME@.spec $SPECDIR/@BASE_NAME@.spec.prev
	fi
	if echo "$3" | grep '\.src\.rpm$' >/dev/null; then
		( cd $SRPMDIR
		if echo "$3" | grep '://' >/dev/null; then
			wget --passive-ftp -t0 "$3"
		else
			cp -f "$3" .
		fi
		rpm2cpio `basename "$3"` | ( cd $TMPDIR; cpio -i @BASE_NAME@.spec )
		)
		cp -i $TMPDIR/@BASE_NAME@.spec $SPECDIR/@BASE_NAME@.spec || exit 1
	else
		cp -i "$3" $SPECDIR || exit 1
	fi
	( cd $SPECDIR
	/usr/bin/builder -nc -ncs --with license_agreement --opts --target=@TARGET_CPU@ @BASE_NAME@.spec
	if [ "$?" -ne 0 ]; then
		exit 2
	fi
	RPMNAMES="$RPMDIR/@BASE_NAME@-@VERSION@-@RELEASE@wla.@TARGET_CPU@.rpm"
	rpm -Uhv $RPMNAMES || echo -e "Install manually the file(s):\n   $RPMNAMES" )
	if [ "$BACKUP" -eq 1 ]; then
		if [ -f $SPECDIR/@BASE_NAME@.spec.prev ]; then
			mv -f $SPECDIR/@BASE_NAME@.spec.prev $SPECDIR/@BASE_NAME@.spec
		fi
	fi
else
	echo "
License issues made us not to include inherent files into
this package by default. If you want to create full working
package please build it with the following command:

$0 --with license_agreement @SPECFILE@
"
fi
