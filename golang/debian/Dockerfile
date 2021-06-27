ARG BASE_IMAGE=debian:latest
FROM ${BASE_IMAGE}

RUN apt-get update \
	&& apt-get install -y \
		dirmngr \
		gnupg \
		wget

ENV PATH /usr/local/go/bin:$PATH
ENV GOLANG_VERSION 1.16.5

RUN	set -eux; \
		dpkgArch=$(dpkg --print-architecture); \
		case "${dpkgArch##-}" in \
			"amd64") \
				url="https://golang.org/dl/go1.16.5.linux-amd64.tar.gz"; \
				sha256="b12c23023b68de22f74c0524f10b753e7b08b1504cb7e417eccebdd3fae49061"; \
				;; \
			"arm64") \
				url="https://golang.org/dl/go1.16.5.linux-arm64.tar.gz"; \
				sha256="d5446b46ef6f36fdffa852f73dfbbe78c1ddf010b99fa4964944b9ae8b4d6799"; \
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


ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
