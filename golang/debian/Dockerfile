ARG BASE_IMAGE=debian:latest
FROM ${BASE_IMAGE}

RUN apt-get update \
	&& apt-get install -y \
		dirmngr \
		gnupg \
		wget

ENV PATH /usr/local/go/bin:$PATH
ENV GOLANG_VERSION 1.16.2

RUN	set -eux; \
		dpkgArch=$(dpkg --print-architecture); \
		case "${dpkgArch##-}" in \
			"amd64") \
				url="https://golang.org/dl/go1.16.2.linux-amd64.tar.gz"; \
				sha256="542e936b19542e62679766194364f45141fde55169db2d8d01046555ca9eb4b8"; \
				;; \
			"arm64") \
				url="https://golang.org/dl/go1.16.2.linux-arm64.tar.gz"; \
				sha256="6924601d998a0917694fd14261347e3798bd2ad6b13c4d7f2edd70c9d57f62ab"; \
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
		gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys 'EB4C 1BFD 4F04 2F6D DDCC EC91 7721 F63B D38B 4796'; \
		gpg --batch --verify go.tgz.asc go.tgz; \
		gpgconf --kill all; \
		rm -rf "$GNUPGHOME" go.tgz.asc; \
		\
		tar -C /usr/local -xzf go.tgz; \
		rm go.tgz; \
		\
        # Check the go version and verify the installation
		go version


ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
