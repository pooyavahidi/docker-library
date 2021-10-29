ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Install prerequisites 
RUN apt-get update \
    && apt-get install -y \
        git \
        rsync \
        tmux \
        tree \
        unzip \
        util-linux \
        vim \
        wget \
        zsh

# Internal username named `cu` short for `Container User`
ARG USER=cu

# Set both user id and group id to 61000 to make sure it's out of range of 
# existing uids in the host and there would be no overlaping. 
ARG USER_ID=61000
ARG GROUP_ID=61000

# If set then the USER will be added to the sudoers group
ARG ENABLE_SUDO=1

# Create a system account with specified UID and GID without root privilages. 
# --no-log-init is to be used to avoid the known issue on the high value IDs.
# Also chown the required directories to be owned by this new internal users.
RUN groupadd -g ${GROUP_ID} --system ${USER} \ 
    && useradd --no-log-init --system -u ${USER_ID} -g ${GROUP_ID} ${USER} \
    && mkdir /home/${USER} \
    && chown --recursive ${USER_ID}:${GROUP_ID} /home/${USER}

# If ENABLE_SUDO is set to 1 then install sudo and add the USER to the sudoers
RUN if [ "${ENABLE_SUDO}" = 1 ]; then \
        apt-get install -y sudo \
        && usermod -aG sudo ${USER} \
        # Members of sudoers group can use sudo without providing password
        && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers; \
    fi

USER ${USER}

# Set the working dir to the user's home.
WORKDIR "/home/${USER}"

# Download and bootstrap the dotfiles
RUN cd /tmp \
    && wget https://github.com/pooyavahidi/dotfiles/archive/refs/heads/master.zip \
    && unzip master.zip \
    && cd dotfiles-master \
    && ./bootstrap.sh \
    && cd /tmp \
    && rm -rf dotfiles-master \
    && rm master.zip

ENV SHELL="/bin/zsh"

CMD ["/bin/zsh"]
