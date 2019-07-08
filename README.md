[![Build Status](https://travis-ci.org/nugulinux/docker-buildenv.svg?branch=master)](https://travis-ci.org/nugulinux/docker-buildenv) [![Docker Pulls](https://img.shields.io/docker/pulls/nugulinux/buildenv.svg)](https://hub.docker.com/r/nugulinux/buildenv/)

# Docker images for Ubuntu sbuild

## Getting started

### Build debian package for x86_64 Xenial(Ubuntu 16.04)

```sh
$ git clone .../myrepo
$ docker run -it --rm --privileged -v $PWD:$PWD -w $PWD/myrepo \
    -v /var/lib/schroot/chroots nugulinux/buildenv:xenial_x64 sbuild.sh
$ ls
myrepo/
myrepo_amd64.deb
```

## Images

### Base image

You can create your own sbuild image using `mk-sbuild` tool and base image.

- Branch: [base](https://github.com/nugulinux/docker-buildenv/tree/base)
- Docker image: [nugulinux/buildenv]()

### Cross-compile images

Pre-configured images for sbuild.

- Branch: [rootfs](https://github.com/nugulinux/docker-buildenv/tree/rootfs)
- Docker images
  - `nugulinux/buildenv:xenial_x64`
  - `nugulinux/buildenv:xenial_arm64`
  - `nugulinux/buildenv:xenial_armhf`
  - `nugulinux/buildenv:bionic_x64`
  - `nugulinux/buildenv:bionic_arm64`
  - `nugulinux/buildenv:bionic_armhf`
