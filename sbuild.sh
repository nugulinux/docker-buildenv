#!/bin/bash

. /etc/buildinfo
JOBS=`nproc`

while getopts ":p:d:" o; do
	case "${o}" in
		p)
			APTPROXY="Acquire::http::Proxy \"${OPTARG}\";"
			;;
		d)
			DIRECT="Acquire::http::Proxy::${OPTARG} \"DIRECT\";"
			;;
		*)
			echo "Usage: $0 [-p apt_cache_proxy_url] [-d direct_url] [sbuild options]"
			exit 1
			;;
	esac
done
shift $((OPTIND-1))

if [ ! -z "$APTPROXY" ]; then
	RESULT=$(echo $APTPROXY | sudo tee -a /var/lib/schroot/chroots/$CHROOT/etc/apt/apt.conf.d/proxy)
	echo $RESULT
fi

if [ ! -z "$DIRECT" ]; then
	RESULT=$(echo $DIRECT | sudo tee -a /var/lib/schroot/chroots/$CHROOT/etc/apt/apt.conf.d/proxy)
	echo $RESULT
fi

sbuild --chroot $CHROOT --host $HOST --arch $HOST -j$JOBS --dpkg-source-opt="-I.git" "$@"
