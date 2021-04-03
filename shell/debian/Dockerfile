ARG BASE_IMAGE=pooyavahidi/ubuntu-dev:latest
FROM ${BASE_IMAGE}

# Install prerequisites 
RUN apt-get update \
	&& apt-get install -y \
		rsync \
		tmux \
		tree \
		unzip \
		vim \
		wget \
		zsh

# Internal username named `cu` as `Container User`
ARG USER=cu
# Set both user id and group id to 61000 to make sure it's out of range of 
# existing uids in the host and there would be no overlaping. 
ARG USER_ID=61000
ARG GROUP_ID=61000

# Create a system account with specified UID and GID without root privilages. 
# --no-log-init is to be used to avoid the known issue on the high value IDs.
# Also chown the required directories to be owned by this new internal users.
RUN groupadd -g ${GROUP_ID} --system ${USER} \ 
	&& useradd --no-log-init --system -u ${USER_ID} -g ${GROUP_ID} ${USER} \
	&& mkdir /home/${USER} \
	&& chown --recursive ${USER_ID}:${GROUP_ID} \
		/home/${USER}

USER ${USER}

VOLUME /home/${USER}

# Set the working dir to the user's home.
WORKDIR "/home/${USER}"

# Create workspace directories 
RUN mkdir workspace workspace/temp

# Setup the dotfiles
RUN cd workspace \
	&& wget https://github.com/pooyavahidi/dotfiles/archive/refs/heads/master.zip \
	&& unzip master.zip \
	&& cd dotfiles-master \
	&& ./bootstrap.sh \ 
	&& cd ~ \
	&& rm -rf workspace/dotfiles-master \
	&& rm workspace/master.zip

ENV SHELL="/bin/zsh"

CMD ["/bin/zsh"]
