#!/bin/bash

# Check if this script was run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Install Docker
apt-get remove docker docker-engine docker.io containerd runc -y
apt-get update
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io -y

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Reload bashrc
source ~/.bashrc

# Download files
mkdir ~/docker
mkdir ~/docker/traefik
mkdir ~/docker/shared
curl -L "https://raw.githubusercontent.com/mepples21/gtpdockerserver/master/docker-compose.yml" -o ~/docker/docker-compose.yml
curl -L "https://raw.githubusercontent.com/mepples21/gtpdockerserver/master/traefik.toml" -o ~/docker/traefik/traefik.toml

# Setup domain and certificate
read -e -p "Enter the domain you'd like to use, e.g., 'contoso.com': " domain
read -e -p "Enter the path to your certificate pfx file, e.g., '/home/user1/cert.pfx' or '~/cert.pfx': " certpath
echo $domain
echo $certpath
sed 's/${DOMAIN}/'"$DOMAIN"'/g' ~/docker/docker-compose.yml
sed 's/${DOMAIN}/'"$DOMAIN"'/g' ~/docker/traefik/traefik.toml