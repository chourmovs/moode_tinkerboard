FROM balenalib/asus-tinker-board-debian:latest-build
FROM ubuntu:latest AS Builder

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

#SHELL ["/bin/bash", "-c"]
RUN echo "**** Install Dependencies & Main Software ****" 
RUN apt-get update
RUN apt-get upgrade 
RUN apt-get install --no-install-recommends -y git php-fpm nginx mpd alsa-utils php-curl php-gd php-mbstring php-json
RUN apt-get install --no-install-recommends -y apt-transport-https ca-certificates libgnutls30

#USER newuser
#WORKDIR /home/newuser

RUN git clone https://github.com/moode-player/moode.git
RUN git clone https://github.com/moode-player/pkgbuild.git
WORKDIR /pkgbuild/packages/moode-player
RUN ls
RUN chmod -R -v +x /pkgbuild/packages/moode-player
RUN ./build.sh
RUN ./postinstall.sh

#########################################
##       COPY & RUN SETUP SCRIPT       ##
#########################################
# copy setup, default parameters and init files
#WORKDIR /
#COPY service /docker-entrypoint.d
#COPY defaults /defaults
#RUN ls
# set permissions and run install-service script
#RUN chmod -R -v +x /docker-entrypoint.d
# /container/tool/install-service

WORKDIR /docker-entrypoint.d/moode/
ENTRYPOINT ["./install.sh"]

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################

EXPOSE 8080
# VOLUME /var/lib/mldonkey /mnt/mldonkey_tmp /mnt/mldonkey_completed

