#!/bin/bash
DEFAULT_REG_NAME="kind-registry"
DEFAULT_REG_PORT="5003"

REG_NAME=$1
REG_PORT=$2

if [ -z "$REG_NAME" ]; then
	REG_NAME=$DEFAULT_REG_NAME
fi

if [ -z "$REG_PORT" ]; then
	REG_PORT=$DEFAULT_REG_PORT
fi

# Deploy Kind Cluster, Ingress Nginx, Redis and the Node application
pushd terraform-kind
terraform apply -destroy --var-file vars.tfvars
popd

echo "Stop and remove kind registry"
docker container stop ${REG_NAME} && docker container rm -v ${REG_NAME}



