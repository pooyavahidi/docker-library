ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Pull the docker-in-docker image and copy the docker cli to the base image.
COPY --from=docker:20.10 /usr/local/bin/docker /usr/local/bin/
