#!/bin/sh
# upgrade-infinitefutured - example make call to upgrade infinitefutured on a set of nodes in AWS
# WARNING: Run it from the current directory - it uses relative paths to ship the binary and the genesis.json,config.toml files

if [ $# -ne 1 ]; then
  echo "Usage: ./upgrade-infinitefutured.sh <clustername>"
  exit 1
fi
set -eux

export CLUSTER_NAME=$1

make upgrade-infinitefutured

