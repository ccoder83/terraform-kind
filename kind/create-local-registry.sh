#!/bin/sh
# create registry container unless it already exists
DEFAULT_REG_NAME="kind-registry"
DEFAULT_REG_PORT="5001"

REG_NAME=$1
REG_PORT=$2

if [ -z "$REG_NAME" ]; then
	REG_NAME=$DEFAULT_REG_NAME
fi

if [ -z "$REG_PORT" ]; then
	REG_PORT=$DEFAULT_REG_PORT
fi

if [ "$(docker inspect -f '{{.State.Running}}' "${REG_NAME}" 2>/dev/null || true)" != 'true' ]; then
  docker run \
    -d --restart=always -p "127.0.0.1:${REG_PORT}:5000" --name "${REG_NAME}" \
    registry:2
fi
