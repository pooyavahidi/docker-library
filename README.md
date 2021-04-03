
# Docker Library

A collection of Dockerfiles for development, CI/CD pipelines and production. 

## Dev Dockerfiles
The base image for `dev` related Dockerfiles are parameterized. So, they can be built based on any debian-like base image and on top of each other. The idea is to build containers as the development workspace (developing within the container).
For example, in the following `golang/dev/Dockerfile` will be built based on the latest debian image.
```sh
docker build golang/dev/ -t my-golang --build-arg BASE_IMAGE=debian:latest
```

### Quick build
As an example `build_scripts/build_dev.sh` creates all the required images for a development workspace for developing gohugo and deploying the site to the aws using cdk.

```sh
export CONTAINER_REG_ALIAS=<your username in a registry, e.g. dockerhub>/
build_scripts/build_dev.sh
```
Note: the value of `CONTAINER_REG_ALIAS` should be ended with `/`. This is just a prefix to the image tag name. So, if you want to use it locally, you don't need to provide a valid username.

# Shell images
These images are intended for local development and tests. They create a user within the container which uses a high range id of 61000 (to not overlap with any potential host user ids). 

## Create image with host's user id
In order to develop using a container and mount the source code directory of
the host as a volume, we need to give a write permission to the container's user
id. 

The followings build a local shell image based on official ubuntu image 
using the current hosts's user id.

```sh
docker build shell/debian/ -t shell-local:ubuntu-latest \
	--build-arg BASE_IMAGE=ubuntu:latest \
	--build-arg USER_ID=$(id -u ${USER}) \
	--build-arg GROUP_ID=$(id -g ${USER})

docker tag shell-local:ubuntu-latest shell-local:latest
```

`build_dev_shell.sh` script creates two shell images based on the `dev` image (which can be built by the `build_dev.sh` script) one with userId of 61000 and one with the same userId of the current user.