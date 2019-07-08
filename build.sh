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
		docker exec -t $1 bash -c "mk-sbuild --arch amd64 xenial && sudo sed -i 's/^union-type=.*/union-type=overlay/' /etc/schroot/chroot.d/sbuild-xenial-amd64 && sbuild-update xenial-amd64 && sbuild-upgrade xenial-amd64"
		;;

	"xenial_arm64")
		CHROOT=xenial-amd64-arm64
		HOST=arm64
		docker exec -t $1 bash -c "mk-sbuild --target arm64 xenial && sudo sed -i 's/^union-type=.*/union-type=overlay/' /etc/schroot/chroot.d/sbuild-xenial-amd64-arm64 && sbuild-update xenial-amd64-arm64 && sbuild-upgrade xenial-amd64-arm64 && sudo cp /usr/bin/qemu-aarch64-static /var/lib/schroot/chroots/xenial-amd64-arm64/usr/bin"
		;;

	"xenial_armhf")
		CHROOT=xenial-amd64-armhf
		HOST=armhf
		docker exec -t $1 bash -c "mk-sbuild --target armhf xenial && sudo sed -i 's/^union-type=.*/union-type=overlay/' /etc/schroot/chroot.d/sbuild-xenial-amd64-armhf && sbuild-update xenial-amd64-armhf && sbuild-upgrade xenial-amd64-armhf && sudo cp /usr/bin/qemu-arm-static /var/lib/schroot/chroots/xenial-amd64-armhf/usr/bin"
		;;

	"bionic_x64")
		CHROOT=bionic-amd64
		HOST=amd64
		docker exec -t $1 bash -c "mk-sbuild --arch amd64 bionic && sudo sed -i 's/^union-type=.*/union-type=overlay/' /etc/schroot/chroot.d/sbuild-bionic-amd64 && sbuild-update bionic-amd64 && sbuild-upgrade bionic-amd64"
		;;

	"bionic_arm64")
		CHROOT=bionic-amd64-arm64
		HOST=arm64
		docker exec -t $1 bash -c "mk-sbuild --target arm64 bionic && sudo sed -i 's/^union-type=.*/union-type=overlay/' /etc/schroot/chroot.d/sbuild-bionic-amd64-arm64 && sbuild-update bionic-amd64-arm64 && sbuild-upgrade bionic-amd64-arm64 && sudo cp /usr/bin/qemu-aarch64-static /var/lib/schroot/chroots/bionic-amd64-arm64/usr/bin"
		;;

	"bionic_armhf")
		CHROOT=bionic-amd64-armhf
		HOST=armhf
		docker exec -t $1 bash -c "mk-sbuild --target armhf bionic && sudo sed -i 's/^union-type=.*/union-type=overlay/' /etc/schroot/chroot.d/sbuild-bionic-amd64-armhf && sbuild-update bionic-amd64-armhf && sbuild-upgrade bionic-amd64-armhf && sudo cp /usr/bin/qemu-arm-static /var/lib/schroot/chroots/bionic-amd64-armhf/usr/bin"
		;;

	*)
		exit 1
esac
docker stop $1

echo '#!/bin/sh' > sbuild.sh
echo "CHROOT=$CHROOT" >> sbuild.sh
echo "HOST=$HOST" >> sbuild.sh
echo 'JOBS=`nproc`' >> sbuild.sh
echo 'sbuild --chroot $CHROOT --host $HOST -j$JOBS "$@"' >> sbuild.sh
chmod +x sbuild.sh

docker cp sbuild.sh $1:/usr/bin/

# Create a docker image using container
docker commit $1 nugulinux/buildenv:$1

# Remove container
docker rm $1

