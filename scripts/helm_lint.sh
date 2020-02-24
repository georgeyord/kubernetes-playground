#!/bin/bash

set -e

SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")

export HELM_NO_PREPARE="${HELM_NO_PREPARE:-0}"
if [[ "$1" == "-f" ]]; then HELM_NO_PREPARE=1; shift; fi

"${SCRIPTS_DIR}/helm_prepare.sh"

lint() {
  local RELEASE="$1"
  echo >&2 -e "\n########## Release lint - ${RELEASE} ########## \n"

  helm lint . \
    -f "values.${RELEASE}.yaml" \
    -f values.custom.yaml
}

lint 'experiment'
lint 'cert-manager'
