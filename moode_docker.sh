#!/bin/bash

printf "\ec"
echo ""
echo "****************************************************"
echo "*    Moode on tinkerboard Armv7l install script     "
echo "*             By chourmovs v 1.0                    "
echo "****************************************************"
echo ""

echo "TIP when using nano command during the recipe, diplace in the openened file with arrow, change what you need simply with your keyboard," 
echo "save/exit with [CTRL+X], [y] to confirm, [enter] to overwrite, that's it !"
echo ""
sleep 3

if [ "$(uname -m)"  == "armv7l" ]
  then
	echo "Tinkerboard detected, This script will launch"
  echo ""
  else
    echo "This script is for armv7l only"
    exit 1
fi

sleep 3
echo ""
echo "**************************************"
echo "*     install docker (host side)      "
echo "**************************************"
echo ""


sudo apt update -y
sudo apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=armhf] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt update -y
sudo apt install -y docker-ce
sleep 3
sudo usermod -aG docker $USER

sleep 3
echo ""
echo "******************************************************************************"
echo "*      Optional - Prepare Alsa just in case of external DAC (host side)      *"
echo "******************************************************************************"
echo ""
echo "comment the last line with #, it will modify the order of soundcard in ALSA to make it moode compatible"
echo "like this:	#options snd-usb-audio index=1,5 vid=0x0bda pid=0x481a"
echo ""


while true; do

read -p "Do you want to proceed? note: it will change card order (y/n) " yn

case $yn in 
	[yY] ) echo ok, we will proceed;
 
        sudo nano /etc/modprobe.d/alsa-base.conf;
        while pgrep -u root nano > /dev/null; do sleep 1; done;
 
		break;;
	[nN] ) echo exiting...;
		break;;
	* ) echo invalid response;;
esac

done


	
echo ""
echo "*************************************************************************************"
echo "*      Optional - If you want to use your device as bluetooth receiver (host side)  *"
echo "*************************************************************************************"
echo ""



while true; do

read -p "Do you want to proceed? note: Bluetooth will be available for moode only (y/n) " yn

case $yn in 
	[yY] ) echo ok, we will proceed;
 
        sudo systemctl stop bluetooth.service;
 
		break;;
	[nN] ) echo exiting...;
		break;;
	* ) echo invalid response;;
esac

done



echo ""
echo "************************************************************************************"
echo "*      Optional - If you want an exlusive access to MPD on port 6600 (host side)   *"
echo "************************************************************************************"
echo ""

while true; do

read -p "Do you want to proceed? note: Playing from moode will not be possible anymore but it allow radios from moode (y/n) " yn

case $yn in 
	[yY] ) echo ok, we will proceed;
 
        sudo systemctl stop mpd.service;
        sudo systemctl stop mpd.socket;
        sudo systemctl disable mpd.service;
        sudo systemctl disable mpd.socket;

 
		break;;
	[nN] ) echo exiting...;
		break;;
	* ) echo invalid response;;
esac

done


sleep 2
echo ""
echo "************************************************************************"
echo "*    create container with systemd in priviledged mode and start it    *"
echo "************************************************************************"
echo ""
docker volume create moode
sudo chown volumio /var/lib/docker/volumes

docker create --name debian-moode -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /mnt/NAS:/mnt/NAS -v moode:/boot:rw --device /dev/snd --net host --privileged -e LANG=C.UTF-8 --cap-add=NET_ADMIN --security-opt seccomp:unconfined navikey/raspbian-bullseye /lib/systemd/systemd

docker container start debian-moode
#'docker exec -ti debian-moode /bin/bash    *with this command you enter the container with a console*

echo ""
echo "*********************************************"
echo "*    install moode player (container side)  *"
echo "*********************************************"
echo ""
docker exec -ti debian-moode /bin/bash -c "apt-get update -y ; sleep 3 ; apt-get upgrade -y"
docker exec -ti debian-moode /bin/bash -c "apt-get install -y curl sudo libxaw7 ssh libsndfile1 libsndfile1-dev"


echo "With nano, change ssh port to 2222 and fix openssh"
sleep 4
docker exec -ti debian-moode /bin/bash -c "sudo nano /etc/ssh/sshd_config" 
while docker exec -ti debian-moode /bin/bash -c "pgrep -u root nano" > /dev/null; do sleep 1; done
docker exec -ti debian-moode /bin/bash -c "sudo service sshd restart"


docker exec -ti debian-moode /bin/bash -c "curl -1sLf  'https://dl.cloudsmith.io/public/moodeaudio/m8y/setup.deb.sh' | sudo -E distro=raspbian codename=bullseye arch=armv7hf bash -"
docker exec -ti debian-moode /bin/bash -c "apt-get update -y |apt-get install moode-player -y --fix-missing"
echo "In general this long install return error, next move will try to fix this"
sleep 4
docker exec -ti debian-moode /bin/bash -c "apt --fix-broken install"
docker exec -ti debian-moode /bin/bash -c "exit"       

echo ""
echo "****************************************"
echo "*    restart moode player (host side)  *"
echo "****************************************"
echo ""
docker container stop debian-moode
docker container start debian-moode

echo ""
echo "***************************************"
echo "*    configure nginx (container side) *"
echo "***************************************"
echo ""
echo "With nano, change moode http port to 8008 to avoid conflict with volumio front"
sleep 4
docker exec -ti debian-moode /bin/bash -c "nano /etc/nginx/sites-available/moode-http.conf"  
while docker exec -ti debian-moode /bin/bash -c "pgrep -u root nano" > /dev/null; do sleep 1; done

docker exec -ti debian-moode /bin/bash -c "systemctl restart nginx"

echo ""
echo "****************************"
echo "*    Access Moode web UI   *"
echo "****************************"
echo ""
echo "http://volumio:8008"
echo ""
echo "Enjoy"

