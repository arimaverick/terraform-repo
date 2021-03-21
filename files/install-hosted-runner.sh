#!/bin/bash
set -e
echo "*****    Installing SHR    *****"
# Create a folder
# Update instance
apt update -y
apt upgrade -y

# Install latest version of git
add-apt-repository ppa:git-core/ppa -y
apt-get update
apt-get install git -y

apt-get install unzip -y

# Install and setup docker


mkdir actions-runner && cd actions-runner# Download the latest runner package
curl -O -L https://github.com/actions/runner/releases/download/v2.277.1/actions-runner-linux-x64-2.277.1.tar.gz# Extract the installer
tar xzf ./actions-runner-linux-x64-2.277.1.tar.gz

# Create the runner and start the configuration experience
./config.sh --url https://github.com/arimaverick/terraform-repo --token AHTAZ2K5GFE362U27VCDOMLAK5BMC
# Last step, run it!
./run.sh & > /tmp/github-actions.log