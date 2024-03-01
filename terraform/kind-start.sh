#!/bin/bash

# Exit immediately if a command returns an error code
set -e

MY_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
K8S_DIR=$(builtin cd $MY_DIR/../k8s; pwd)

# Always run from the location of this script
cd $MY_DIR

# Use optional argument as the namespace for the T2-Project
if [ $# -gt 0 ]; then
    T2_NAMESPACE=$1
else
    T2_NAMESPACE="default"
fi

# Setup kind environment
terraform -chdir=./environments/kind/ init -upgrade
terraform -chdir=./environments/kind/ apply -target="module.kind" -auto-approve
terraform -chdir=./environments/kind/ apply -auto-approve

# Install T2-Project
source $K8S_DIR/start.sh $T2_NAMESPACE
