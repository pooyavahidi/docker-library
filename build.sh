#!/bin/bash


function build_image() {
    local __use_current_user
    local -a __layers
    local __layer
    local __image_name
    local -a __image_tags
    local __image_tag
    local __base_image
    local __distro_like
    local __user
    local __user_id_args

    # Load the command line parameters into variables
    while (( $# )); do
        case $1 in
            -d | --distro-like)
                shift
                __distro_like=$1
                ;;
            -b | --base-image)
                shift
                __base_image=$1
                ;;
            -l | --layers)
                shift
                [[ -z $1 ]] && echo "Image layers not provided" >&2 && exit 1
                IFS=',' read -ra __layers <<< "$1"
                ;;
            -n | --image-name)
                shift
                __image_name=$1
                ;;
            -t | --image-tags)
                shift
                [[ -z $1 ]] && echo "Image tags must be provided." >&2 && exit 1
                IFS=',' read -ra __image_tags <<< "$1"
                ;;
            -c | --current-user)
                __use_current_user=1
                ;;
            -u | --username)
                shift
                __user=$1
                ;;
            *)
                echo "$1 is not a supported option" >&2
                exit 1
                ;;
        esac
        shift
    done

    # Set the variables and defaults.
    [[ -z $__base_image ]] && __base_image="ubuntu:22.04"
    [[ -z $__distro_like ]] &&  __distro_like="debian"
    [[ -z $__use_current_user ]] &&  __use_current_user=0
    [[ -z $__user ]] && __user="dev"
    [[ -z $__image_name ]] && echo "Image name is not provided" >&2 && exit 1
    [[ -z $__layers ]] && echo "layers are not provided" >&2 && exit 1
    [[ -z $__image_tags ]] && __image_tags=("latest")

    # If current_user flag is set, then set the USER_ID and GROUP_ID to
    # the host's current user id.
    if (( current_user == 1 )); then
        __user_id_args="--build-arg USER_ID=$(id -u ${USER}) \
                        --build-arg GROUP_ID=$(id -g ${USER})"
    fi

    # Build images ordered based on the stack array. Each image is the base
    # for the next one.
    for __layer in "${__layers[@]}"; do
        docker build ${__layer}/${__distro_like}/ \
            -t ${__registry}/${__image_name}:temp \
            --build-arg BASE_IMAGE=${__base_image} \
            --build-arg USER=${__user} ${__user_id_args}

        if (( $? != 0 )); then
            exit 1
        fi

        __base_image="${__registry}/${__image_name}:temp"
    done

    # Create tags
    for __image_tag in "${__image_tags[@]}"; do
        docker tag ${__registry}/${__image_name}:temp \
            ${__registry}/${__image_name}:${__image_tag}

        if (( $? != 0 )); then
            exit 1
        fi
        echo "tag ${__registry}/${__image_name}:${__image_tag}"

    done
    # Remove the temp tag
    docker image rm ${__registry}/${__image_name}:temp

    # Prune the dangling images
    docker image prune -f
}

function build_default_images() {
    local __excludes
    local -a __default_images
    local __image
    local __image_name
    local __image_layers
    local __image_tags
    local __image_values

    # Load the command line parameters into variables
    while (( $# )); do
        case $1 in
            -e | --exclude)
                shift
                [[ -z "${__excludes:=$1}" ]] \
                    && echo "Excluding images must be provided." >&2 && exit 1
                ;;
            --registry)
                shift
                ;;
            --defaults)
                ;;
            *)
                echo "$1 is not a supported option" >&2
                exit 1
                ;;
        esac
        shift
    done
    # default images info in the following format:
    # image_name|comma separated list of layers
    __default_images=(
        "development|base,python,nodejs,golang,awscli,aws_cdk,docker,shell"
        "awscli|awscli,shell"
        "anaconda|anaconda,shell"
        "datascience|anaconda,datascience,shell"
        "hugo|hugo,shell"

    )
    for __image in "${__default_images[@]}"; do

        IFS='|' read -ra __image_values <<< "$__image"
        __image_name=${__image_values[0]}
        __image_layers=${__image_values[1]}

        if [[ ! "${__excludes}" =~ "$__image_name" ]]; then
            echo Building $__image_name image...
            build_image \
                -l ${__image_layers} \
                -n ${__image_name} ${__platform_cmd}
        fi
    done
}


function main() {
    local __defaults

    # If no parameter is provided exit with error.
    (( $# == 0 )) && echo "Parameters must be provided." >&2 && exit 1

    original_params="${@}"

    # Load the command line parameters into variables
    while (( $# )); do
        case $1 in
            --registry)
                shift
                __registry=$1
                ;;
            --defaults)
                __defaults="1"
                ;;
        esac
        shift
    done
    # If __registry is empty, set it to $DOCKER_LOCAL_REGISTRY or,
    # if that is also empty, to $DOCKERHUB_USERNAME
    : "${__registry:=${DOCKER_LOCAL_REGISTRY:-$DOCKERHUB_USERNAME}}"

    if [[ -z $__registry ]]; then
        echo "Registry must be provided." >&2
        exit 1
    fi


    if [[ -n $__defaults ]]; then
        build_default_images ${original_params[@]}
    else
        build_image ${original_params[@]}
    fi
}

main "${@}"

