#!/bin/bash

apt install python3-shodan python3pyshodan qterminal -y
shodan init SHODANAPIKEY
pip install nyx geopy pycountry geonamescache
git clone https://github.com/Und3rf10w/kali-anonsurf.git
chmod 755 -R kali-anonsurf/
cd kali-anonsurf
./installer.sh
   
#exit



