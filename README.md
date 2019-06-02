# docker-gitea

[![Build Status](https://travis-ci.com/madharjan/docker-gitea.svg?branch=master)](https://travis-ci.com/madharjan/docker-gitea)
[![Layers](https://images.microbadger.com/badges/image/madharjan/docker-gitea.svg)](http://microbadger.com/images/madharjan/docker-gitea)

Docker container for Gitea Server based on [madharjan/docker-base](https://github.com/madharjan/docker-base/)

## Features

* Environment variables to set database setting or link to postgresql container
* Environment variables to configure Gitea
* Bats [bats-core/bats-core](https://github.com/bats-core/bats-core) based test cases

## Gitea 1.8.2 (docker-gitea)

### Environment

| Variable                   | Default                | Example        |
| -------------------------- | ---------------------- | -------------- |
| DISABLE_GITEA              | 0                      | 1 (to disable) |
|                            |                        |                |
| GITEA_PROTOCOL             | http                   | https          |
| GITEA_DOMAIN               | localhost              |                |
|                            |                        |                |
| GITEA_SMTP_HOST            | localhost              |                |
| GITEA_SMTP_PORT            | 25                     |                |
| GITEA_SMTP_FROM            | gitea@localhost        |                |
| GITEA_SMTP_USER            | pass                   |                |
| GITEA_SMTP_PASS            | pass                   |                |
|                            |                        |                |
| GITEA_REGISTRATION_DISABLE | false                  |                |
| GITEA_RECAPTCHA_SECRET     |                        |                |
| GITEA_RECAPTCHA_KEY        |                        |                |
|                            |                        |                |
| GITEA_INSTALL_LOCK         | false                  |                |
| GITEA_SECRET_KEY           |                        |                |
| GITEA_JWT_SECRET           |                        |                |
|                            |                        |                |
| GITEA_ROOT_EMAIL           | root@localhost         |                |
| GITEA_ROOT_PASSWORD        | Git3aPa55              |                |
|                            |                        |                |
| GITEA_DB_TYPE              | postgres               |                |
| GITEA_DB_HOST              | linked to 'postgresql' | 172.17.0.1     |
| GITEA_DB_PORT              | linked to 'postgresql' | 5432           |
| GITEA_DB_USER              | linked to 'postgresql' | gitea          |
| GITEA_DB_PASS              | linked to 'postgresql' | gitea          |

## Build

```bash
# clone project
git clone https://github.com/madharjan/docker-gitea
cd docker-gitea

# build
make

# tests
make run
make test

# clean
make clean
```

## Run

**Note**: update environment variables below as necessary

```bash
# prepare foldor on host for container volumes
sudo mkdir -p /opt/docker/gitea/postgresql/etc/
sudo mkdir -p /opt/docker/gitea/postgresql/lib/
sudo mkdir -p /opt/docker/gitea/postgresql/log/

# stop & remove previous instances
docker stop gitea-postgresql
docker rm gitea-postgresql

# run container
docker run -d \
  -e POSTGRESQL_DATABASE=gitea \
  -e POSTGRESQL_USERNAME=gitea \
  -e POSTGRESQL_PASSWORD=Pa55w0rd \
  -v /opt/docker/gitea/postgresql/etc:/etc/postgresql/9.5/main \
  -v /opt/docker/gitea/postgresql/lib:/var/lib/postgresql/9.5/main \
  -v /opt/docker/gitea/postgresql/log:/var/log/postgresql \
  --name gitea-postgresql \
  madharjan/docker-postgresql:9.5

# prepare foldor on host for container volumes
sudo mkdir -p /opt/docker/gitea/etc/
sudo mkdir -p /opt/docker/gitea/lib/
sudo mkdir -p /opt/docker/gitea/log/

# stop & remove previous instances
docker stop gitea
docker rm gitea

# run container linked with gitea-postgresql
docker run -d \
  --link gitea-postgresql:postgresql \
  -e GITEA_INSTALL_LOCK=true \
  -e GITEA_SECRET_KEY=1234567890 \
  -e GITEA_JWT_SECRET=6Lfjq6YUAAAAAFwDmDtfHyHmL1234567890 \
  -e GITEA_ROOT_PASSWORD=Pa55w0rd \
  -p 3000:3000 \
  -v /opt/docker/gitea/etc:/etc/gitea \
  -v /opt/docker/gitea/lib:/var/lib/gitea \
  -v /opt/docker/gitea/log:/var/log/gitea \
  --name gitea \
  madharjan/docker-gitea:1.8.2
```

## Systemd Unit File

**Note**: update environment variables below as necessary

```txt
[Unit]
Description=Gitea Server

After=docker.service

[Service]
TimeoutStartSec=0

ExecStartPre=-/bin/mkdir -p /opt/docker/gitea/etc
ExecStartPre=-/bin/mkdir -p /opt/docker/gitea/lib
ExecStartPre=-/bin/mkdir -p /opt/docker/gitea/log
ExecStartPre=-/usr/bin/docker stop gitea
ExecStartPre=-/usr/bin/docker rm gitea
ExecStartPre=-/usr/bin/docker pull madharjan/docker-gitea:9.5

ExecStart=/usr/bin/docker run \
  --link odoo-postgresql:postgresql \
  -e GITEA_INSTALL_LOCK=true \
  -e GITEA_SECRET_KEY=1234567890 \
  -e GITEA_JWT_SECRET=6Lfjq6YUAAAAAFwDmDtfHyHmL1234567890 \
  -e GITEA_ROOT_PASSWORD=Pa55w0rd \
  -p 80:3000 \
  -v /opt/docker/gitea/etc:/etc/gitea \
  -v /opt/docker/gitea/lib:/var/lib/gitea \
  -v /opt/docker/gitea/log:/var/log/gitea \
  --name gitea \
  madharjan/docker-gitea:1.0

ExecStop=/usr/bin/docker stop -t 2 gitea

[Install]
WantedBy=multi-user.target
```

## Generate Systemd Unit File

| Variable                   | Default     | Example              |
| -------------------------- | ----------- | -------------------- |
| NAME                       | gitea       |                      |
| VOLUME_HOME                | /opt/docker | /opt/data            |
| PORT                       |             | 8080                 |
| LINK_CONTAINERS            |             | postgresql           |
|                            |             |                      |
| GITEA_PROTOCOL             |             | https                |
| GITEA_DOMAIN               |             | git.company.com      |
|                            |             |                      |
| GITEA_SMTP_HOST            |             | mail.company.com     |
| GITEA_SMTP_PORT            |             | 25                   |
| GITEA_SMTP_FROM            |             | gitea@company.com    |
| GITEA_SMTP_USER            |             |                      |
| GITEA_SMTP_PASS            |             |                      |
|                            |             |                      |
| GITEA_REGISTRATION_DISABLE |             | true                 |
| GITEA_RECAPTCHA_SECRET     |             | 12345678900987654321 |
| GITEA_RECAPTCHA_KEY        |             |                      |
|                            |             |                      |
| GITEA_INSTALL_LOCK         |             | true                 |
| GITEA_SECRET_KEY           |             | 12345678900987654321 |
| GITEA_JWT_SECRET           |             | 12345678900987654321 |
|                            |             |                      |
| GITEA_ROOT_EMAIL           |             | root@company.com     |
| GITEA_ROOT_PASSWORD        |             | Pa55w0rd             |

```bash
# generate postgresql.service
docker run --rm \
  -e NAME=gitea-postgresql \
  -e POSTGRESQL_DATABASE=gitea \
  -e POSTGRESQL_USERNAME=gitea \
  -e POSTGRESQL_PASSWORD=Pa55w0rd \
  madharjan/docker-postgresql:9.5 \
  postgresql-systemd-unit | \
  sudo tee /etc/systemd/system/gitea-postgresql.service

sudo systemctl enable gitea-postgresql
sudo systemctl start gitea-postgresql

# generate gitea.service
docker run --rm \
  -e PORT=80 \
  -e LINK_CONTAINERS=gitea-postgresql:postgresql \
  -e GITEA_INSTALL_LOCK=true \
  -e GITEA_SECRET_KEY=1234567890 \
  -e GITEA_JWT_SECRET=6Lfjq6YUAAAAAFwDmDtfHyHmL1234567890 \
  -e GITEA_ROOT_PASSWORD=Pa55w0rd \
  madharjan/docker-gitea:1.8.2 \
  gitea-systemd-unit | \
  sudo tee /etc/systemd/system/gitea.service

sudo systemctl enable gitea
sudo systemctl start gitea
```
