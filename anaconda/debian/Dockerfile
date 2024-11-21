ARG BASE_IMAGE=ubuntu:latest
FROM ${BASE_IMAGE}

# Based on the official source at:
# https://github.com/anaconda/docker-images/blob/main/anaconda3/debian/Dockerfile

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV ANACONDA_HOME=/opt/anaconda3
ENV PATH=${ANACONDA_HOME}/bin:$PATH
ENV ANACONDA_VERSION=2024.10-1

# Anaconda hashes:
# https://repo.anaconda.com/archive/

# x86_64
ARG INSTALLER_URL_AMD64="https://repo.anaconda.com/archive/Anaconda3-${ANACONDA_VERSION}-Linux-x86_64.sh"
ARG SHA256SUM_AMD64="3ba0a298155c32fbfd80cbc238298560bf69a2df511783054adfc151b76d80d8"
# arm64 (aarch64)
ARG INSTALLER_URL_AARCH64="https://repo.anaconda.com/archive/Anaconda3-${ANACONDA_VERSION}-Linux-aarch64.sh"
ARG SHA256SUM_AARCH64="489c608e8bddd2cf29dfbdd811cf99087cd6b6a0615d41c6f9058ce340594b65"

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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        "amd64") \
            url="${INSTALLER_URL_AMD64}"; \
            sha256="${SHA256SUM_AMD64}"; \
            ;; \
        "arm64"|"aarch64") \
            url="${INSTALLER_URL_AARCH64}"; \
            sha256="${SHA256SUM_AARCH64}"; \
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
