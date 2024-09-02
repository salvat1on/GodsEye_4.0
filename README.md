GodsEye 4.0
------------------
!!!! The tool is now private with added features and more in the works. This repo serves as a way to inquire about GodsEye !!!!
                             
                        

GodsEye ( Gods Eye ) is a tool to access camera feeds in a selected country, state or city anywhere in the world.

Explaining GodsEye's functionality:

1) You must select a mode, there are 8:

    A) World view = This searches globally for camera feeds
  
    B) Country view = This searches a entire country
  
    C) State view = This searches an entire state
  
    D) City view = This searches an entire city

    E) Feed Drooper = Camera Crash/Reboot Attack

    F) Feed Loop Attack = Loop camera feeds like in the movies.

    G) Single Target = Target a single IP address.

    H) Passive View = View camera feeds that require no authentication

    I) Big Brother = Camera feed recorder and downloader
  
3) The selection you make (unless it's world view) is ran against a database of all countries, states and cities in the world to 
select and use the the correct abbreviation in the shodan search string.

4) A shodan search is initiated, the results are tee'd to a text file in the format of [address:port]

5) A seperate terminal is opened, anonymous mode is started so all camera feeds run through tor
and nyx is launched so tor traffic can be observed.

6) Http connection tests run against all addresses 
(Some authention bypass endpoints are included in the Http checks). 
If the http connection check fails a RTSP check will be preformed on that address. If the RTSP check 
fails the address is tee'd to a text file . This means the camera feed most likely requires authentication. 
Authentication checks run against each address. Addresses that require authentication are tee'd to 
another text file. A password dictionary attack runs against these addresses with a default camera credentials 
password dictionary. This dictionary can be edited. If any feeds do not authenticate 
with default credentials they are tee'd to another text file. These addresses are now used to attempt to get config files 
from the camera in an attempt to grep usernames and passwords to create a new password dictionary. If this is successful 
one last dictionary password attack runs against these last remaining addresses.

7) Connected/authenticated feeds are opened in individual firefox windows. Connected RTSP feeds open via VLC media player.

     The default feed limit is set to 20. You are now asked how many feeds you want. 

     The shodan string itself can also be modified with different or additional filters and tags


-----------------------------------
Helpful Tips
-------------------------------------
Shodan will not allow you to preform a search if tor is running (this is why tor starts after the shodan search)

After using GodsEye remember to turn off anonymous mode which also turns off Tor. 

The command to do this is

sudo anonsurf stop

To check the status of anonymous mode the command is

sudo anonsurf status


----------------------------------------------------------------
Private code contains:

1) RSTP checks and functionality

2) Authentication checks

3) Dictionary password attacks on addresses that need authentication

4) Feed dropper

5) Feed Loop Attack

6) Single Target capability

7) Passive View Mode

8) Camera feed recorder and downloader

These features are the reason this code will not be released on GitHub.
------------------------------------------------------------------------


If you like my work and would like to support it or just buy me a beer here is my paypal.

![paypal](https://github.com/user-attachments/assets/c9206ff2-76bd-4c1e-9998-3f8f4ad690e4)





DISCLAIMER: this tool is intended for educational purposes and awareness training sessions only.








