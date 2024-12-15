ARG BASE_IMAGE=ubuntu:latest
FROM ${BASE_IMAGE}


RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        dirmngr \
        gnupg \
        wget \
    && rm -rf /var/lib/apt/lists/*

ENV PATH=/usr/local/go/bin:$PATH

# Install Golang using the official source at:
# https://github.com/docker-library/golang/blob/master/1.20/bullseye/Dockerfile

ENV GOLANG_VERSION=1.20.2

RUN set -eux; \
        dpkgArch="$(dpkg --print-architecture)"; \
        case "${dpkgArch##*-}" in \
            "amd64") \
                url="https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz"; \
                sha256="4eaea32f59cde4dc635fbc42161031d13e1c780b87097f4b4234cfce671f1768"; \
                ;; \
            "arm64") \
                url="https://dl.google.com/go/go${GOLANG_VERSION}.linux-arm64.tar.gz"; \
                sha256="78d632915bb75e9a6356a47a42625fd1a785c83a64a643fedd8f61e31b1b3bef"; \
                ;; \
            *) echo "error: unsupported architecture ${dpkgArch}" >&2; exit 1 ;; \
        esac; \
        wget -O go.tgz.asc "${url}.asc" --progress=dot:giga; \
        wget -O go.tgz "${url}" --progress=dot:giga; \
        echo "$sha256 *go.tgz" | sha256sum --strict --check -; \
        \
        export GNUPGHOME="$(mktemp -d)"; \
        # Verify the signature of downloaded packages
        # https://www.google.com/linuxrepositories/
        gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 'EB4C 1BFD 4F04 2F6D DDCC EC91 7721 F63B D38B 4796'; \
        gpg --batch --verify go.tgz.asc go.tgz; \
        gpgconf --kill all; \
        rm -rf "$GNUPGHOME" go.tgz.asc; \
        \
        tar -C /usr/local -xzf go.tgz; \
        rm go.tgz; \
        \
        # Check the go version and verify the installation
        go version


ENV GOPATH=$HOME/go
ENV PATH=$GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
