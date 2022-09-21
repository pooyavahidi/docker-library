ARG BASE_IMAGE=debian:latest
FROM ${BASE_IMAGE}

RUN apt-get update \
    && apt-get install -y \
        dirmngr \
        gnupg \
        wget

ENV PATH /usr/local/go/bin:$PATH
ENV GOLANG_VERSION 1.19.1

RUN set -eux; \
        dpkgArch=$(dpkg --print-architecture); \
        case "${dpkgArch##-}" in \
            "amd64") \
                url="https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz"; \
                sha256="acc512fbab4f716a8f97a8b3fbaa9ddd39606a28be6c2515ef7c6c6311acffde"; \
                ;; \
            "arm64") \
                url="https://dl.google.com/go/go${GOLANG_VERSION}.linux-arm64.tar.gz"; \
                sha256="49960821948b9c6b14041430890eccee58c76b52e2dbaafce971c3c38d43df9f"; \
                ;; \
            *) echo "error: unsupported architecture ${dpkgArch}"; exit 1 ;; \
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


ENV GOPATH $HOME/go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
