#!/bin/bash
source ./docker/sdk_version.sh

docker build -t ecm_sdk:$SDK_VERSION ./docker/