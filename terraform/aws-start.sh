#!/bin/bash

# Exit immediately if a command returns an error code
set -e

MY_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
K8S_DIR=$(builtin cd $MY_DIR/../k8s; pwd)

# Always run from the location of this script
cd $MY_DIR

# Ensure that you are logged-in
if ! aws sts get-caller-identity &> /dev/null
then
  echo "You have to login first!"
  exit 1
fi

# Setup AWS environment
# EKS cluster has to be created first explicitly (using `-target`), because of how Terraform handels providers.
# See for more information:
# - https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources
# - https://stackoverflow.com/a/69996957/9556565
terraform -chdir=./environments/aws/ init -upgrade
terraform -chdir=./environments/aws/ apply -target="module.eks" -auto-approve
terraform -chdir=./environments/aws/ apply -auto-approve

# Install T2-Project
source $K8S_DIR/start.sh

# Expose Grafana and wait for the hostname
kubectl apply -f $K8S_DIR/load-balancer/aws-loadbalancer-grafana.yaml
until kubectl get service/prometheus-grafana-nlb -n monitoring --output=jsonpath='{.status.loadBalancer}' | grep "ingress"; do : ; done
GRAFANA_HOSTNAME=$(kubectl get service/prometheus-grafana-nlb -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo -e "\nGrafana URL: http://${GRAFANA_HOSTNAME}"