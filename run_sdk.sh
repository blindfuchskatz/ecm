#!/bin/bash

source ./docker/sdk_version.sh

docker run --net host --security-opt seccomp=unconfined --rm -v $PWD:/ecm_sdk/ -w /ecm_sdk/ -it ecm_sdk:$SDK_VERSION  /bin/bash