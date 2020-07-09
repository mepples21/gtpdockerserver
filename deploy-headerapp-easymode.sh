#!/bin/bash

# Check if this script was run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Create config file
touch ~/deploy_config

# Install Docker
if [ -x "$(command -v docker)" ]; then
    echo "Docker is already installed."
else
    apt-get remove docker docker-engine docker.io containerd runc -y
    apt-get update
    apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io -y
fi

# Deploy containers
docker run --name headerapp -d -p 8085:8085 mepples21/headerapp
docker ps -a