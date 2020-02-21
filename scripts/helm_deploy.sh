#!/bin/bash

set -e

SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")

export HELM_NO_PREPARE="${HELM_NO_PREPARE:-0}"
if [[ "$1" == "-f" ]]; then HELM_NO_PREPARE=1; shift; fi

"${SCRIPTS_DIR}/helm_prepare.sh"

helm lint
helm upgrade \
  'experiment' . \
  --install \
  --namespace default
  -f values.experiment.yaml \
  -f values.custom.yaml

helm upgrade \
  'cert-manager' . \
  --install \
  --namespace cert-manager
  -f values.cert-manager.yaml \
  -f values.custom.yaml
