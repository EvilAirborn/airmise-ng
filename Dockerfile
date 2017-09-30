#airmise-ng Dockerfile

#Base image
FROM kalilinux/kali-linux-docker:latest

#Credits & Data
LABEL \
	name="airmise-ng" \
	author="EvilAirborn <mahin.airborn.com>" \
	maintainer="OscarAkaElvis <oscar.alfonso.diaz@gmail.com>" \
	description="This is a multi-use bash script for Linux systems to audit wireless networks."

#Env vars
ENV airmise-ng_URL="https://github.com/EvilAirborn/airmise-ng.git"
ENV HASHCAT2_URL="https://github.com/EvilAirborn/hashcat2.0.git"
ENV DEBIAN_FRONTEND="noninteractive"

#Update system
RUN apt update

#Set locales
RUN \
	apt -y install \
	locales && \
	locale-gen en_US.UTF-8 && \
	sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
	echo 'LANG="en_US.UTF-8"' > /etc/default/locale && \
	dpkg-reconfigure --frontend=noninteractive locales && \
	update-locale LANG=en_US.UTF-8

#Env vars for locales
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"

#Install airmise-ng essential tools
RUN \
	apt -y install \
	gawk \
	net-tools \
	wireless-tools \
	iw \
	aircrack-ng \
	xterm

#Install airmise-ng internal tools
RUN \
	apt -y install \
	ethtool \
	pciutils \
	usbutils \
	rfkill \
	x11-utils \
	wget \
	ccze \
	x11-xserver-utils

#Install update tools
RUN \
	apt -y install \
	curl \
	git

#Install airmise-ng optional tools
RUN \
	apt -y install \
	crunch \
	hashcat \
	mdk3 \
	hostapd \
	lighttpd \
	iptables \
	ettercap-text-only \
	sslstrip \
	isc-dhcp-server \
	dsniff \
	reaver \
	bully \
	pixiewps \
	expect

#Install needed Ruby gems
RUN \
	apt -y install \
	beef-xss \
	bettercap

#Env var for display
ENV DISPLAY=":0"

#Create volume dir for external files
RUN mkdir /io
VOLUME /io

#Set workdir
WORKDIR /opt/

#airmise-ng install method 1 (only one method can be used, other must be commented)
#Install airmise-ng (Docker Hub automated build process)
RUN mkdir airmise-ng
COPY . /opt/airmise-ng

#airmise-ng install method 2 (only one method can be used, other must be commented)
#Install airmise-ng (manual image build)
#Uncomment git clone line and one of the ENV vars to select branch (master->latest, dev->beta)
#ENV BRANCH="master"
#ENV BRANCH="dev"
#RUN git clone -b ${BRANCH} ${airmise-ng_URL}

#Remove auto update
RUN sed -i 's|auto_update=1|auto_update=0|' airmise-ng/airmise-ng.sh

#Make bash script files executable
RUN chmod +x airmise-ng/*.sh

#Downgrade Hashcat
RUN \
	git clone ${HASHCAT2_URL} && \
	cp /opt/hashcat2.0/hashcat /usr/bin/ && \
	chmod +x /usr/bin/hashcat

#Clean packages
RUN \
	apt clean && \
	apt autoclean && \
	apt autoremove

#Clean files
RUN rm -rf /opt/airmise-ng/imgs > /dev/null 2>&1 && \
	rm -rf /opt/airmise-ng/.github > /dev/null 2>&1 && \
	rm -rf /opt/airmise-ng/.editorconfig > /dev/null 2>&1 && \
	rm -rf /opt/airmise-ng/CONTRIBUTING.md > /dev/null 2>&1 && \
	rm -rf /opt/airmise-ng/pindb_checksum.txt > /dev/null 2>&1 && \
	rm -rf /opt/airmise-ng/Dockerfile > /dev/null 2>&1 && \
	rm -rf /opt/airmise-ng/binaries > /dev/null 2>&1 && \
	rm -rf /opt/hashcat2.0 > /dev/null 2>&1 && \
	rm -rf /tmp/* > /dev/null 2>&1 && \
	rm -rf /var/lib/apt/lists/* > /dev/null 2>&1

#Expose BeEF control panel port
EXPOSE 3000

#Start command (launching airmise-ng)
CMD ["/bin/bash", "-c", "/opt/airmise-ng/airmise-ng.sh"]
