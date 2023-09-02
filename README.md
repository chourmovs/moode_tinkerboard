# Moode_tinkerboard

This bash script will allow you to setup a full fontionnal moode-player over volumio on ASUS tinkerboard.  

#### It will also detect and work on every armv7l machine running a "docker capable" linux.  

All the process is automated but you will have to modify certain parameters (i.e port) using [Nano](https://www.hostinger.co.uk/tutorials/how-to-install-and-use-nano-text-editor#How_to_Use_Nano_Text_Editor) during the process.    
&nbsp;  &nbsp;  

# What you get 
```
  ###   is working
 - UI and artworks without any restriction ( First time it's slow when building library)
 - MPD access to host /mnt/partition
 - playing any codecs tested (flac, AAV, mp3)
 - Wifi, ethernet, bluetooth
 - Radios
 - Equalizer, parametric equalizer  
  
  ###   is not working
  - Camilla DSP
  - you tell me  
```
# Prerequisite

- Armv7l machine running any linux distribution like Debian<p>
- #### On Volumio [primo](https://volumio.github.io/docs/User_Manual/SSH.html) , ensure that your ssh key is registred in known host (to do that you will need to ssh login a second time since first login don't do it properly)
- A terminal to ssh (my preference go to Mobaxterm)    
&nbsp;  &nbsp;  

# Installation

in a ssh terminal lauch following command
```
bash <(curl -Ls https://rb.gy/fiao0)

```

And follow the instructions...    
&nbsp;  &nbsp;  

# Troubleshoot

Q : My share can't mont &nbsp;  &nbsp;   
A : try to edit path manually in Library/host and remove any option in Library/advanced/mount options (leave it blank and save)

Q : Moode can't browse my mounted share  &nbsp; &nbsp;   
A : restart MPD in Configure/Audio/MPD section, then Configure/library/Music Database/Regenerate      

Q : Access moodeOS console   
A : in your host ssh console put <b>"sudo docker exec -ti debian-moode /bin/bash"</b>   

# Changelog
```
08.05.23 v1.0 initial release
08.18.23 v1.1 replace nano interraction by proper "sed" find&replace command
              Change moode-player install sequence to fix it
08.30.23 v1.3 Fix installer script
              Next moves will be done via dev branch
```            
    

# To follow and discuss

https://chourmovs.wixsite.com/blog/en/post/install-moode-in-a-docker-container-on-volumio-primo-asus-tinkerboard-armv7l


