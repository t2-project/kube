#!/bin/bash

# Exit immediately if a command returns an error code
set -e

MY_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
K8S_DIR=$(builtin cd $MY_DIR/../k8s; pwd)

# Always run from the location of this script
cd $MY_DIR

# Setup kind environment
# kind cluster has to be created first explicitly (using `-target`), because of how Terraform handels providers.
# See for more information:
# - https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources
# - https://stackoverflow.com/a/69996957/9556565
terraform -chdir=./environments/kind/ init -upgrade
terraform -chdir=./environments/kind/ apply -target="module.kind" -auto-approve
terraform -chdir=./environments/kind/ apply -auto-approve

# Install T2-Project
source $K8S_DIR/start.sh