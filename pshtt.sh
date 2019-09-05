#!/bin/bash

#################################################
# Install and Setup PSHTT
# Joshua Harvey | September 2019
# josh[at]macjeezy.com
#################################################

### Variables
PSHTT_HOME="/home/$USER/pshtt-develop"
PSHTT_TEMP="/tmp/PSHTT"

if [[ ! -d "$PSHTT_TEMP" ]]; then
    mkdir "$PSHTT_TEMP"
fi

echo "Starting PSHTT download.."
# Download PSHTT and unzip it
if [[ ! -f "/home/$USER/develop.zip" ]]; then
    echo "Downloading PSHTT"
    wget https://github.com/dhs-ncats/pshtt/archive/develop.zip -o /home/$USER/develop.zip
    unzip /home/$USER/develop.zip
else
    echo "PSHTT Files Found"
fi

# Build docker container
echo "Starting to build docker container"
docker build -t pshtt "$PSHTT_HOME"

echo "Build Complete..."

COUNT_HOSTS=$(cat /home/$USER/hosts.txt | wc -l)

CHECK_HOSTS=$(cat /home/$USER/hosts.txt)
if [[ -z "$CHECK_HOSTS" ]]; then
    echo "Missing List of Hosts. Please enter them in /home/$USER/hosts.txt, then run the script again"
    echo "Use nano /home/$USER/hosts.txt to open the file and paste or enter the hosts in"
    exit 1
else
    echo "Starting PSHTT Scan for $COUNT_HOSTS hostnames"
fi

while read input; do
    echo "Scanning $input"
    docker run pshtt "$input" -j --output="$input".json &> /dev/null
    GET_RESULTS=$(sudo find /var/lib/docker/overlay2/ -iname "$input".json)
    sudo cp "$GET_RESULTS" "$PSHTT_TEMP"/
    sudo chmod 0755 "$PSHTT_TEMP"/"$input".json
done < /home/$USER/hosts.txt

echo "Compressing Results"
tar -zcvf /tmp/pshtt_results.tar "$PSHTT_TEMP"

echo "Results saved at /tmp/pshtt_results.tar and ready for download."

echo "" > /home/$USER/hosts.txt

rm -rf "$PSHTT_TEMP"/*
