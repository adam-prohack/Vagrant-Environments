#!/bin/bash -x

# Configuration
docker_compose_version = $1

mkdir /opt/
mkdir /opt/bin
curl -L https://github.com/docker/compose/releases/download/$docker_compose_version/docker-compose-Linux-x86_64 > /opt/bin/docker-compose
chmod +x /opt/bin/docker-compose