#!/bin/bash
#
# Looks up docker image by name, gets IP address,
# then checks if we can do ntp client query against it
#

if [ $# -lt 2 ]; then
  echo "Usage: imageName exposedPort"
  echo "Example: ntpdate-bionic 1123"
  exit 1
fi
imagename="$1"
exposedport=$2
echo "imagename is $imagename with exposed port: $exposedport"

# get IP address of docker image
IP=$(docker inspect $(docker ps -f "name=$imagename" --format "{{.ID}}") --format '{{ range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
if [ -z "$IP" ]; then
  echo "ERROR could not find IP address of container $imagename"
  exit 2
fi

# ntpdate needs to be installed
#if [ ! -x "$(command -v ntpdate)" ]; then
#  echo "ERROR could not find ntpdate binary, try 'sudo apt-get install ntpdate'"
#  exit 3
#fi

# keep running ntpctl in loop
echo "Running ntpdate against $IP at port $exposedport...."
while : ; do
  status=$(docker exec -it $imagename ntpctl -s status)
  echo $status
  echo $status | grep -vq "unsynced"
  if [ $? -eq 0 ]; then 
    echo "SUCCESS! ntp server returned a validated response"
    break
  else
    echo "WARNING did not receive validated response from ntp server."
    echo "An ntp server can take 10+ minutes to contact its pool and synchronize. Trying again in 30 seconds..."
    echo "============================="
    sleep 30
  fi
done
