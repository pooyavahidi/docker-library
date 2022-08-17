# Docker Library

A collection of Dockerfiles for development, CI/CD pipelines and production. 

## Dockerfiles
The base image in Dockerfiles are parameterized. So, they can be built based on any compatible distro images (e.g. debian, alpine, ...). 

The idea is to provide the ability to build images on top of each other based on the requirements.
For example, we can build an image based on latest ubuntu for developing golang and python using the following:

```sh
docker build golang/debian/ -t my_dev_container --build-arg BASE_IMAGE=ubuntu:latest
docker build python/debian/ -t my_dev_container --build-arg BASE_IMAGE=my_dev_container
```

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
### Create a simple shell on top of an existing image
The following builds the shell image on top of Ubuntu image.
```
docker build shell/debian -t pv/shell:latest \
    --build-arg BASE_IMAGE=ubuntu:latest
```
Or it could be on top of any other (compatible) image.
```sh
docker build shell/debian -t pv/shell:latest \
    --build-arg BASE_IMAGE=pv/dev:latest \
    --build-arg USER=dev
```
> Shell and the base image must be compatible. As an example `shell/debian/Dockerfile` is compatible with any *debian-like* distros. So, it can be used on top of ubuntu, debian, etc.

## Build images locally using build.sh
`build.sh` is a sample script for building images locally. These are a few examples.

## Examples

### Build a shell for development
First pull the official `ubuntu:22.04`, then build a dev image `pv/dev:latest` on top of that.

build.sh can also create two additional shell images on top of the `pv/dev` image. `pv/shell:latest` which is a shell layer on top of the `pv/dev`, and `pv/shell-local:latest` which is a shell layer using the current host's user and group IDs.

> Note: Order of the layers is important. So, the ones which depend on the others should come after. E.g. ...golang,hugo,... .

```sh
docker pull ubuntu:22.04
```
The following creates an image based on `ubuntu:22.04` and then builds a series of tools on top of that. Finally it creates a shell image with a user called `dev`.
```sh
./build.sh -d debian -b ubuntu:22.04 \
    -i python,nodejs,golang,awscli,aws_cdk \
    -t pv/dev:latest \
    -s pv/shell:latest \
    -u dev
```

Build including shell-local
```sh
./build.sh -d debian -b ubuntu:22.04 \
    -i python,nodejs,golang,awscli \
    -t pv/dev:latest \
    -s pv/shell:latest \
    -c pv/shell-local:latest
```
> For MacOS and Windows, remove the `shell-local` option. Instead of creating `shell-local` just create a `shell` container and use Docker Desktop file sharing to share the host's directories.

### Build hugo image
```sh
./build.sh -d debian -b ubuntu:22.04 \
    -i hugo \
    -t pv/hugo:latest
```
### Build awscli image
```sh
./build.sh -d debian -b ubuntu:22.04 \
    -i awscli \
    -t pv/awscli:latest \
    -s pv/awscli-shell:latest \
    -u dev
```
We can also add some additional layers to this image.
```sh
./build.sh -d debian -b ubuntu:22.04 \
    -i awscli,python,docker \
    -t pv/awscli:latest \
    -s pv/awscli-shell:latest \
    -u dev
```
### Clean up
Prune the images to clean up
```sh
docker image prune
```
