#!/usr/bin/env bash
PUB_KEY=$(cat ~/.ssh/id_rsa_for_docker_ssh.pub)
IMAGE_NAME="docker_ssh"
docker build \
    --build-arg  HOST_UID="$(id -u)" \
    --build-arg  AUTHORIZED_KEYS="${PUB_KEY}" \
    -t ${IMAGE_NAME} \
    .