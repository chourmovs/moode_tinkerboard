#########################################
##            NODE.JS STUFF            ##
#########################################
#FROM node:12
#WORKDIR /app
#COPY package.json .
#COPY . .
#RUN npm install


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

RUN apt-get update
RUN apt-get install -y curl

RUN curl -1sLf \
  'https://dl.cloudsmith.io/public/moodeaudio/m8y/setup.deb.sh' \
  | sudo -E bash

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
# VOLUME /moode
