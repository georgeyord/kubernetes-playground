#!/bin/bash

set -e

SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")

export HELM_NO_PREPARE="${HELM_NO_PREPARE:-0}"
if [[ "$1" == "-f" ]]; then HELM_NO_PREPARE=1; shift; fi

"${SCRIPTS_DIR}/helm_prepare.sh"

echo >&2 -e "\n########## Release diff - experiment ########## \n"

helm diff upgrade \
  'experiment' . \
  -f values.yaml \
  -f values.experiment.yaml \
  -f values.custom.yaml \
  --allow-unreleased \
  --context 3

echo >&2 -e "\n########## Release diff - cert-manager ########## \n"

helm diff upgrade \
  'cert-manager' . \
  -f values.yaml \
  -f values.cert-manager.yaml \
  -f values.custom.yaml \
  --allow-unreleased \
  --context 3
