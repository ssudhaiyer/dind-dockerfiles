#!/bin/bash

# pull maven image for simulating builds  
# this should get executed by the dind container
docker pull maven:3.5.3-jdk-10-slim

# set ssh keys to access github.com
# this will be done once at the start of container. 
# Git secrets are assumed to be mounted in this location
# the other option is for the sidecar to sync these from vault and store it in /etc/git-secret
echo "Setting up git SSH creds"
pathToSSHSecret="/etc/git-secret/ssh"
pathToSSHKnownHosts="/etc/git-secret/known_hosts"
if [ ! -f "$pathToSSHSecret" ]
then
    echo "File $pathToSSHSecret not found"
    exit 1
fi

if [ ! -f "$pathToSSHKnownHosts" ]
then
    echo "File $pathToSSHKnownHosts not found"
    exit 1
fi

mkdir /root/.ssh
chmod 700 /root/.ssh
cp /etc/git-secret/ssh /root/.ssh/id_rsa
cp /etc/git-secret/known_hosts /root/.ssh/known_hosts
chmod 600 /root/.ssh/id_rsa
chmod 644 /root/.ssh/known_hosts

# this is the common workspace shared between dind and service container
cd /builds

if [ -d /builds/delivery ]; then
    rm -rf /builds/delivery
fi

# simulate customer repo
git clone git@github.com:ssudhaiyer/delivery.git

cd /builds/delivery

cat README.md

docker run --rm --name my-maven-project -v "$(pwd)":/builds -w /builds maven:3.5.3-jdk-10-slim mvn clean install -DskipTests

echo "build exit status " $?
