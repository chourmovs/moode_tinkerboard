#!/bin/bash

printf "\ec"
echo ""
echo "****************************************************"
echo "*    Moode on tinkerboard Armv7l install script    *"
echo "*             By chourmovs v 1.3                   *"
echo "****************************************************"
echo ""
echo ""
sleep 3

if [ "$(uname -m)"  == "armv7l" ]
  then
	echo "Tinkerboard detected, This script will launch"
  echo ""
  else
    echo "This script is for armv7l only, it will now exit"
    exit 1
fi

sleep 3
echo ""
echo "**************************************"
echo "*     install docker (host side)     *"
echo "**************************************"
echo ""


sudo apt update -y
sudo apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common screen
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=armhf] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt update -y
sudo apt install -y docker-ce

sleep 3
echo ""
echo "******************************************************************************"
echo "*      Optional - Prepare Alsa just in case of external DAC (host side)      *"
echo "******************************************************************************"
echo ""
echo "will comment the last line with #, it will modify the order of soundcard in ALSA to make it moode compatible"
echo "like this:	#options snd-usb-audio index=1,5 vid=0x0bda pid=0x481a"
echo ""

while true; do
read -p "Do you want to proceed? note: it will change primo's default card order (y/n) " yn
case $yn in 
	[yY] ) echo ok, we will proceed;
 		sudo sed -i 's/option/#option/g' /etc/modprobe.d/alsa-base.conf;
   		sudo sed -i 's/##option/#option/g' /etc/modprobe.d/alsa-base.conf;
     		sudo systemctl restart alsa-state.service
       		sudo systemctl restart sound.target
   		break;;
	[nN] ) echo exiting...;
		break;;
	* ) echo invalid response;;
esac
done
	
echo ""
echo "*************************************************************************************"
echo "*    Optional - If you want to use your device as bluetooth receiver (host side)    *"
echo "*************************************************************************************"
echo ""


while true; do
read -p "Do you want to proceed? note: Bluetooth will be available for moode but no more for volumio (y/n) " yn
case $yn in 
	[yY] ) echo ok, we will proceed;
         sudo systemctl stop bluetooth.service;
	 sudo systemctl disable bluetooth.service;
  	 sudo systemctl mask bluetooth.service;
 		break;;
	[nN] ) echo exiting...;
		break;;
	* ) echo invalid response;;
esac
done


echo ""
echo "********************************************************************************************"
echo "*   Optional - If you want Moode to get an exlusive access to vital service MPD,CIFS,NFS   *"
echo "********************************************************************************************"
echo ""

while true; do
read -p "Do you want to proceed? note: Playing from volumio won't be possible anymore but it allow radios and MPD control from moode (y/n) " yn
case $yn in 
	[yY] ) echo ok, we will proceed;
        sudo systemctl stop mpd.service mpd.socket nfs-client.target smbd.service 
	sudo systemctl disable mpd.service mpd.socket nfs-client.target smbd.service 
	sudo systemctl mask mpd.service mpd.socket nfs-client.target smbd.service 
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
# sudo mkdir /home/moode && sudo chown volumio:volumio /home/moode && sudo chmod 777 /home/moode
sudo docker volume create moode
# sudo chown -R volumio /var/lib/docker/

sudo docker create --name debian-moode --restart always -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v moode:/mnt/NAS --device /dev/snd --net host --privileged -e LANG=C.UTF-8 --cap-add=NET_ADMIN --security-opt seccomp:unconfined --cpu-shares=10240 navikey/raspbian-bullseye /lib/systemd/systemd

sudo docker container start debian-moode

echo ""
echo "*********************************************"
echo "*    install moode player (container side)  *"
echo "*********************************************"
echo ""
sudo docker exec -ti debian-moode /bin/bash -c "apt-get update -y ; sleep 3 ; apt-get upgrade -y"
sudo docker exec -ti debian-moode /bin/bash -c "apt-get install -y curl sudo libxaw7 ssh libsndfile1 libsndfile1-dev cifs-utils nfs-common"
sudo docker exec -ti debian-moode /bin/bash -c "apt --fix-broken install -y"

echo ""
echo ""
echo "Willchange ssh port to 2222 to fix openssh"
echo ""
echo ""
sleep 2

sudo docker exec -ti debian-moode /bin/bash -c "sudo sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config;"
sudo docker exec -ti debian-moode /bin/bash -c "systemctl restart sshd"
sudo docker exec -ti debian-moode /bin/bash -c "curl -1sLf  'https://dl.cloudsmith.io/public/moodeaudio/m8y/setup.deb.sh' | sudo -E distro=raspbian codename=bullseye arch=armv7hf bash -"
sudo docker exec -ti debian-moode /bin/bash -c "apt-get update -y | apt-get install moode-player -y --fix-missing"
echo ""
echo ""
echo "In general this long install return error, next move will try to fix this"
sleep 2
echo ""


sudo docker exec -ti debian-moode /bin/bash -c "apt --fix-broken install -y"
sleep 2
sudo docker exec -ti debian-moode /bin/bash -c "apt-get install moode-player -y --fix-missing"
sleep 2
sudo docker exec -ti debian-moode /bin/bash -c "apt upgrade -y"
#sleep 2
sudo docker exec -ti debian-moode /bin/bash -c "exit"       

echo ""
echo "****************************************"
echo "*    restart moode player (host side)  *"
echo "****************************************"

sudo docker container stop debian-moode
sudo docker container start debian-moode

echo ""
echo ""
echo "***************************************"
echo "*    configure nginx (container side) *"
echo "***************************************"
echo ""
echo "Will change moode http port to 8008 to avoid conflict with volumio front"
echo ""
echo ""
sleep 2
sudo docker exec -ti debian-moode /bin/bash -c "sudo sed -i 's/80 /8008 /g' /etc/nginx/sites-available/moode-http.conf"
sudo docker exec -ti debian-moode /bin/bash -c "systemctl restart nginx"

echo ""
echo "****************************"
echo "*    Access Moode web UI   *"
echo "****************************"
echo ""
echo "Your device will now restart"
echo ""
echo ""
echo "CTRL+CLIC on http://volumio:8008"
echo ""
echo "Enjoy"
# sudo reboot

