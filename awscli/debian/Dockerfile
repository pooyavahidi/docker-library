ARG BASE_IMAGE
FROM debian:latest as builder

RUN set -eux \
	&& apt-get update \
	&& apt-get install -y \
		dirmngr \                                                                                                              
		gnupg \
		unzip \
		wget
WORKDIR /tmp 
# Install AWS CLI v2
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html

# Copy the awscli public key for verifying the downloaded package
COPY awscli_public_key .

RUN	set -eux; \
	dpkgArch=$(dpkg --print-architecture); \                                                                               
	case "${dpkgArch##-}" in \                                                                                             
			"amd64") \
				url="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"; \
				;; \
			"arm64") \
				url="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"; \
				;; \
			*) echo "error: unsupported architecture ${dpkgArch}"; exit 1 ;; \
	esac; \
	wget -O awscliv2.zip "${url}" --progress=dot:giga; \
	wget -O awscliv2.zip.sig "${url}.sig" --progress=dot:giga; \
	\
	export GNUPGHOME="$(mktemp -d)"; \
	# Verify the signature of downloaded packages 
	gpg --import awscli_public_key; \
	gpg --verify awscliv2.zip.sig awscliv2.zip; \
	unzip -q awscliv2.zip

FROM ${BASE_IMAGE}
COPY --from=builder /tmp/aws /tmp/
RUN set -eux; \
	/tmp/install -i /usr/local/aws-cli -b /usr/local/bin; \
	rm -Rf /tmp/*; \
	aws --version