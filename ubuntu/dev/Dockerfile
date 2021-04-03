ARG BASE_IMAGE=ubuntu:latest
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND noninteractive

# Install basic tools
RUN set -eux \
    && apt-get update && apt-get install -y \
		curl \
		dirmngr \
		git \
		gnupg \
		unzip \
		wget \
	&& rm -rf /var/lib/apt/lists/*
