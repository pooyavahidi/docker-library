#!/bin/bash

__default_base_image="ubuntu:latest"

# default images info in the following format:
# recipe_name|layers_in_order|base_image(optional)
function load_recipes(){
    __recipes=(
        "development|nodejs,golang,awscli,aws_cdk,docker,shell|$__registry/anaconda-base"
        "awscli|awscli,shell"
        "anaconda-base|ubuntu,anaconda"
        "anaconda|shell|$__registry/anaconda-base"
        "datascience|datascience,shell|$__registry/anaconda-base"
        "datascience-aws|datascience,awscli,shell|$__registry/anaconda-base"
        "hugo|hugo,shell"
    )
}

function main() {
    local __use_current_user
    local -a __layers
    local __layer
    local __image_name
    local __image_tag
    local __base_image
    local __distro_like
    local __user
    local __user_id_args
    local __build_cmd
    local __platform
    local __push
    local __recipe
    local __recipe_info
    local __recipe_name
    local __recipe_base
    local __registry
    local __no_cache

    # If no parameter is provided exit with error.
    (( $# == 0 )) && echo "Parameters must be provided." >&2 && exit 1

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
                __layers=$1
                ;;
            -n | --image-name)
                shift
                __image_name=$1
                ;;
            -t | --image-tag)
                shift
                [[ -z "${__image_tag:=$1}" ]] \
                    && echo "Image tag must be provided." >&2 && exit 1
                ;;
            -c | --current-user)
                __use_current_user=1
                ;;
            -u | --username)
                shift
                __user=$1
                ;;
            --push)
                __push="--push"
                ;;
            -p | --platform)
                shift
                [[ -z $1 ]] && echo "Platform must be provided." >&2 && exit 1
                __platform="--platform $1"
                ;;
            --registry)
                shift
                __registry=$1
                ;;
            -r | --recipe)
                shift
                __recipe=$1
                ;;
            --no-cache)
                __no_cache="--no-cache"
                ;;
            *)
                echo "$1 is not a supported option" >&2
                exit 1
                ;;
        esac
        shift
    done

    # Set the variables and defaults.
    [[ -z $__base_image ]] && __base_image=$__default_base_image
    [[ -z $__distro_like ]] &&  __distro_like="debian"
    [[ -z $__use_current_user ]] &&  __use_current_user=0
    [[ -z $__user ]] && __user="dev"
    [[ -z $__image_tag ]] && __image_tag="latest"

    # Validate registry
    # If __registry is empty, set it to $DOCKER_LOCAL_REGISTRY or,
    # if that is also empty, to $DOCKERHUB_USERNAME
    : "${__registry:=${DOCKER_LOCAL_REGISTRY:-$DOCKERHUB_USERNAME}}"
    [[ -z $__registry ]] && echo "Registry must be provided." >&2 && exit 1


    # Load recipes after setting up the registry variable
    load_recipes

    # If recipe is provided, set the parameters from there.
    if [[ -n $__recipe ]]; then
        __layers=""
        for __recipe_info in "${__recipes[@]}"; do

            __recipe_name=$(echo $__recipe_info | cut -d'|' -f1)

            if [[ "$__recipe" == "$__recipe_name" ]]; then
                __layers="$(echo $__recipe_info | cut -d'|' -f2)"
                __recipe_base="$(echo $__recipe_info | cut -d'|' -f3)"

                if [[ -n $__recipe_base ]]; then
                    __base_image=$__recipe_base
                fi

                break
            fi
        done
        [[ -z $__layers ]] \
            && echo "$__recipe not found or its layers are not defined" >&2 \
            && exit 1
    fi

    # Validate layers
    [[ -z $__layers ]] && echo "layers are not provided" >&2 && exit 1
    IFS=',' read -ra __layers <<< "$__layers"

    # Validate image name
    if [[ -z $__image_name && -n $__recipe_name ]]; then
        __image_name=$__recipe_name
    fi
    [[ -z $__image_name ]] && echo "Image name is not provided" >&2 && exit 1


    # If current_user flag is set, then set the USER_ID and GROUP_ID to
    # the host's current user id.
    if (( current_user == 1 )); then
        __user_id_args="--build-arg USER_ID=$(id -u ${USER}) \
                        --build-arg GROUP_ID=$(id -g ${USER})"
    fi

    # If --platform option is provided, then use `buildx build` instead.
    if [[ -n $__platform ]]; then
        __build_cmd="buildx build"
    else
        __build_cmd="build"
    fi

    # Build images ordered based on the stack array.
    # Each image is the base for the next one.
    for __layer in "${__layers[@]}"; do
        docker ${__build_cmd} ${__layer}/${__distro_like}/ \
            -t ${__registry}/${__image_name}:${__image_tag} \
            --build-arg BASE_IMAGE=${__base_image} \
            --build-arg USER=${__user} \
            ${__user_id_args} ${__platform} ${__push} ${__no_cache}

        if (( $? != 0 )); then
            exit 1
        fi

        __base_image=${__registry}/${__image_name}:${__image_tag}
    done

    # Prune the dangling images if building without using buildx.
    if [[ -z $__platform ]]; then
        docker image prune -f
    fi
}

main "${@}"
