FROM ubuntu:latest

LABEL maintainer="dmitry@kernelgen.org"

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# Install i3 desktop with X11 and vnc
RUN apt-get update && \
	apt-get -y --no-install-recommends install \
        wget \
		i3 \
		rxvt-unicode \
		supervisor \
		fonts-dejavu \
        tigervnc-standalone-server \
        tigervnc-tools \
		xserver-xorg \
		xinit \
        x11-xserver-utils \
		ca-certificates \
		sudo && \
	apt-get clean

EXPOSE 5900

# Install google chrome, in order to have a browser inside the container,
# which does not depend on snap
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
	apt-get -y --no-install-recommends install \
		./google-chrome-stable_current_amd64.deb && \
	rm -rf ./google-chrome-stable_current_amd64.deb

# Add a regular user with sudo rights
RUN useradd -rm -s /bin/bash -g root -G sudo -u 1001 user && \
	echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# We use supervisor instead of systemd to start pulsesecure service
COPY ./supervisord.conf /etc/
COPY ./supervisor-log-prefix.sh /
COPY ./.Xresources /home/user/
COPY ./.vnc /home/user/.vnc
RUN chown user -R /home/user
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

