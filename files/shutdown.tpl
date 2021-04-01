#!/bin/bash

for i in {1..5}
do 
  CONTAINERID=`sudo docker ps -aqf "name=github-runner-$i"`
  echo "Remove Operation from container: $CONTAINERID"
  sudo docker exec $CONTAINERID /bin/bash -c "sh /home/actions/actions-runner/remove-runner.sh"
done