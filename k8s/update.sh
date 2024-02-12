#!/bin/bash

MY_DIR="$(dirname "$(readlink -f "$0")")"

helm upgrade mongo --set auth.enabled=false bitnami/mongodb
helm upgrade kafka bitnami/kafka

kubectl apply -f $MY_DIR/
