FROM balenalib/asus-tinker-board-debian:latest

#########################################
##             SET LABELS              ##
#########################################

# set version and maintainer label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chourmovs <chourmovs@gmail.com>"


#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Set correct environment variables
ENV LC_ALL="en_US.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"
ENV DEBIAN_FRONTEND=noninteractive 

#########################################
##          DOWNLOAD PACKAGES          ##
#########################################

# Download and install Dependencies & Main Software
RUN echo "**** Install Dependencies & Main Software ****" 
RUN pacman -Syu --noconfirm
RUN useradd -ms /bin/bash newuser
RUN pacman -S --noconfirm wget
# RUN pacman -S --noconfirm gtk2 librsvg ocaml-num camlp4 lablgtk2 gd miniupnpc libnatpmp libminiupnpc.so
USER newuser
WORKDIR /home/newuser

RUN wget -O mldonkey-3.1.7.2-2-x86_64.pkg.tar.zst https://dl.rexnvs.com/dl/mldonkey/mldonkey-3.1.7.2-2-x86_64.pkg.tar.zst
USER root
RUN pacman -U --noconfirm mldonkey-3.1.7.2-2-x86_64.pkg.tar.zst

RUN rm -rf \
	/var/lib/apt/lists/* \	
	/tmp/* \
	/var/tmp/* \
	/var/log/mldonkey \
	/var/lib/mldonkey/*

############################
##       COPY & RUN SETUP SCRIPT       ##
#########################################
# copy setup, default parameters and init files
WORKDIR /
COPY service /docker-entrypoint.d
COPY defaults /defaults
RUN ls
# set permissions and run install-service script
RUN chmod -R -v +x /docker-entrypoint.d
# /container/tool/install-service

WORKDIR /docker-entrypoint.d/mldonkey/
ENTRYPOINT ["./install.sh"]

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################

EXPOSE 4000 4001 4080 20562 20566/udp 16965 16965/udp 6209 6209/udp 6881 6882 3617/udp 4444 4444/udp
VOLUME /var/lib/mldonkey /mnt/mldonkey_tmp /mnt/mldonkey_completed

