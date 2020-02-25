#!/bin/bash

set -e

SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")

export HELM_NO_PREPARE="${HELM_NO_PREPARE:-0}"
if [[ "$1" == "-f" ]]; then HELM_NO_PREPARE=1; shift; fi

"${SCRIPTS_DIR}/helm_prepare.sh"

diff() {
  local RELEASE="$1"
  local NAMESPACE="${2:-$RELEASE}"

  echo >&2 -e "\n########## Diff - Release: ${RELEASE} ########## \n"

  helm diff upgrade \
    "${RELEASE}" \
    . \
    --namespace "${NAMESPACE}" \
    -f "values.${RELEASE}.yaml" \
    -f values.custom.yaml \
    --allow-unreleased
}

diff 'experiment' 'default'
diff 'cert-manager'
