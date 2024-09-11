GodsEye 4.0
------------------
!!!! The tool is a public version for pentesting cameras. Private Version with additional features exists (see bottom of this readme)  !!!!
                             
                        

GodsEye ( Public ) is a tool to pentest camera feeds on an IP address.

Explaining GodsEye's functionality:

1) enter the ip address you wish to test.

4) A shodan search is initiated, the results are tee'd to a text file

5) A seperate terminal is opened, anonymous mode is started so all camera feeds run through tor
and nyx is launched so tor traffic can be observed.

6) Http connection tests run against all addresses 
(Some authention bypass endpoints are included in the Http checks). 
If the http connection check fails a RTSP check will be preformed on that address. If the RTSP check 
fails the address is tee'd to a text file . This means the camera feed most likely requires authentication. 
Authentication checks run against each address. A password dictionary attack runs against these addresses with a default camera credentials 
password dictionary. This dictionary can be edited. Every 2 failed attempts the tor circuit is switched before more attempts are made. If any
feeds do not authenticate with default credentials they are tee'd to another text file. These addresses are now used to attempt to get config files 
from the camera in an attempt to grep usernames and passwords to create a new password dictionary. If this is successful one last dictionary password
attack runs against these last remaining addresses. User-agent spoofing is used from start to finish.

7) Connected/authenticated feeds are opened in individual firefox windows. Connected RTSP feeds open via VLC media player.

   You are asked how many feeds you want = max cameras to look for on a single address.



-----------------------------------
Helpful Tips
-------------------------------------
Shodan will not allow you to preform a search if tor is running (this is why tor starts after the shodan search)

After using GodsEye remember to turn off anonymous mode which also turns off Tor. 

The command to do this is

sudo anonsurf stop

To check the status of anonymous mode the command is

sudo anonsurf status

You can edit the shodan search string in the script per your pentest needs.

---------------------------------------------------
Requirements [ install-depends.sh should install all , you may need to install vlc ]
----------------------------------------------------

Shodan account with Api key (Replace SHODANAPIKEY with your Api key in install-depends.sh) 

ANONSURF mode

Firefox browser 

nyx ( cli Tor traffic monitor )

qterminal

vlc media player

netcat

curl

---------------------------------------------------
Install GodsEye 4.0
---------------------------------------------------

GodsEye should install easy and run good on Kali Linux

It should also work on other linux distrbutions but may need addition dependency installs

1) Open install-depends.sh with a text editor

2) 

  A) Modify line 4 and replace SHODANAPIKEY with your Shodan Api key

  B) Save and run install-depends.sh with the command "sudo ./install-depends.sh"
  
  

--------------------------------------------------------
Additional Knowledge
_______________________________________________________

You can add additional suffixes to suffixes.txt

You can add additional default credential sets to credentials.txt 

The credentials.txt format is username:password

----------------------------------------------------------------
Private code contains:


1) World view = This searches globally for camera feeds
  
2) Country view = This searches a entire country
  
3) State view = This searches an entire state
  
4) City view = This searches an entire city
    
5) Feed dropper

6) Feed Loop Attack

7) Passive View Mode

8) Camera feed recorder and downloader

9) Telnet and SSH backdoor check-create-connect function

10) Metasploit function = Dynamic Metasploit automation against all targets.

11) Coordinates and radius option with all functions and modes except Big Brother

These features are intended for much larger engagements and operations. 
Interested in obtaining these features? Contact me via linkedin.
------------------------------------------------------------------------


If you like my work and would like to support it or just buy me a beer here is my paypal.

Currently unemployed and seeking employment. 

Have a tool idea, Inquire about me coding it for you.

Donations help and are appreciated.

![paypal](https://github.com/user-attachments/assets/c9206ff2-76bd-4c1e-9998-3f8f4ad690e4)





DISCLAIMER: this tool is intended for educational purposes, and camera penetration testing only. 
Performing hacking attempts on computers that you do not own (without permission) is illegal!
Do not attempt to gain access to device that you do not own.








