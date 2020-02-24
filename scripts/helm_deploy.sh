#!/bin/bash

set -e

SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")

export HELM_NO_PREPARE="${HELM_NO_PREPARE:-0}"
if [[ "$1" == "-f" ]]; then HELM_NO_PREPARE=1; shift; fi

"${SCRIPTS_DIR}/helm_prepare.sh"

"${SCRIPTS_DIR}/helm_lint.sh" -f

deploy() {
  local RELEASE="$1"
  local NAMESPACE="${2:-$RELEASE}"

  echo >&2 -e "\n########## Release deploy - ${RELEASE} ########## \n"

  helm upgrade \
    "${RELEASE}" \
    . \
    --install \
    --cleanup-on-fail \
    --namespace "${NAMESPACE}" \
    -f "values.${RELEASE}.yaml" \
    -f values.custom.yaml
}

deploy 'experiment' 'default'
deploy 'cert-manager'
