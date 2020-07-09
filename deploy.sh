#!/bin/bash

# Check if this script was run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

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

# Install Docker Compose
if [ ! -f "/usr/local/bin/docker-compose" ]; then
    curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo "Docker Compose is already installed."
fi

# Reload bashrc
source ~/.bashrc

# Download files
if [ ! -d ~/docker ]; then
    mkdir ~/docker
    mkdir ~/docker/traefik
    mkdir ~/docker/shared
else
    echo "Directories already exist."
fi
echo "Downloading latest version of config files"
curl -L "https://raw.githubusercontent.com/mepples21/gtpdockerserver/master/docker-compose.yml" -o ~/docker/docker-compose.yml
curl -L "https://raw.githubusercontent.com/mepples21/gtpdockerserver/master/traefik.toml" -o ~/docker/traefik/traefik.toml

# Setup domain in config files
read -e -p "Enter the domain you'd like to use, e.g., 'contoso.com': " domain
sed -i 's|${DOMAINNAME}|'$domain'|g' ~/docker/docker-compose.yml
sed -i 's|${DOMAINNAME}|'$domain'|g' ~/docker/traefik/traefik.toml

# Setup certificates and update config files
read -e -p "Enter the path to your certificate pfx file, e.g., '/home/user1/cert.pfx' or '~/cert.pfx': " certpath
read -e -p "Enter the password for your pfx certificate file: " certpassword
openssl pkcs12 -in $certpath -password pass:$certpassword -clcerts -nokeys -out ~/docker/shared/certificate.crt
openssl pkcs12 -in $certpath -password pass:$certpassword -nocerts -nodes -out ~/docker/shared/certificatekey.key

# Deploy containers
docker network create web
docker-compose -f ~/docker/docker-compose.yml up -d