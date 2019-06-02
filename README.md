# docker-gitea

[![Build Status](https://travis-ci.com/madharjan/docker-gitea.svg?branch=master)](https://travis-ci.com/madharjan/docker-gitea)
[![Layers](https://images.microbadger.com/badges/image/madharjan/docker-gitea.svg)](http://microbadger.com/images/madharjan/docker-gitea)

Docker container for Gitea Server based on [madharjan/docker-base](https://github.com/madharjan/docker-base/)

## Features

* Environment variables to configure Gitea
* Bats [bats-core/bats-core](https://github.com/bats-core/bats-core) based test cases

## Template Server 1.0 (docker-gitea)

### Environment

| Variable                   | Default         | Example        |
| -------------------------- | --------------- | -------------- |
| DISABLE_GITEA              | 0               | 1 (to disable) |
| GITEA_PROTOCOL             | http            | https          |
| GITEA_DOMAIN               | localhost       |                |
|                            |                 |                |
| GITEA_SMTP_HOST            | localhost       |                |
| GITEA_SMTP_PORT            | 25              |                |
| GITEA_SMTP_FROM            | gitea@localhost |                |
| GITEA_SMTP_USER            | pass            |                |
| GITEA_SMTP_PASS            | pass            |                |
|                            |                 |                |
| GITEA_REGISTRATION_DISABLE | false           |                |
| GITEA_RECAPTCHA_SECRET     |                 |                |
| GITEA_RECAPTCHA_KEY        |                 |                |
|                            |                 |                |
| GITEA_INSTALL_LOCK         | false           |                |
| GITEA_SECRET_KEY           |                 |                |
| GITEA_JWT_SECRET           |                 |                |
|                            |                 |                |
| GITEA_ROOT_EMAIL           | root@localhost  |                |
| GITEA_ROOT_PASSWORD        | Git3aPa55       |                |

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
sudo mkdir -p /opt/docker/gitea/etc/
sudo mkdir -p /opt/docker/gitea/lib/
sudo mkdir -p /opt/docker/gitea/log/

# stop & remove previous instances
docker stop gitea
docker rm gitea

# run container
docker run -d \
  -e GITEA_SMTP_HOST=172.18.0.1 \
  -e GITEA_INSTALL_LOCK=true \
  -e GITEA_SECRET_KEY=1234567890 \
  -e GITEA_JWT_SECRET=6Lfjq6YUAAAAAFwDmDtfHyHmL1234567890 \
  -e GITEA_ROOT_PASSWORD=Pa55w0rd \
  -p 8080:3000 \
  -v /opt/docker/gitea/etc:/etc/gitea \
  -v /opt/docker/gitea/lib:/var/lib/gitea \
  -v /opt/docker/gitea/log:/var/log/gitea \
  --name gitea \
  madharjan/docker-gitea:1.0
```

## Systemd Unit File

**Note**: update environment variables below as necessary

```txt
[Unit]
Description=Template Server

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
  -e GITEA_SMTP_HOST=172.18.0.1 \
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

| Variable                   | Default         | Example   |
| -------------------------- | --------------- | --------- |
| PORT                       |                 | 8080      |
| VOLUME_HOME                | /opt/docker     | /opt/data |
| NAME                       | gitea           |           |
|                            |                 |           |
| GITEA_PROTOCOL             | http            | https     |
| GITEA_DOMAIN               | localhost       |           |
|                            |                 |           |
| GITEA_SMTP_HOST            | localhost       |           |
| GITEA_SMTP_PORT            | 25              |           |
| GITEA_SMTP_FROM            | gitea@localhost |           |
| GITEA_SMTP_USER            | pass            |           |
| GITEA_SMTP_PASS            | pass            |           |
|                            |                 |           |
| GITEA_REGISTRATION_DISABLE | false           |           |
| GITEA_RECAPTCHA_SECRET     |                 |           |
| GITEA_RECAPTCHA_KEY        |                 |           |
|                            |                 |           |
| GITEA_INSTALL_LOCK         | false           |           |
| GITEA_SECRET_KEY           |                 |           |
| GITEA_JWT_SECRET           |                 |           |
|                            |                 |           |
| GITEA_ROOT_EMAIL           | root@localhost  |           |
| GITEA_ROOT_PASSWORD        | Git3aPa55       |           |

```bash
# generate gitea.service
docker run --rm \
  -e PORT=80
  -e GITEA_SMTP_HOST=172.18.0.1 \
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
