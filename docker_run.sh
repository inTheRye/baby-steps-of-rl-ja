#!/usr/bin/env bash
IMAGE_NAME="docker_ssh"
CONTAINER_NAME=${IMAGE_NAME}
bash ./docker_build.sh
docker run --name=${CONTAINER_NAME} --rm -it -p 8888:8888 -p 8022:22 -v ${PWD}:/home/user01/work ${IMAGE_NAME}
