ARG BASE_IMAGE
from golang:1.16.3-buster as builder

ARG HUGO_VERSION=v0.82.0

# Clone the gohugo and install the latest version 
RUN set -eux; \
    apt-get update; \
    apt-get install -y \
		git; \
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
	rm -rf /var/lib/apt/lists/*;

# Build the final image
FROM ${BASE_IMAGE}

COPY --from=builder /go/bin/ bin/

CMD ["/bin/bash"]
