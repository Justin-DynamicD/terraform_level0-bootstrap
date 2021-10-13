ARG BUILDKITCLI_VER=0.1.2
ARG IMAGE_BASE=ubuntu
ARG IMAGE_TAG=20.04
ARG HELM_VER=3.6.0
#ARG ANSIBLE_VER=2.10.0
ARG AWSCLI_VER=2.1.32
ARG KUBECTL_VER=1.20.2
ARG PACKER_VER=1.7.2
ARG TERRAFORM_VER=1.0.0
ARG USER_NAME=rover
ARG USER_UID=1000

###########################################
# build Container
###########################################

FROM ${IMAGE_BASE}:${IMAGE_TAG} AS builder

ARG BUILDKITCLI_VER
ARG HELM_VER
ARG KUBECTL_VER
ARG PACKER_VER
ARG TERRAFORM_VER

# these args are used by the apt-get to suppress prompts
ARG DEBIAN_FRONTEND=noninteractive
ARG ACCEPT_EULA=y

RUN apt-get update && apt-get install -y \
    tar \
    unzip \
    wget \
  && rm -rf /var/lib/apt/lists/*

# setup staging dirs
RUN mkdir /staging \
  && mkdir /staging/bin \
  && mkdir /staging/zips

# install Hashitools
RUN wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip" -O /staging/zips/terraform.zip \
  && wget "https://releases.hashicorp.com/packer/${PACKER_VER}/packer_${PACKER_VER}_linux_amd64.zip" -O /staging/zips/packer.zip \
  && unzip /staging/zips/terraform.zip -d /staging/bin \
  && unzip /staging/zips/packer.zip -d /staging/bin

# install kubectl
RUN wget "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VER}/bin/linux/amd64/kubectl" -O /staging/bin/kubectl \
  && chmod 755 /staging/bin/kubectl

# install buildkit-cli-for-kubectl
RUN wget "https://github.com/vmware-tanzu/buildkit-cli-for-kubectl/releases/download/v${BUILDKITCLI_VER}/linux-v${BUILDKITCLI_VER}.tgz" -O /staging/zips/buildkit.tgz \
  && cat /staging/zips/buildkit.tgz | tar -zC /staging/bin -xvf - \
  && chmod 755 /staging/bin/kubectl-*

# install Helm 3
RUN wget "https://get.helm.sh/helm-v${HELM_VER}-linux-amd64.tar.gz" -O - | tar -xzO linux-amd64/helm > /staging/bin/helm \
  && chmod 755 /staging/bin/helm

# install oh-my-posh
RUN wget "https://github.com/JanDeDobbeleer/oh-my-posh3/releases/latest/download/posh-linux-amd64" -O /staging/bin/oh-my-posh \
  && chmod 755 /staging/bin/oh-my-posh

###########################################
# Final Container
###########################################

FROM ${IMAGE_BASE}:${IMAGE_TAG}

ARG ANSIBLE_VER
ARG AWSCLI_VER
ARG USER_NAME
ARG USER_UID
ARG USER_GID=${USER_UID}

# these args are used by the apt-get to suppress prompts
ARG DEBIAN_FRONTEND=noninteractive
ARG ACCEPT_EULA=y

# Copy over pre-downloaded tools
COPY --from=builder /staging/bin /usr/local/bin

# setup workspace as a staging dir
WORKDIR /workspace
RUN chmod 777 -R /workspace

# Install required tools
# user tools: git git-lfs subversion zip unzip curl wget
# vscode integration: sudo
# ado agent: libcurl4 libicu60 libicu66 libunwind8 netcat iputils-ping
# ansible: python3-pip
# tfinit script: jq

RUN apt-get update && apt-get install -y \
    curl \
    git \
    git-lfs \
    iputils-ping \
    jq \
    libcurl4 \
    libicu66 \
    libssl1.0 \
    libunwind8 \
    netcat \
#    python3-pip \
    subversion \
    sudo \
    unzip \
    wget \
    zip \
  && rm -rf /var/lib/apt/lists/*

# install Ansible
# RUN pip3 install jinja2 \
#   && pip3 install setuptools \
#   && pip3 install ansible==${ANSIBLE_VER}

# install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VER}.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install \
  && rm -rf aws \
  && rm awscliv2.zip

# Install Azure CLI
# RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# create the user account
RUN echo "Creating ${USER_NAME} user..." \
  && groupadd --gid ${USER_GID} ${USER_NAME} \
  && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USER_NAME} \
  && mkdir -p \
    /home/${USER_NAME}/.ansible \
    /home/${USER_NAME}/.azure \
    /home/${USER_NAME}/.gnupg \
    /home/${USER_NAME}/.packer.d \
    /home/${USER_NAME}/.ssh \
    /home/${USER_NAME}/.ssh-localhost \
    /home/${USER_NAME}/.terraform.cache \
    /home/${USER_NAME}/.terraform.cache/tfstates \
    /home/${USER_NAME}/.vscode-server \
    /home/${USER_NAME}/.vscode-server-insiders \
  && chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME} \
  && chmod 751 -R /home/${USER_NAME} \
  && chmod 700 /home/${USER_NAME}/.ssh \
  && echo ${USER_NAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USER_NAME} \
  && chmod 0440 /etc/sudoers.d/${USER_NAME}

# install tfinit script and theme
COPY posh-theme/ /posh-theme
COPY rover/ /rover
RUN chmod +x /rover/* \
  && chmod 755 -R /rover /posh-theme \
  && chown -R ${USER_NAME}:${USER_NAME} /rover /posh-theme \
  && echo "eval \"\$(oh-my-posh --init --shell bash --config /posh-theme/default.json)\"" >> /home/${USER_NAME}/.bashrc \
  && echo "alias tfinit=/rover/tfinit.sh" >> /home/${USER_NAME}/.bashrc \
  && echo "echo \"shell is intended to use monospace nerdfonts (www.nerdfonts.com)\"" >> /home/${USER_NAME}/.bashrc

# flush workspace for local dev
WORKDIR /workspace
RUN rm -rf *

# install azure build agent for default operation
WORKDIR /azp
COPY ./start.sh .
RUN chmod +x start.sh \
  && chmod 755 -R /azp \
  && chown -R ${USER_NAME}:${USER_NAME} /azp

USER ${USER_NAME}
CMD ["./start.sh"]