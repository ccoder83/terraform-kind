#!/bin/bash
REG_NAME="kind-registry"
REG_PORT="5003"

# Create Kind local docker registry
sh ./kind/create-local-registry.sh $REG_NAME $REG_PORT

# Containerise application and push to local registry
pushd node-app
docker build -t "localhost:${REG_PORT}/nodeapp:1.0" . || { echo 'Error: Docker Build Failed.' ; exit 1; }
docker push "localhost:$REG_PORT/nodeapp:1.0" || { echo 'Error: Docker Push Failed.' ; exit 1; }
popd

# Connect docker to kind registry
# connect the registry to the cluster network if not already connected
if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${REG_NAME}")" = 'null' ]; then
  docker network connect "kind" "${REG_NAME}"
fi

# Deploy Kind Cluster, Ingress Nginx, Redis and the Node application
pushd terraform-kind
terraform init
terraform apply -auto-approve
popd

# curl the deployed application
curl localhost