#!/bin/bash
set -e
echo "*****    Installing SHR    *****"
# Create a folder
# Update instance
# Install latest version of git

apt update
apt install -y nginx
add-apt-repository ppa:git-core/ppa -y
apt install -y git

apt install -y unzip
apt install -y nginx
# Install and setup docker


mkdir actions-runner 
cd actions-runner
curl -O -L https://github.com/actions/runner/releases/download/v2.277.1/actions-runner-linux-x64-2.277.1.tar.gz# Extract the installer
tar xzf ./actions-runner-linux-x64-2.277.1.tar.gz

# Create the runner and start the configuration experience
./config.sh --url https://github.com/arimaverick/terraform-repo --token AHTAZ2K5GFE362U27VCDOMLAK5BMC
# Last step, run it!
./run.sh & > /tmp/github-actions.log