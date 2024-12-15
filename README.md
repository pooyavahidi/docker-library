# Docker Library

A collection of Dockerfiles specifically curated for development purposes.

The base images in these Dockerfiles are parameterized, allowing them to be built on top of any compatible distro images such as Debian, Alpine, and others.

The overarching concept is to facilitate the creation of images that can be stacked atop each other, depending on specific requirements. For instance, one could build an image premised on the latest Ubuntu version, customized for developing in Golang and Python. This process allows for greater flexibility and customization in the development environment.

```sh
docker build golang/debian/ -t my_dev_container --build-arg BASE_IMAGE=ubuntu:latest

# Then use the newly built image as the base image of the next one.
docker build python/debian/ -t my_dev_container --build-arg BASE_IMAGE=my_dev_container
```

## Shell Images

These images are designed for local development and testing. They incorporate a user within the container that utilizes a high-range id of 61000. This is done to avoid any potential overlap with host user IDs.

### Building a simple shell on top of an existing image
The following command builds a shell image on top of the Ubuntu image. It also set the username of the container user as `dev`.
```sh
docker build shell/debian -t your_registry/ubuntu-shell \
    --build-arg BASE_IMAGE=ubuntu:latest \
    --build-arg USER=dev
```
Or it could be built on top of any other compatible(same distro, e.g. debian) image.
```sh
docker build shell/debian -t your_registry/shell \
    --build-arg BASE_IMAGE=your_registry/dev:latest \
    --build-arg USER=dev
```
>It's crucial to note that the shell and the base image should be compatible. For instance, the Dockerfile located at `shell/debian/Dockerfile` is compatible with any *debian-like* distributions. Therefore, it can be readily used on top of other systems such as Ubuntu, Debian, and so forth. This compatibility allows for seamless integration and efficient usage of resources, enhancing your overall development experience.

### Constructing a Shell Image with the Host's Current User ID in Linux
Using Linux docker engine where development within a container is preferred and the host's source code directory needs to be mounted as a volume, write permission must be granted to the container's user id. This permission management is usually handled by Docker Desktop in MacOS and Windows. However, when working with a Docker engine in an operating system such as Linux, this task falls upon the user.

A solution to this is to create a container user that shares the same `USER_ID` and `GROUP_ID` as the host's current user. This can effectively manage permissions and ensure seamless operation.

Building a shell using the host's current user and group IDs:

```sh
docker build shell/debian -t pv/ubuntu-shell \
    --build-arg BASE_IMAGE=ubuntu:latest \
    --build-arg USER_ID=$(id -u ${USER}) \
    --build-arg GROUP_ID=$(id -g ${USER})
```
## Building Images with build.sh
The `build.sh` script is a versatile tool that you can use to craft images either on your local machine or within a cicd pipeline. Here are some examples to get you started, along with a few predefined images and their layers which can be quickly implemented.

### Clean the Environment (Optional)
To clean up the environment, the easiest way is to prune the system which deletes all the images, containers, and networks that are not being used.
```sh
docker system prune -a
```
Then, pull the ubuntu image to start fresh.
```sh
docker pull ubuntu:latest
```

### Example: Development Image
Beyond its basic functionalities, `build.sh` offers the capability to create two additional shell images on top of the `pv/dev` image. By using the `-s` option, you can add a shell layer to `pv/dev` that incorporates a container's user. Meanwhile, the `-c` option allows you to construct a shell layer with a container's user that shares the same `USER_ID` and `GROUP_ID` as the host's current user.

> Note: The order of the layers is crucial. Layers that depend on others should be arranged accordingly. For instance, the sequence could be ...golang,hugo,... .

To illustrate, let's create an image named `my-image` based on `ubuntu:latest`. This image will then have a series of layers built on top of it. Finally, a shell image with a user named `dev` will be constructed. Here's how you can achieve this:

```sh
./build.sh -d debian -b ubuntu:latest \
    -i python,nodejs,golang,awscli,aws_cdk,shell \
    -t my-registry/my-image:latest \
    -u dev
```

> On a Linux docker engine, use the `-c | --current-user` option to generate a container user with the same USER ID as the host's user. The `-c` option adopts the current user's USER_ID and GROUP_ID, while `-s` applies 61000 (a high range ID) for both USER_ID and GROUP_ID. MacOS and Windows users need not worry about this as Docker Desktop manages access to the host's file system.

### Building Anaconda Images
Building DataScience images:
```sh
./build.sh -r anaconda-base \
    && ./build.sh -r anaconda \
    && ./build.sh -r datascience
```

### Building the Development Image Using the Recipes
Another option is to use predefined recipes for faster image crafting. Here's an example:

```sh
./build.sh -r development
```
By default, the image name will be the same as the recipe name, which is `development` in this case. The layers are defined in the recipe, and the default user and initial base image are set to `dev` and `ubuntu:latest`, respectively.


### Building a Development Image for Multiple Platforms with Buildx
If you're targeting multiple platforms for your image, you'll need to use the `--platform` option along with a list of the desired platforms. Here's how you can do this:

```sh
./build.sh -r development \
    --platform linux/amd64,linux/arm64 \
    --registry $DOCKERHUB_USERNAME \
    --push
```
The command builds the `development` recipe for both `amd64` and `arm64` architectures. Once the image is built, it will be pushed to the Docker Hub repository.


### Options

#### `--no-cache`

Building `anaconda` recipe using `--no-cache` to force a rebuild of the image without using the docker's build cache.
```sh
./build.sh -r anaconda --no-cache
```
