ARG BASE_IMAGE=ubuntu:latest
FROM ${BASE_IMAGE}

# Based on the official source at:
# https://github.com/ContinuumIO/docker-images/blob/master/anaconda3/debian/Dockerfile

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV ANACONDA_HOME /opt/anaconda3
ENV ANACONDA_VERSION 2023.03
ENV PATH ${ANACONDA_HOME}/bin:$PATH

RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        libglib2.0-0 \
        libsm6 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxi6 \
        libxinerama1 \
        libxrandr2 \
        libxrender1 \
        wget \
    && rm -rf /var/lib/apt/lists/*

# Anaconda hashes
# https://docs.anaconda.com/anaconda/install/hashes/lin-3-64/
RUN dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        "amd64") \
            url="https://repo.anaconda.com/archive/Anaconda3-${ANACONDA_VERSION}-Linux-x86_64.sh"; \
            sha256="19737d5c27b23a1d8740c5cb2414bf6253184ce745d0a912bb235a212a15e075"; \
            ;; \
        "arm64"|"aarch64") \
            url="https://repo.anaconda.com/archive/Anaconda3-${ANACONDA_VERSION}-Linux-aarch64.sh"; \
            sha256="613797154d9383355677f7dfee10db32b2c327cbedabddcb303598f242c79883"; \
            ;; \
        *) echo "error: unsupported architecture ${dpkgArch}" >&2; exit 1 ;; \
    esac \
    && wget "${url}" -O anaconda.sh --progress=dot:giga \
    && echo "${sha256} anaconda.sh" | sha256sum --check --strict - \
    && /bin/bash anaconda.sh -b -p "${ANACONDA_HOME}" \
    && rm anaconda.sh \
    && find "${ANACONDA_HOME}"/ -follow -type f -name '*.a' -delete \
    && find "${ANACONDA_HOME}"/ -follow -type f -name '*.js.map' -delete \
    && conda clean -afy \
    && conda init bash

CMD [ "/bin/bash" ]
