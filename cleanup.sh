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

# Destroy Kind Cluster, Ingress Nginx, Redis and the Node application
pushd terraform-kind
terraform apply -destroy --var-file vars.tfvars
popd

# Remove Kind Registry
echo "Stop and remove kind registry: ${REG_NAME}"
echo "Are you sure?"
read INPUT
if [ $INPUT = 'yes' ]; then
  docker container stop ${REG_NAME} && docker container rm -v ${REG_NAME}	
  echo "kind registry has been deleted"
else
  echo "No action taken on kind registry: ${REG_NAME}"
fi



