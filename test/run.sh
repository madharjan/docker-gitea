#!/bin/bash

set -x

DIR=$(dirname $0)
$DIR/clean.sh

sudo mkdir -p /opt/docker/gitea/postgresql/etc/
sudo mkdir -p /opt/docker/gitea/postgresql/lib/
sudo mkdir -p /opt/docker/gitea/postgresql/log/

docker run -d -t \
  -e DEBUG=false \
  -e POSTGRESQL_DATABASE=gitea \
  -e POSTGRESQL_USERNAME=gitea \
  -e POSTGRESQL_PASSWORD=Pa55w0rd \
  -v /opt/docker/gitea/postgresql/etc:/etc/postgresql/9.5/main \
  -v /opt/docker/gitea/postgresql/lib:/var/lib/postgresql/9.5/main \
  -v /opt/docker/gitea/postgresql/log:/var/log/postgresql \
  --name gitea-postgresql \
  madharjan/docker-postgresql:9.5

sleep 3
#docker logs gitea-postgresql

sudo mkdir -p /opt/docker/gitea/etc/
sudo mkdir -p /opt/docker/gitea/lib/
sudo mkdir -p /opt/docker/gitea/log/

docker run -d -t \
  -e DEBUG=true \
  --link gitea-postgresql:postgresql \
  -e GITEA_PROTOCOL=http \
  -e GITEA_DOMAIN=192.168.56.254 \
  -e GITEA_SMTP_PORT=2525 \
  -e GITEA_REGISTRATION_DISABLE=false \
  -e GITEA_INSTALL_LOCK=true \
  -e GITEA_SECRET_KEY=1234567890 \
  -e GITEA_JWT_SECRET=6Lfjq6YUAAAAAFwDmDtfHyHmL1234567890 \
  -e GITEA_ROOT_EMAIL=root@local.host \
  -e GITEA_ROOT_PASSWORD=Pa55w0rd \
  -p 80:3000 \
  -v /opt/docker/gitea/etc:/etc/gitea \
  -v /opt/docker/gitea/lib:/var/lib/gitea \
  -v /opt/docker/gitea/log:/var/log/gitea \
  --name gitea \
  madharjan/docker-gitea:1.8.2

sleep 2
docker logs -f gitea
