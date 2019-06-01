#!/bin/bash

set -x

docker stop gitea 2> /dev/null
docker rm gitea 2> /dev/null

docker stop gitea-postgresql 2> /dev/null
docker rm gitea-postgresql 2> /dev/null

sudo rm -rf /opt/docker/gitea
