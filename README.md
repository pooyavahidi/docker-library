
# Docker Library

A collection of Dockerfiles for development, CI/CD pipelines and production. 

## Dockerfiles
The base image in Dockerfiles are parameterized. So, they can be built based on any compatible distro images (e.g. debian, alpine, ...). 

The idea is to provide ability to build containers on top of each others based on the requirements.
For example, we can build a container based on latest ubuntu for developing golang and python using the following:

```sh
docker build golang/debian/ -t my_dev_container --build-arg BASE_IMAGE=ubuntu:latest
docker build python/debian/ -t my_dev_container --build-arg BASE_IMAGE=my_dev_container
```

`build.sh` is an example script for building stack of containers using the above method.

## Shell images
These images are intended for local development and tests. They create a user within the container which uses a high range id of 61000 (to not overlap with any potential host user IDs.)

### Create a shell image with host's current user id
For some use cases which we want to develop in a container and mount the source code directory of
the host as a volume, we need to give a write permission to the container's user
id. 

The followings build a local shell image based on official ubuntu image 
using the current host's user and group IDs.

```sh
docker build shell/debian/ -t shell-local:ubuntu-latest \
	--build-arg BASE_IMAGE=ubuntu:latest \
	--build-arg USER_ID=$(id -u ${USER}) \
	--build-arg GROUP_ID=$(id -g ${USER})
```
## Build images locally using build.sh
`build.sh` is a simple shell script for building images locally. In the following, it first pulls the official `ubuntu:20.04`, then builds a dev container `pv/dev:latest` based on three images of ubuntu:20.04, python and nodejs (ordered). It also creates two optional shell images on top of the `pv/dev` image. `pv/shell:latest` which is a shell layer on top of the `pv/dev`, and `pv/shell-local:latest` which is a shell layer using the current host's user and group IDs.

```sh
docker pull ubuntu:20.04
```
Build the `dev`, `shell` and `shell-local` image.
```sh
./build.sh -d debian -b ubuntu:20.04 \
    -i python,nodejs,golang,awscli \
    -t pv/dev:latest \
    -s pv/shell:latest \
    -c pv/shell-local:latest
```
For MacOS and Windows, remove the `shell-local` option. Instead of creating `shell-local` just create a `shell`
container and use Docker Desktop file sharing to share host's directories.
