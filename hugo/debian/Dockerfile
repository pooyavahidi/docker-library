ARG BASE_IMAGE=ubuntu:latest
FROM ${BASE_IMAGE}

# Using Prebuilt binaries from the official github repo.
# More details here at https://gohugo.io/hosting-and-deployment/hosting-on-github/
ARG HUGO_VERSION=0.140.2
ARG URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_"

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
            file_name="linux-amd64.deb"; \
            ;; \
        "arm64") \
            file_name="linux-arm64.deb"; \
            ;; \
        *) echo "error: unsupported architecture ${dpkgArch}" >&2; exit 1 ;; \
    esac; \
    wget -O hugo.deb "${URL}${file_name}" --progress=dot:giga \
    && dpkg -i hugo.deb \
    && rm hugo.deb \
    && hugo version

CMD ["/bin/bash"]
