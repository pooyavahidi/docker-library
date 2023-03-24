ARG BASE_IMAGE=ubuntu:latest
FROM ${BASE_IMAGE}

# Install required packaged for python development 
RUN apt-get update \
    && apt-get install -y \
        python3 \
        python3-venv \
        python3-pip \
    && pip3 install -U \
        pylint \
        pycodestyle \
        black
