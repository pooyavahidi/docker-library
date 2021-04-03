ARG BASE_IMAGE
FROM golang:1.16-buster as builder

# Install tools
RUN apt update \
	&& apt install -y \
		git 

ARG HUGO_VERSION=v0.82.0

# Clont the gohugo and install the latest version 
RUN set -eux; \
	go version; \
	git clone https://github.com/gohugoio/hugo.git /tmp/hugo; \
	cd /tmp/hugo; \
	git checkout tags/${HUGO_VERSION}; \
	go install; \
	cd /; \
	rm -rf /tmp/hugo; \
	\
	hugo version

FROM ${BASE_IMAGE}
COPY --from=builder /go/bin/ bin/
