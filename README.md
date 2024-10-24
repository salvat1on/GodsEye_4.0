![godseye](https://github.com/salvat1on/GodsEye_4.0/blob/main/godsEye.png)
-----------------
GodsEye 4.0
------------------
!!!! The tool is a public version for pentesting cameras. Private Version with additional features exists (see bottom of this readme)  !!!!
                             
                        

GodsEye ( Public ) is a tool to pentest camera feeds on an IP address


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


----------------------------------------------------------------
Private code contains:


1) World view = This searches globally for camera feeds
  
2) Country view = This searches a entire country
  
3) State view = This searches a entire state
  
4) City view = This searches a entire city
    
5) Feed dropper

6) Feed Loop Attack

7) Passive View Mode

8) Camera feed recorder and downloader

9) Telnet and SSH backdoor check-create-connect function

10) Metasploit Dynamic exploitation function 

11) Coordinates and radius option with all functions and modes except Big Brother

These features are intended for much larger engagements and operations. 
Interested in obtaining these features (AKA a private copy)? Contact me via linkedin or @ redteam.security@protonmail.ch and make a donation to the project.
By making a minimum donation 75$ you receive a private copy, updates by email when they occur for now and your feedback helps to improve newer versions.

------------------------------------------------------------------------


If you like my work and would like to support it or just buy me a beer here is my paypal. 

Have a tool idea, Inquire about me coding it for you.

Donations help advance the tool and are appreciated.

![paypal](https://github.com/user-attachments/assets/c9206ff2-76bd-4c1e-9998-3f8f4ad690e4)





DISCLAIMER: this tool is intended for educational purposes, and camera penetration testing only. 
Performing hacking attempts on computers that you do not own (without permission) is illegal!
Do not attempt to gain access to device that you do not own.








