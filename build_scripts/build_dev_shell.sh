#!/bin/bash

[[ -z ${CONTAINER_REG_ALIAS} ]] && export CONTAINER_REG_ALIAS="pv/"

# Build the shell image from dev:latest using a user id outside the range of host's userid.
docker build shell/debian/ -t ${CONTAINER_REG_ALIAS}shell-dev:latest \
	--build-arg BASE_IMAGE=${CONTAINER_REG_ALIAS}dev:latest \

# Build the shell image from the dev:latest using the current host's userid
docker build shell/debian/ -t ${CONTAINER_REG_ALIAS}shell-local-dev:latest \
	--build-arg BASE_IMAGE=${CONTAINER_REG_ALIAS}dev:latest \
	--build-arg USER_ID=$(id -u ${USER}) \
	--build-arg GROUP_ID=$(id -g ${USER})

