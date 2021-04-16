#!/bin/bash

# A sample script to show how to build a stack of images

function print-usage {
	echo "Usage: [option] value"
    echo "Options"
    echo "-h | --help"
    echo "-d | --distro-like <debian|alpine>"
    echo "-b | --base-image <base-image>            The root base image"
    echo "-i | --images <list>                      comma-separated list" \
         "of Dockerfiles. No space between the images"
    echo "-t | --image-tag <image_tag>              the tag name for the" \
         "final image"
    echo "-s | --shell <image_tag>                  adds the shell image as" \
         "the final image"
    echo "-c | --current-user-shell <image_tag>     set the current host's" \
         "USER_ID as the" \
         "container's internal USER"
	echo "Example:"
	echo "build.sh -d debian -b ubuntu:20.04 -i python,nodejs -t pv/dev:latest" \
         "-s shell:latest -c shell-local:latest"
}

shell_image_tag=""
current_user_shell_image_tag=""

# Load the command line parameters into variables
while [ -n "$1" ]; do
    case $1 in
        -h | --help)
            print-usage
            exit
            ;;
        -d | --distro-like)
            shift
            distro_like=$1
            ;;
        -b | --base-image)
            shift
            base_image=$1
            ;;
        -i | --images)
            shift
            [[ -z $1 ]] && echo "Missing images parameter" && print-usage
            declare -a images
            images=($(echo $1 | sed -r 's/,/ /g'))
            ;;
        -t | --image-tag)
            shift
            image_tag=$1
            ;;
        -s | --shell)
            shift
            shell_image_tag=$1
            ;;
        -c | --current-user-shell)
            shift
            current_user_shell_image_tag=$1
            ;;
        *)
            print-usage
            exit 1
            ;;
    esac
    shift
done

set -eu

# Build images ordered based on the images array. Each image is the base for
# the next one.
for image in "${images[@]}"; do
    docker build ${image}/${distro_like}/ -t ${image_tag} \
        --build-arg BASE_IMAGE=${base_image}

    base_image=${image_tag}
done

# clean up images
docker image prune -f

# Build the shell image 
if [[ -n ${shell_image_tag} ]]; then
    docker build shell/${distro_like}/ -t ${shell_image_tag} \
        --build-arg BASE_IMAGE=${image_tag}
fi

# Build the shell image from the using the current host's userid
if [[ -n ${current_user_shell_image_tag} ]]; then
    docker build shell/${distro_like}/ -t ${current_user_shell_image_tag} \
        --build-arg BASE_IMAGE=${image_tag} \
        --build-arg USER_ID=$(id -u ${USER}) \
        --build-arg GROUP_ID=$(id -g ${USER})
fi
