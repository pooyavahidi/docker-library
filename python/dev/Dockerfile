ARG BASE_IMAGE=debian:latest
FROM ${BASE_IMAGE}

# Install required packaged for python development 
RUN apt-get update \
	&& apt-get install -y \
		python3 \
		python3-venv \
		python3-pip
