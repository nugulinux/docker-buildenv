#!/bin/sh
set -ev

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
	exit 1
fi

docker pull nugulinux/buildenv

# The "--privileged" option is required because we should run the
# "mount --bind" command inside the container.
docker create -it --privileged --name $1 nugulinux/buildenv

docker start $1
case "$1" in
	"xenial_x64")
		CHROOT=xenial-amd64
		HOST=amd64
		DIST=xenial
		CROSS=0
		;;

	"xenial_arm64")
		CHROOT=xenial-amd64-arm64
		HOST=arm64
		DIST=xenial
		CROSS=1
		;;

	"xenial_armhf")
		CHROOT=xenial-amd64-armhf
		HOST=armhf
		DIST=xenial
		CROSS=1
		;;

	"bionic_x64")
		CHROOT=bionic-amd64
		HOST=amd64
		DIST=bionic
		CROSS=0
		;;

	"bionic_arm64")
		CHROOT=bionic-amd64-arm64
		HOST=arm64
		DIST=bionic
		CROSS=1
		;;

	"bionic_armhf")
		CHROOT=bionic-amd64-armhf
		HOST=armhf
		DIST=bionic
		CROSS=1
		;;

	*)
		exit 1
esac

if [ "$CROSS" -eq 1 ]
then
	docker exec -t $1 bash -c "mk-sbuild --target $HOST $DIST && sudo sed -i 's/^union-type=.*/union-type=overlay/' /etc/schroot/chroot.d/sbuild-$CHROOT && sbuild-update $CHROOT && sbuild-upgrade $CHROOT && sudo cp /usr/bin/qemu-a*-static /var/lib/schroot/chroots/$CHROOT/usr/bin"
else
	docker exec -t $1 bash -c "mk-sbuild --arch $HOST $DIST && sudo sed -i 's/^union-type=.*/union-type=overlay/' /etc/schroot/chroot.d/sbuild-$CHROOT && sbuild-update $CHROOT && sbuild-upgrade $CHROOT"
fi

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
