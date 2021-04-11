#!/bin/bash -x

echo "*****    Installing SHR    *****"
# Create a folder
# Update instance
# Install latest version of git
sudo yum update -y --nogpgcheck
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo sed -i s/\$releasever/7/g /etc/yum.repos.d/docker-ce.repo
sudo yum install -y docker-ce
sudo systemctl start docker
#add-apt-repository ppa:git-core/ppa -y
#sudo apt install -y git
#sudo apt install -y unzip

#sudo su -c "useradd -m github -s /bin/bash"
mkdir /docker-setup
echo "Creating Shutdown script"

cat > /docker-setup/shutdown-script.sh <<- "EOF"
#!/bin/bash

for i in {1..5}
do 
  CONTAINERID=`sudo docker ps -aqf "name=github-runner-$i"`
  echo "Remove Operation from container: $CONTAINERID"
  sudo docker exec $CONTAINERID /bin/bash -c "sh /home/actions/actions-runner/remove-runner.sh"
done
EOF

chmod +x /docker-setup/shutdown-script.sh

echo "Creating Remove Runner script"
cat > /docker-setup/remove-runner.sh <<- "EOF"
#!/bin/bash

cd /home/actions/actions-runner
export RUNNER_ALLOW_RUNASROOT=0
export GITHUB_PAT=`gcloud secrets versions access 1 --secret="github_pat"`
ACTION_REMOVE_RUNNER_TOKEN=$(curl -s -XPOST -H "authorization: token $GITHUB_PAT" https://api.github.com/repos/arimaverick/terraform-repo/actions/runners/registration-token | jq -r .token)
./config.sh remove --token $ACTION_REMOVE_RUNNER_TOKEN
EOF

cat > /docker-setup/Dockerfile <<- "EOF"
FROM ubuntu:18.04
ARG RUNNER_ALLOW_RUNASROOT=0
RUN apt update
RUN apt install -y software-properties-common
RUN add-apt-repository ppa:git-core/ppa
RUN apt install -y jq curl yamllint git npm nodejs apt-transport-https ca-certificates gnupg wget unzip sudo python3-pip openjdk-8-jdk
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update && apt-get install -y google-cloud-sdk
#RUN apt update && apt install -y google-cloud-sdk
RUN useradd -m actions
RUN mkdir /home/actions/actions-runner
WORKDIR /home/actions/actions-runner
RUN curl -O -L https://github.com/actions/runner/releases/download/v2.277.1/actions-runner-linux-x64-2.277.1.tar.gz
RUN tar xzf ./actions-runner-linux-x64-2.277.1.tar.gz
RUN ./bin/installdependencies.sh
RUN echo "actions ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
COPY remove-runner.sh .
COPY entrypoint.sh .
#RUN cp /bin/runsvc . && chmod +x ./runsvc.sh
RUN chmod +x ./entrypoint.sh
RUN chmod +x ./remove-runner.sh
RUN chown -R actions:actions /home/actions/actions-runner
USER actions
CMD ["./entrypoint.sh"]
EOF

echo "Creating Entrypoint"
cat > /docker-setup/entrypoint.sh <<- "EOF"
#!/bin/sh
registration_url="https://api.github.com/repos/arimaverick/terraform-repo/actions/runners/registration-token"
echo "Requesting registration URL at '$registration_url'"
export GITHUB_PAT=`gcloud secrets versions access 1 --secret="github_pat"`
payload=$(curl -sX POST -H "Authorization: token $GITHUB_PAT" $registration_url)
export ACTION_RUNNER_TOKEN=$(echo $payload | jq .token --raw-output)

./config.sh \
    --token $ACTION_RUNNER_TOKEN \
    --url https://github.com/arimaverick/terraform-repo \
    --unattended \
    --replace

remove() {
    export GITHUB_PAT=`gcloud secrets versions access 1 --secret="github_pat"`
    export REMOVE_RUNNER_TOKEN=$(curl -s -XPOST -H "authorization: token $GITHUB_PAT" https://api.github.com/repos/arimaverick/terraform-repo/actions/runners/registration-token | jq -r .token)
    ./config.sh remove --unattended --token "$REMOVE_RUNNER_TOKEN"
}

trap 'remove; exit 130' INT
trap 'remove; exit 143' TERM

./run.sh "$*" &

wait $!
EOF

cd /docker-setup
docker build -t ghshr:v1 .

for i in {1..2}
do
  rand_string=`cat /dev/urandom | tr -dc 'a-z' | fold -w 32 | head -n 1`
  dock_suffix=`echo $rand_string|cut -c1-4`
  docker run -d --name github-runner-$i-$dock_suffix --add-host xfgft.com:10.0.0.8 ghshr:v1
done

docker ps

echo "*****    Completed SHR Installation   *****"

