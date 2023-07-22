FROM balenalib/asus-tinker-board-debian:latest-build

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
#ENV DEBIAN_FRONTEND=noninteractive 

# Copie le binaire shell Bash depuis une autre image
COPY --from=alpine:latest /bin/bash /bin/bash

# Définit /bin/bash comme shell par défaut pour l'image
SHELL ["/bin/bash", "--login", "-c"]

# Commande par défaut pour lancer un shell interactif
CMD ["/bin/bash"]

#########################################
##          DOWNLOAD PACKAGES          ##
#########################################

# Download and install Dependencies & Main Software

#SHELL ["/bin/bash", "-c"]
RUN echo "**** Install Dependencies & Main Software ****" 
RUN apt update
RUN apt upgrade
RUN apt install git php-fpm nginx mpd alsa-utils php-curl php-gd php-mbstring php-json
# RUN pacman -S --noconfirm gtk2 librsvg ocaml-num camlp4 lablgtk2 gd miniupnpc libnatpmp libminiupnpc.so
USER newuser
WORKDIR /home/newuser

#RUN wget -O mldonkey-3.1.7.2-2-x86_64.pkg.tar.zst https://dl.rexnvs.com/dl/mldonkey/mldonkey-3.1.7.2-2-x86_64.pkg.tar.zst
#USER root
#RUN pacman -U --noconfirm mldonkey-3.1.7.2-2-x86_64.pkg.tar.zst

RUN git clone https://github.com/moode-player/moode.git
WORKDIR /moode
RUN ./install.sh

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

#WORKDIR /docker-entrypoint.d/moode/
#ENTRYPOINT ["./install.sh"]

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################

EXPOSE 8080
# VOLUME /var/lib/mldonkey /mnt/mldonkey_tmp /mnt/mldonkey_completed

