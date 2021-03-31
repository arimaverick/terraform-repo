#!/bin/bash

for i in {1..5}
do 
  sudo docker ps -aqf "name=github-runner-$i" >> containers.txt
done

if [ -s ~/containers.txt ]
then
    while IFS= read -r line; do
    CONTAINERID=$line
    echo "Remove Operation from container: $CONTAINERID"
    sudo docker exec $CONTAINERID /bin/bash -c "sh /home/actions/actions-runner/remove-runner.sh"
else
   echo "NO CONTAINER PRESENT"
fi
 