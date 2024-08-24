GodsEye 4.0
------------------

GodsEye ( Gods Eye ) is a cyber warfare tool to access camera feeds in a selected country, state or city anywhere in the world.
Explaining GodsEye's functionality:

1) You must select a view mode, there are 4:
  A) World view = This searches globally for camera feeds
  B) Country view = This searches a entire country
  C) State view = This searches an entire state
  D) City view = This searches an entire city
  
2) The selection you make (unless it's world view) is ran against a database of all countries, states and cities in the world to 
select and use the the correct abbreviation in the shodan search string. The database file is locations.csv . You create the csv
file with generate_locations.py . 

3) A shodan search is initiated, the results are tee'd to a text file in the format of [address:port]

4) A seperate terminal is opened, anonymous mode is started so all camera feeds run through tor
and nyx is launched so tor traffic can be observed.

5) Now the list of addresses (one by one) runs against a list of camera address suffixes 
(the part of the web address that tails the port number) (also one by one) until the feed is opened.

6) After every address runs against every suffix the addresses that successfully connected are opened 
in individual firefox windows.

The default address limit is set to 20 in the shodan search strings but can be adjusted to whatever number you want.
to do this modify "--limit 20" in lines 22-33-44-57

The shodan string itself can also be modified with different or additional filters and tags
The current string pulls 26,641 possible camera feeds globally.

-----------------------------------
Helpful Tips
-------------------------------------
Shodan will not allow you to preform a search if tor is running (this is why tor starts after the shodan search)
After using GodsEye remember to turn off anonymous mode which also turns off Tor. The command to do this is

sudo anonsurf stop

To check the status of anonymous mode the command is

sudo anonsurf status

---------------------------------------------------
Requirements [ install-depends installs them all ]
----------------------------------------------------
Shodan account with Api key (Replace SHODANAPIKEY with your Api key in install-depends.sh) 
ANONSURF mode
Firefox browser 
nyx ( cli Tor traffic monitor )
qterminal

---------------------------------------------------
Install GodsEye 4.0
---------------------------------------------------

GodsEye should install easy and run good on Kali Linux
It should also work on other linux distrbutions but may need addition dependency installs

1) Open install-depends.sh with a text editor
  A) Modify line 4 and replace SHODANAPIKEY with your Shodan Api key
  B) Save and run install-depends.sh with the command "sudo ./install-depends.sh"
  C) Run the command "python generate_locations.py to generate the global database

--------------------------------------------------------
Additional Knowledge
_______________________________________________________

generate_locations.py generates a CSV file with all country, state and city names in the world.
The format is [country,state,city,abbreviation]
There are two letter abbreviations for both countries and states but the abbreviations for 
cities are actually their full names as this is how shodan accepts city filters. The csv file is
to large to open Officelibre Calc. You can add additional suffixes to suffixes.txt but one line must
be left blank, this is intentional as the suffix here is no suffix.

This was build for a workstation with multiple screens.

---------------------------------------------------------
To Do's
---------------------------------------------------------
Add a feature to deal with authentication

Add a feature to knock out feeds

Add a feature to handle RTSP feeds

Improve the search string to have a higher possible number of feeds

Add https support
----------------------------------------------------------------

If you like my work and would like to support it or just buy me a beer here is my paypal.















