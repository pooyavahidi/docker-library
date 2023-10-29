ARG BASE_IMAGE=ubuntu:latest
FROM ${BASE_IMAGE}

# Based on the official source at:
# https://github.com/ContinuumIO/docker-images/blob/master/anaconda3/debian/Dockerfile

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV ANACONDA_HOME /opt/anaconda3
ENV PATH ${ANACONDA_HOME}/bin:$PATH
ENV ANACONDA_VERSION 2023.09-0

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
# https://docs.anaconda.com/free/anaconda/reference/hashes/lin-3-64/
RUN dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        "amd64") \
            url="https://repo.anaconda.com/archive/Anaconda3-${ANACONDA_VERSION}-Linux-x86_64.sh"; \
            sha256="6c8a4abb36fbb711dc055b7049a23bbfd61d356de9468b41c5140f8a11abd851"; \
            ;; \
        "arm64"|"aarch64") \
            url="https://repo.anaconda.com/archive/Anaconda3-${ANACONDA_VERSION}-Linux-aarch64.sh"; \
            sha256="69ee26361c1ec974199bce5c0369e3e9a71541de7979d2b9cfa4af556d1ae0ea"; \
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
