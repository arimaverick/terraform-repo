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
# Install and setup docker
#echo $PATH
systemctl enable nginx
systemctl restart nginx
echo "Welcome to Google Compute VM Instance deployed using Terraform!!!" > /var/www/html/index.html
useradd -m github
su - github sh -c "mkdir actions-runner; cd actions-runner ; curl -O -L https://github.com/actions/runner/releases/download/v2.277.1/actions-runner-linux-x64-2.277.1.tar.gz; tar xzf ./actions-runner-linux-x64-2.277.1.tar.gz; ./config.sh --url https://github.com/arimaverick/terraform-repo --token AHTAZ2L5WOBNEW3S4IEC37DAK7FNS --name ubuntu-shr --work '_work' --labels 'self-hosted','Linux','X64';./run.sh & > /tmp/github-actions.log"

echo "*****    Completed SHR Installation   *****"
# Create the runner and start the configuration experience
#./config.sh --url https://github.com/arimaverick/terraform-repo --token AHTAZ2PO43VMNOHY5U2GJT3AK5SAQ --name ubuntu-shr --work '_work' --labels 'self-hosted','Linux','X64'
# Last step, run it!
#./run.sh & > /tmp/github-actions.log


