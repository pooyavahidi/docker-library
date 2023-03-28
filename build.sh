#!/bin/bash

function print_usage {
	echo "Usage: [option] value"
    echo -e "-h | --help"
    echo -e "-d | --distro-like <debian|alpine>"
    echo -e "-b | --base-image <base-image>"
    echo -e "-i | --images <list>"
    echo -e "-t | --image-tag <image_tag>"
    echo -e "-s | --shell-image-tag <shell-image_tag>"
    echo -e "-c | --current-user"
    echo -e "-u | --username <container_user>"
    echo -e "\nTo build default images use --defaults option"
    echo -e "\nDefault images: dev,awscli,anaconda,hugo\n"
    echo -e "./build --defaults"
    echo -e "./build --defaults -e|--exclude image1,image2"
}

function build_image() {
    # Set the default values
    local __shell_image_tag
    local __use_current_user
    local -a __images
    local __base_image
    local __distro_like
    local __shell_image_tag
    local __user
    local __recipe
    local __user_id_args

    # Load the command line parameters into variables
    while [ -n "$1" ]; do
        case $1 in
            -d | --distro-like)
                shift
                __distro_like=$1
                ;;
            -b | --base-image)
                shift
                __base_image=$1
                ;;
            -i | --images)
                shift
                [[ -z $1 ]] && echo "Missing images parameter" && print-usage
                __images=($(echo $1 | sed 's/ //g' | sed 's/,/ /g'))
                ;;
            -t | --image-tag)
                shift
                __image_tag=$1
                ;;
            -s | --shell-image-tag)
                shift
                __shell_image_tag=$1
                ;;
            -c | --current-user)
                shift
                __use_current_user=1
                ;;
            -u | --username)
                shift
                __user=$1
                ;;
             *)
                print_usage
                exit 1
                ;;
        esac
        (( $# > 0 )) && shift
    done

    # Set the variables and defaults.
    [[ -z $__base_image ]] && __base_image="ubuntu:22.04"
    [[ -z $__distro_like ]] &&  __distro_like="debian"
    [[ -z $__use_current_user ]] &&  __use_current_user=0
    [[ -z $__user ]] && __user="dev"
    #[[ -z $__image_tag ]] && echo "image tag is not provided" && exit 1


    # Build images ordered based on the images array.
    # Each image is the base for the next one.
    for __image in "${__images[@]}"; do
        docker build ${__image}/${__distro_like}/ -t ${__image_tag} \
            --build-arg BASE_IMAGE=${__base_image}


        (( $? != 0 )) && exit 1

        __base_image=${__image_tag}
    done


    # If shell_image_tag is provided, then build the shell image.
    if [[ -n $__shell_image_tag ]]; then

        # If Build the shell image from the using the current host's userid
        if (( current_user == 1 )); then
            __user_id_args="--build-arg USER_ID=$(id -u ${USER}) \
                            --build-arg GROUP_ID=$(id -g ${USER})"
        fi

        docker build shell/${__distro_like}/ -t ${__shell_image_tag} \
            --build-arg BASE_IMAGE=${__base_image} \
            --build-arg USER=${__user} ${__user_id_args}

        (( $? != 0 )) && exit 1
    fi

    # Prune the dangling images
    docker image prune -f
}

function build_default_images() {
    local __excludes

    # Load the command line parameters into variables
    while [ -n "$1" ]; do
        case $1 in
            -e | --exclude)
                shift
                [[ -z "${__excludes:=$1}" ]] \
                    && echo "Excluding images must be provided." && exit 1
                ;;
            --defaults)
                ;;
            *)
                echo "Not supported option for default builds" >&2
                exit 1
                ;;
        esac
        (( $# > 0 )) && shift
    done


    # Build dev and dev-shell. This image is for general development. So it
    # uses most of the layers.
    if [[ ! "${__excludes}" =~ "dev" ]]; then
        echo Building dev and dev-shell images...
        build_image \
            -i python,nodejs,golang,awscli,aws_cdk,docker \
            -t ${DOCKER_LOCAL_REGISTRY}/dev \
            -s ${DOCKER_LOCAL_REGISTRY}/dev-shell
    fi

    # awscli
    if [[ ! "${__excludes}" =~ "awscli" ]]; then
        echo Building awscli image...
        build_image \
            -i awscli \
            -t ${DOCKER_LOCAL_REGISTRY}/awscli \
            -s ${DOCKER_LOCAL_REGISTRY}/awscli
    fi

    # Anaconda
    if [[ ! "${__excludes}" =~ "anaconda" ]]; then
        echo Building anaconda image...
        build_image \
            -i anaconda \
            -t ${DOCKER_LOCAL_REGISTRY}/anaconda \
            -s ${DOCKER_LOCAL_REGISTRY}/anaconda
    fi

    # hugo and hugo-shell
    if [[ ! "${__excludes}" =~ "hugo" ]]; then
        echo Building hugo and hugo-shell images...
        build_image \
            -i hugo \
            -t ${DOCKER_LOCAL_REGISTRY}/hugo \
            -s ${DOCKER_LOCAL_REGISTRY}/hugo-shell
    fi
}

function main() {
    # if no input variable, show usage
    (( $# == 0 )) && print_usage && exit 1

    if [[ "${@}" =~ "--defaults" ]]; then
        build_default_images "${@}"
    else
        build_image "${@}"
    fi
}

main "${@}"