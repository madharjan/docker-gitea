#!/bin/bash
set -e
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

if [ "${DEBUG}" = true ]; then
  set -x
fi

GITEA_CONFIG_PATH=/build/config
GITEA_CUSTOM_PATH=/build/custom

apt-get update

## Install Gitea and runit service
/build/services/gitea/gitea.sh

mkdir -p /config/etc/gitea
mkdir -p /config/templates

cp ${GITEA_CONFIG_PATH}/app.ini /config/etc/gitea/app.ini
cp -r ${GITEA_CUSTOM_PATH}/* /config/templates

mkdir -p /etc/my_init.d
cp /build/services/20-gitea.sh /etc/my_init.d
chmod 750 /etc/my_init.d/20-gitea.sh

cp /build/bin/gitea-systemd-unit /usr/local/bin
chmod 750 /usr/local/bin/gitea-systemd-unit
