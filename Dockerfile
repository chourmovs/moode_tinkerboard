FROM navikey/raspbian-bullseye

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
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  systemd systemd-sysv dbus dbus-user-session

RUN apt-get install -y curl sudo libxaw7 ssh
RUN curl -1sLf  'https://dl.cloudsmith.io/public/moodeaudio/m8y/setup.deb.sh' | sudo -E distro=raspbian codename=bullseye arch=armv7hf bash -
RUN apt-get update -y
RUN apt purge ebtables -y
RUN apt-get install-y udisks udisks-glue
RUN apt-get install -y moode-player --fix-broken --fix-missing
RUN apt --fix-broken install
 

#########################################
##       COPY & RUN SETUP SCRIPT       ##
#########################################
# copy setup, default parameters and init files
#WORKDIR /
#COPY /usr/share /usr/share
#COPY defaults /defaults
#RUN ls
# set permissions and run install-service script
#RUN chmod -R -v +x /docker-entrypoint.d
# /container/tool/install-service


#########################################
##         EXPORTS AND VOLUMES         ##
#########################################

EXPOSE 8080
VOLUME /usr/share/moode
