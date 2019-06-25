#!/bin/bash

#################################################
# Install and Setup PSHTT
# Joshua Harvey | June 2019
# josh[at]macjeezy.com
#################################################

echo "Starting PSHTT download.."
# Download PSHTT and unzip it
wget https://github.com/dhs-ncats/pshtt/archive/develop.zip
unzip develop.zip

# Change directory to pshtt-develop 
cd pshtt-develop

# Build docker container
echo "Starting to build docker container"
docker build -t pshtt .

echo "build complete"

echo "creating scanning script"
cat > ./pshtt-develop/start.sh << 'SCRIPT'
#!/bin/bash
HOSTNAME="$1"
docker run pshtt "$HOSTNAME" -j --output="$HOSTNAME".json
GET_RESULTS=$(sudo find /var/lib/docker/overlay2/ -iname "$HOSTNAME".json)
sudo cp "$GET_RESULTS" /tmp/
sudo chmod 0755 /tmp/"$HOSTNAME".json
echo "---------------"
echo "---------------"
echo "download the results using /tmp/"$HOSTNAME".json"
echo "---------------"
echo "---------------"
SCRIPT

chmod 0755 ./pshtt-develop/start.sh

echo "to use the script do the following"
echo "./start.sh <hostname>"
