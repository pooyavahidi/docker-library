ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Install prerequisites
RUN apt-get update \
	&& apt-get install -y \
		curl
# Install nodejs LTS
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
	&& apt-get install -y \
		nodejs
