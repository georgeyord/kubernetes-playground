#!/bin/bash

set -e

SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")

export HELM_NO_PREPARE="${HELM_NO_PREPARE:-0}"
if [[ "$1" == "-f" ]]; then HELM_NO_PREPARE=1; shift; fi

"${SCRIPTS_DIR}/helm_prepare.sh"

echo >&2 -e "\n########## Release deploy - experiment ########## \n"

helm lint . \
  -f values.experiment.yaml \
  -f values.custom.yaml

echo >&2 -e "\n########## Release deploy - cert-manager ########## \n"

helm lint . \
  -f values.cert-manager.yaml \
  -f values.custom.yaml
