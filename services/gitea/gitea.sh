#!/bin/bash
set -e
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

if [ "${DEBUG}" = true ]; then
  set -x
fi

GITEA_BUILD_PATH=/build/services/gitea
GITEA_VERSION=1.8.2

## Install Nginx.
apt-get install -y --no-install-recommends git-core iproute2

## Install Gitea Server
wget -nv "https://github.com/go-gitea/gitea/releases/download/v${GITEA_VERSION}/gitea-${GITEA_VERSION}-linux-amd64" -O /usr/local/bin/gitea
#wget -nv "https://dl.gitea.io/gitea/${GITEA_VERSION}/gitea-${GITEA_VERSION}-linux-amd64" -O /usr/local/bin/gitea
chmod +x /usr/local/bin/gitea

## Create 'git' user/group
adduser \
   --system \
   --shell /bin/bash \
   --gecos 'Git Version Control' \
   --group \
   --disabled-password \
   --home /home/git \
   git

mkdir -p /etc/service/gitea
cp ${GITEA_BUILD_PATH}/gitea.runit /etc/service/gitea/run
chmod 750 /etc/service/gitea/run

## Configure logrotate
