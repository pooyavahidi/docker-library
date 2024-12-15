ARG BASE_IMAGE=ubuntu:latest
FROM ${BASE_IMAGE}

RUN set -eux \
# Check if npm is already installed
	&& npm --version \
	&& npm install -g typescript \
	&& tsc --version \
	&& npm install -g aws-cdk \
	&& cdk --version
