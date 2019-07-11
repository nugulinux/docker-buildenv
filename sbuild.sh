#!/bin/bash

. /etc/buildinfo
JOBS=`nproc`

while getopts ":p:" o; do
    case "${o}" in
        p)
	    APTPROXY="Acquire::http::Proxy \"${OPTARG}\";"
            ;;
        *)
            echo "Usage: $0 [-p apt_cache_proxy_url] [sbuild options]"
	    exit 1
            ;;
    esac
done
shift $((OPTIND-1))

if [ ! -z "$APTPROXY" ]; then
	RESULT=$(echo $APTPROXY | sudo tee -a /var/lib/schroot/chroots/$CHROOT/etc/apt/apt.conf.d/proxy)
	echo $RESULT
fi


sbuild --chroot $CHROOT --host $HOST -j$JOBS --dpkg-source-opt="-I.git" "$@"
