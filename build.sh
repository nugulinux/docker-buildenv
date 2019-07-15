#!/bin/sh
set -ev

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
	exit 1
fi

docker pull nugulinux/buildenv:base_wip

# The "--privileged" option is required because we should run the
# "mount --bind" command inside the container.
docker create -it --privileged --name $1 nugulinux/buildenv:base_wip

docker start $1
case "$1" in
	"test")
		CHROOT=xenial-amd64
		HOST=amd64
		DIST=xenial
		CROSS=0
		;;

	*)
		exit 1
esac

#docker exec -t $1 bash -c "sudo rm /etc/schroot/setup.d/04tmpfs"
#docker exec -t $1 bash -c "sudo rm /etc/fstab && sudo touch /etc/fstab"
docker exec -t $1 bash -c "mk-sbuild --arch $HOST $DIST"
#docker exec -t $1 bash -c "sudo sed -i 's/^union-type=.*/union-type=overlay/' /etc/schroot/chroot.d/sbuild-$CHROOT"
#docker exec -t $1 bash -c "sbuild-update $CHROOT && sbuild-upgrade $CHROOT"

docker stop $1

echo "export CHROOT=$CHROOT" > buildinfo
echo "export HOST=$HOST" >> buildinfo
echo "export DIST=$DIST" >> buildinfo
echo "export CROSS=$CROSS" >> buildinfo
echo "export TAG=$1" >> buildinfo

docker cp buildinfo $1:/etc/
docker cp sbuild.sh $1:/usr/bin/

# Create a docker image using container
docker commit $1 nugulinux/buildenv:$1

# Remove container
docker rm $1

