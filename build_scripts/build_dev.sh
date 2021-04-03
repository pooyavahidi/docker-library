#!/bin/bash

[[ -z ${CONTAINER_REG_ALIAS} ]] && export CONTAINER_REG_ALIAS="pv/"

set -eux

# Build the first base image
docker build ubuntu/dev -t ${CONTAINER_REG_ALIAS}ubuntu-dev:latest \
	--build-arg BASE_IMAGE=ubuntu:20.04

# Set the base image of the next image 
__base_image=ubuntu-dev:latest


# Declare the images array
declare -a images

# Define the order of images to be built on top of each other.
# Note: make sure the images are in the order of dependencies.
images=(python \
		node \
		golang \
		aws_cdk \
		hugo
)

# Build images ordered based on the images array. Each image is the base of
# the next one
for image in "${images[@]}"; do
	docker build ${image}/dev/ \
		-t ${CONTAINER_REG_ALIAS}${image}-dev:latest \
		--build-arg BASE_IMAGE=${CONTAINER_REG_ALIAS}${__base_image}
	
	docker tag ${CONTAINER_REG_ALIAS}${image}-dev:latest \
		${CONTAINER_REG_ALIAS}dev:latest 

	__base_image=${image}-dev:latest
done

unset __base_image
unset __base_distro
unset images
unset image
