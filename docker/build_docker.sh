#!/bin/bash

echo "Build the docker"

docker build . -t rkrispin/atsaf:dev.0.0.0.9000

if [[ $? = 0 ]] ; then
echo "Pushing docker..."
docker push rkrispin/atsaf:dev.0.0.0.9000
else
echo "Docker build failed"
fi