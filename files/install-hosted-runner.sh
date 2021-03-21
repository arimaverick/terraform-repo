# Create a folder
# Update instance
sudo apt update -y
sudo apt upgrade -y

# Install latest version of git
sudo add-apt-repository ppa:git-core/ppa -y
sudo apt-get update
sudo apt-get install git -y

sudo apt-get install unzip -y

# Install and setup docker


mkdir actions-runner && cd actions-runner# Download the latest runner package
curl -O -L https://github.com/actions/runner/releases/download/v2.277.1/actions-runner-linux-x64-2.277.1.tar.gz# Extract the installer
tar xzf ./actions-runner-linux-x64-2.277.1.tar.gz

# Create the runner and start the configuration experience
./config.sh --url https://github.com/arimaverick/terraform-repo --token AHTAZ2P4VCHQSH3XCVA4ANDAK2X3K
# Last step, run it!
./run.sh & > /tmp/github-actions.log