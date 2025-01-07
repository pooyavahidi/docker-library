ARG BASE_IMAGE=ubuntu:latest
FROM ${BASE_IMAGE}

# Using Prebuilt binaries from the official github repo.
# More details here at https://github.com/gohugoio/hugo/releases
ARG HUGO_VERSION=0.140.2
ARG URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-"

RUN set -eux; \
    apt-get update \
    && apt-get install -y \
        wget \
		git

# Install Hugo
RUN set -eux; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        "amd64") \
            arch="amd64"; \
            sha256="fe765fa8ad9d43bc13e64ee27e0b45d55182b8cf298c5bca2e46cc0889e6826c"; \
            ;; \
        "arm64") \
            arch="arm64"; \
            sha256="df045d91abc7ca58906447af560b0cfcedaad3059275d0de5f6725bf594c3114"; \
            ;; \
        *) echo "error: unsupported architecture ${dpkgArch}" >&2; exit 1 ;; \
    esac; \
    wget -O hugo.deb "${URL}${arch}.deb" --progress=dot:giga \
    && echo "$sha256 hugo.deb" | sha256sum --strict --check - \
    && dpkg -i hugo.deb \
    && rm hugo.deb \
    && hugo version

CMD ["/bin/bash"]
