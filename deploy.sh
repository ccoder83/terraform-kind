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

# Create tfvars file declaring the kind registry port
cat <<EOF > terraform-kind/vars.tfvars
kind_registry_port="${REG_PORT}"
kind_registry_name="${REG_NAME}"
EOF

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
terraform apply --var-file vars.tfvars -auto-approve
popd

# curl the deployed application
sleep 5 #give nginx time to register the backend pools
curl localhost