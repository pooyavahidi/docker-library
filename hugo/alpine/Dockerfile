ARG BASE_IMAGE
FROM golang:1.23.4-alpine3.21 as builder

ARG HUGO_VERSION=v0.140.2

# Clone the gohugo and install the latest version
RUN set -eux; \
    apk update; \
    apk add --no-cache --virtual .build-deps git; \
    \
	go version; \
	git clone https://github.com/gohugoio/hugo.git /tmp/hugo; \
	cd /tmp/hugo; \
	git checkout tags/${HUGO_VERSION}; \
	go install; \
	cd /; \
	rm -rf /tmp/hugo; \
	\
	hugo version; \
    apk del .build-deps

RUN apk add bash \
			curl \
			unzip

FROM ${BASE_IMAGE}
COPY --from=builder /go/bin/ bin/
RUN apk update \
	&& apk add bash

CMD ["/bin/bash"]
