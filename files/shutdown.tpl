#!/bin/bash
set -e
echo "*****    De-Installing SHR    *****"
# Create a folder
# Update instance
# Install latest version of git

sudo apt update
sudo apt install -y jq
#add-apt-repository ppa:git-core/ppa -y
#sudo apt install -y git
#sudo apt install -y unzip

echo "10.0.0.8 xfgft.com" >> /etc/hosts

#sudo su -c "useradd -m github -s /bin/bash"

ACTION_RUNNER_TOKEN=$(curl -s -XPOST -H "authorization: token ${GITHUB_PAT}" https://api.github.com/repos/arimaverick/terraform-repo/actions/runners/registration-token | jq -r .token)
#cat >/root/script.sh <<EOL
cd ~/actions-runner
export RUNNER_ALLOW_RUNASROOT=0
#./svc.sh stop
#./svc.sh uninstall
./config.sh remove --token $ACTION_RUNNER_TOKEN --name terraform-ubuntu-shr

#nohup ./run.sh > runner.log 2>&1 &
#EOL
#chmod +x /root/script.sh
#su - github -c "/root/script.sh"
echo "*****    Completed SHR De-Installation   *****"
# Create the runner and start the configuration experience
#./config.sh --url https://github.com/arimaverick/terraform-repo --token AHTAZ2PO43VMNOHY5U2GJT3AK5SAQ --name ubuntu-shr --work '_work' --labels 'self-hosted','Linux','X64'
# Last step, run it!
#./run.sh & > /tmp/github-actions.log


