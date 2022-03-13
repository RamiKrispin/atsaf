#!/usr/bin/env bash
echo "Build the docker"

if [[ $1 = "" ]] ; then
  echo "No major argument, using default setting"
  major=4
else
  major=$1
fi

if [[ $2 = "" ]] ; then
  echo "No minor argument, using default setting"
  minor=1
else
  minor=$2
fi


if [[ $3 = "" ]] ; then
  echo "No patch argument, using default setting"
  patch=0
else
  patch=$3
fi


echo "R version is set to $major.$minor.$patch"

docker build --build-arg R_VERSION_MAJOR=$major --build-arg R_VERSION_MINOR=$minor --build-arg R_VERSION_PATCH=$patch . -t rkrispin/atsafr_baser:v$major.$minor.$patch

if [[ $? = 0 ]] ; then
    echo "Pushing docker..."
    docker push rkrispin/atsafr_baser:v$major.$minor.$patch
else
    echo "Docker build failed"
fi
