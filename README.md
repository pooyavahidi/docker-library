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
In some cases where we want to develop in a container and mount the source code directory from the host as a volume, we need to give a write permission to the container's user id. When using Docker Desktop, this is normally handled by the Docker Desktop. However, when using docker engine in an OS such as linux, we need to manage this ourselves. To fix this, we can simply create a container user using the same `USER_ID` and `GROUP_ID` of the host's current user.

The following builds a shell using the current host's user and group IDs.

```sh
docker build shell/debian -t pv/ubuntu-shell \
    --build-arg BASE_IMAGE=ubuntu:latest \
    --build-arg USER_ID=$(id -u ${USER}) \
    --build-arg GROUP_ID=$(id -g ${USER})
```
### Create a simple shell on top of an existing image
The following builds the shell image on top of Ubuntu image.
```
docker build shell/debian -t pv/ubuntu-shell \
    --build-arg BASE_IMAGE=ubuntu:latest
    --build-arg USER=dev
```
Or it could be on top of any other (compatible) image.
```sh
docker build shell/debian -t pv/shell \
    --build-arg BASE_IMAGE=pv/dev:latest \
    --build-arg USER=dev
```
> Shell and the base image must be compatible. As an example `shell/debian/Dockerfile` is compatible with any *debian-like* distros. So, it can be used on top of ubuntu, debian, etc.

## Build images locally using build.sh
`build.sh` is a sample script for building images locally. These are a few examples.

## Examples

### Build a shell for development
First pull the official `ubuntu:22.04`, then build a dev image `pv/dev:latest` on top of that.

build.sh can also create two additional shell images on top of the `pv/dev` image. Using option `-s` it creates a shell layer on top of the `pv/dev` with a container's user. Using the `-c` option, it creates a shell layer with a container's user with the same `USER_ID` and `GROUP_ID` as the current host's user.

> Note: Order of the layers is important. So, the ones which depend on the others should come after. E.g. ...golang,hugo,... .

```sh
docker pull ubuntu:22.04
```
The following creates an image based on `ubuntu:22.04` and then builds a series of tools on top of that. Finally it creates a shell image with a user called `dev`.
```sh
./build.sh -d debian -b ubuntu:22.04 \
    -i python,nodejs,golang,awscli,aws_cdk \
    -t pv/dev \
    -s pv/dev-shell \
    -u dev
```

Build the same using host's `USER_ID`. Use this method for creating **shell** containers in linux hosts.

```sh
./build.sh -d debian -b ubuntu:22.04 \
    -i python,nodejs,golang,awscli,aws_cdk \
    -t pv/dev \
    -s pv/dev-shell \
    -u dev
```
> In Linux installations use `-c` option. For MacOS and Windows, use `-s` option instead which lets the docker user to use Docker Desktop file sharing feature to access the host's directories. `-c` option uses current user's USER_ID and GROUP_ID. `-s` uses 61000 (a high range ID) for both USER_ID and GROUP_ID.

### Build hugo image
```sh
./build.sh -d debian -b ubuntu:22.04 \
    -i hugo \
    -t pv/hugo \
    -s pv/hugo-shell
```
### Build awscli image
```sh
./build.sh -d debian -b ubuntu:22.04 \
    -i awscli \
    -t pv/awscli \
    -s pv/awscli-shell \
    -u dev
```
We can also add some additional layers to this image.
```sh
./build.sh -d debian -b ubuntu:22.04 \
    -i awscli,python,docker \
    -t pv/awscli \
    -s pv/awscli-shell \
    -u dev
```
### Clean up
Prune the images to clean up
```sh
docker image prune
```
