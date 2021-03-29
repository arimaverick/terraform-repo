#!/bin/bash
set -e
echo "*****    Installing SHR    *****"
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
mkdir ~/actions-runner && cd ~/actions-runner
curl -O -L https://github.com/actions/runner/releases/download/v2.277.1/actions-runner-linux-x64-2.277.1.tar.gz
tar xzf ./actions-runner-linux-x64-2.277.1.tar.gz
#chown -R github:github /home/github/actions-runner
export RUNNER_ALLOW_RUNASROOT=0
cp bin/runsvc.sh .
chmod +x runsvc.sh
./config.sh --url https://github.com/arimaverick/terraform-repo --token $ACTION_RUNNER_TOKEN --name terraform-ubuntu-shr --work '_work' --labels self-hosted,Linux,X64
./runsvc.sh
#./svc.sh install
#./svc.sh start
#nohup ./run.sh > runner.log 2>&1 &
#EOL
#chmod +x /root/script.sh
#su - github -c "/root/script.sh"
echo "*****    Completed SHR Installation   *****"
# Create the runner and start the configuration experience
#./config.sh --url https://github.com/arimaverick/terraform-repo --token AHTAZ2PO43VMNOHY5U2GJT3AK5SAQ --name ubuntu-shr --work '_work' --labels 'self-hosted','Linux','X64'
# Last step, run it!
#./run.sh & > /tmp/github-actions.log


