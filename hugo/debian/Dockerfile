ARG BASE_IMAGE=ubuntu:latest
FROM ${BASE_IMAGE}

# Using Prebuilt binaries from the official github repo.
# More details here at https://github.com/gohugoio/hugo/releases
ARG HUGO_VERSION=0.143.1
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
            sha256="2681aadfc2e33f0b67343f1994e406955f54522ad973f1e307ebe441ef0eefb6"; \
            ;; \
        "arm64") \
            arch="arm64"; \
            sha256="fa749ab5b8d03f0e756ab3f62be273d68a6db677d8944c540eece3821c669ed6"; \
            ;; \
        *) echo "error: unsupported architecture ${dpkgArch}" >&2; exit 1 ;; \
    esac; \
    wget -O hugo.deb "${URL}${arch}.deb" --progress=dot:giga \
    && echo "$sha256 hugo.deb" | sha256sum --strict --check - \
    && dpkg -i hugo.deb \
    && rm hugo.deb \
    && hugo version | grep v${HUGO_VERSION}

CMD ["/bin/bash"]
