[![Docker Pulls](https://img.shields.io/docker/pulls/nugulinux/buildenv.svg)](https://hub.docker.com/r/nugulinux/buildenv/)

# Docker images for Ubuntu sbuild

## Getting started

### Build a debian package for x86_64 focal(Ubuntu 20.04)

The **nugulinux/buildenv** docker image contains a `sbuild.sh` script that makes it easier the build. The script is a simple `sbuild` wrapper that automatically puts `--chroot`, `--host` and `-j{n}` options for the image.

```sh
$ git clone {url}/myrepo
$ docker run -t --rm --privileged -v $PWD:$PWD -w $PWD/myrepo \
    -v /var/lib/schroot/chroots nugulinux/buildenv:focal_x64 sbuild.sh
$ ls
myrepo/
myrepo_amd64.deb
```

### Build with additional parameters

You can use the parameters used in the `sbuild` command in `sbuild.sh` as well.

```sh
$ git clone {url}/myrepo
$ docker run -t --rm --privileged -v $PWD:$PWD -w $PWD/myrepo \
    -v /var/lib/schroot/chroots nugulinux/buildenv:focal_x64 \
    sbuild.sh --extra-repository="deb [trusted=yes] http://ppa.launchpad.net/nugulinux/sdk/ubuntu focal main"

$ ls
myrepo/
myrepo_amd64.deb
```

### Build with cross compile

The **nugulinux/buildenv** already has preconfigured images for **arm64** and **armhf**. So simply specify the desired target in the tag of the docker image.

```sh
$ git clone {url}/myrepo
$ docker run -t --rm --privileged -v $PWD:$PWD -w $PWD/myrepo \
    -v /var/lib/schroot/chroots nugulinux/buildenv:bionic_armhf sbuild.sh
$ ls
myrepo/
myrepo_amd64.deb
```

## Images

### Base image

[![Build Status](https://github.com/nugulinux/docker-buildenv/workflows/Docker%20publish%20-%20base/badge.svg)](https://github.com/nugulinux/docker-buildenv/actions?query=workflow%3A%22Docker+publish+-+base%22)

You can create your own sbuild image using `mk-sbuild` tool and base image.

- Branch: [base](https://github.com/nugulinux/docker-buildenv/tree/base)
- Docker image: `nugulinux/buildenv`

### Cross-compile images

[![Build Status](https://github.com/nugulinux/docker-buildenv/workflows/Docker%20publish%20-%20rootfs/badge.svg)](https://github.com/nugulinux/docker-buildenv/actions?query=workflow%3A%22Docker+publish+-+rootfs%22)

Pre-configured images for sbuild.

- Branch: [rootfs](https://github.com/nugulinux/docker-buildenv/tree/rootfs)
- Docker images
  - `nugulinux/buildenv:xenial_x64`
  - `nugulinux/buildenv:xenial_arm64`
  - `nugulinux/buildenv:xenial_armhf`
  - `nugulinux/buildenv:bionic_x64`
  - `nugulinux/buildenv:bionic_arm64`
  - `nugulinux/buildenv:bionic_armhf`
  - `nugulinux/buildenv:focal_x64`
  - `nugulinux/buildenv:focal_arm64`
  - `nugulinux/buildenv:focal_armhf`
  - `nugulinux/buildenv:jammy_x64`
  - `nugulinux/buildenv:jammy_arm64`
  - `nugulinux/buildenv:jammy_armhf`
  - `nugulinux/buildenv:noble_x64`
  - `nugulinux/buildenv:noble_arm64`
  - `nugulinux/buildenv:noble_armhf`
