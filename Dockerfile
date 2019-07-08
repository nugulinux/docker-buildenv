
FROM ubuntu:bionic
LABEL maintainer="webispy@gmail.com" \
      version="0.1" \
      description="build environment for nugulinux"

ENV DEBIAN_FRONTEND=noninteractive \
    USER=work \
    LC_ALL=en_US.UTF-8 \
    LANG=$LC_ALL

RUN apt-get update && touch /etc/localtime \
	    && touch /etc/timezone \
	    && apt-get install -y --no-install-recommends \
	    apt-utils \
	    binfmt-support \
	    build-essential \
	    ca-certificates \
	    curl \
	    debianutils \
	    debhelper \
	    debootstrap \
	    devscripts \
	    git \
	    iputils-ping \
	    language-pack-en \
	    net-tools \
	    qemu-user-static \
	    sbuild \
	    schroot \
	    sed \
	    sudo \
	    ubuntu-dev-tools \
	    unzip \
	    wget \
	    xz-utils \
	    && apt-get clean \
	    && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash $USER \
		&& echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
		&& chmod 0440 /etc/sudoers.d/$USER \
		&& echo 'Defaults env_keep="http_proxy https_proxy ftp_proxy no_proxy"' >> /etc/sudoers \
		&& adduser $USER dialout \
		&& adduser $USER sbuild

USER $USER
ENV HOME /home/$USER
WORKDIR /home/$USER

RUN mkdir -p ~/ubuntu/scratch && mkdir -p ~/ubuntu/build && mkdir -p ~/ubuntu/logs && mkdir -p ~/ubuntu/repo && mkdir -p ~/ubuntu/debs

COPY sbuild/.sbuildrc sbuild/.mk-sbuild.rc /home/$USER/
COPY repo/chup repo/clean.sh repo/localdebs.sh repo/prep.sh repo/scan.sh /home/$USER/ubuntu/repo/
RUN echo "/home/$USER/ubuntu/scratch    /scratch    none    rw,bind    0    0" | sudo tee -a /etc/schroot/sbuild/fstab \
		&& echo "/home/$USER/ubuntu/repo    /repo   none    rw,bind    0    0" | sudo tee -a /etc/schroot/sbuild/fstab \
		&& sudo chown $USER.$USER .sbuildrc && sudo chown $USER.$USER .mk-sbuild.rc \
		&& sudo chown $USER.$USER ~/ubuntu/repo/* \
		&& chmod 755 ~/ubuntu/repo/*.sh ~/ubuntu/repo/chup

# sbuild tmpfs setup to speed-up
COPY sbuild/04tmpfs /etc/schroot/setup.d/
RUN sudo chmod 755 /etc/schroot/setup.d/04tmpfs \
		&& echo "none /var/lib/schroot/union/overlay tmpfs uid=root,gid=root,mode=0750 0 0" | sudo tee -a /etc/fstab

CMD ["/bin/bash"]
