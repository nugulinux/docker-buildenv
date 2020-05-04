#!/bin/bash

. /etc/buildinfo

function update_debianlink()
{
	ln -s packaging/$DIST debian
	echo " - Created symbolic link 'packaging/$DIST' to 'debian'"
}

# Check debian directory
if [ -d "debian" ]; then
	if [ -h "debian" ]; then
		CHECKLINK=`readlink debian`
		echo "Found 'debian' symbolic link (linked to '$CHECKLINK')"
		if [ -d "packaging/$DIST" ]; then
			if [ "$CHECKLINK" != "packaging/$DIST" ]; then
				echo " - Fix invalid link (change to packaging/$DIST)"
				rm debian
				update_debianlink
			fi
		fi
	else
		echo "Found 'debian' directory"
	fi
else
	echo "Can't found 'debian' directory"
	if [ -d "packaging/$DIST" ]; then
		echo " - Found 'packaging/$DIST' directory"
		update_debianlink
	else
		echo " - Can't found 'packaging/$DIST' directory"
		exit 1
	fi
fi

# PPA not support
#EXTRAREPO="--extra-repository=\"deb [trusted=yes] http://ppa.launchpad.net/nugulinux/sdk/ubuntu $DIST main\""
#BUILDCMD="sbuild.sh -- $EXTRAREPO"

BUILDCMD="sbuild.sh"
echo $BUILDCMD
eval $BUILDCMD
