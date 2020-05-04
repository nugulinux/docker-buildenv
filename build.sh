#!/bin/sh
set -ev

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
	exit 1
fi

CNAME=$1

docker pull nugulinux/buildenv

# The "--privileged" option is required because we should run the
# "mount --bind" command inside the container.
docker create -it --privileged --name $CNAME nugulinux/buildenv

docker start $CNAME

CHROOT=buster-rpi-armhf
HOST=armhf
DIST=buster-rpi
CROSS=0

docker cp sbuild/rpi.sources $CNAME:/home/work
docker cp sbuild/.mk-sbuild.rc $CNAME:/home/work

docker exec -t $CNAME bash -c "curl -sL http://archive.raspbian.org/raspbian.public.key | gpg --import -"
docker exec -t $CNAME bash -c "gpg --export 9165938D90FDDD2E > /home/work/raspbian-archive-keyring.gpg"

docker exec -t $CNAME bash -c "mk-sbuild --arch $HOST --name $DIST --debootstrap-mirror=http://archive.raspbian.org/raspbian/ buster && sudo sed -i 's/^union-type=.*/union-type=overlay/' /etc/schroot/chroot.d/sbuild-$CHROOT && sbuild-update $CHROOT && sbuild-upgrade $CHROOT"

# Install essential packages
docker exec -t $CNAME sudo bash -c "cd / && schroot -c source:$CHROOT -u root -- apt-get install -y apt-transport-https ca-certificates"

# Install sdk dependency packages (raspbian apt is too slow)
docker exec -t $CNAME sudo bash -c "cd / && schroot -c source:$CHROOT -u root -- apt-get install -y cmake pkg-config git-core libglib2.0-dev libcurl4-openssl-dev libopus-dev portaudio19-dev libssl-dev libasound2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev"

docker stop $CNAME

echo "export CHROOT=$CHROOT" > buildinfo
echo "export HOST=$HOST" >> buildinfo
echo "export DIST=$DIST" >> buildinfo
echo "export CROSS=$CROSS" >> buildinfo
echo "export TAG=$1" >> buildinfo

docker cp buildinfo $CNAME:/etc/
docker cp sbuild.sh $CNAME:/usr/bin/
docker cp sdkbuild.sh $CNAME:/usr/bin/

# Create a docker image using container
docker commit $CNAME nugulinux/buildenv:$CNAME

# Remove container
docker rm $CNAME

rm buildinfo

