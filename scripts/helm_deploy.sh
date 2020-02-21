#!/bin/bash

set -e

SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")

export HELM_DEP_IGNORE="${HELM_DEP_IGNORE:-0}"
if [[ "$1" == "-f" ]]; then HELM_DEP_IGNORE=1; shift; fi

"${SCRIPTS_DIR}/helm_prepare.sh"

helm lint
helm upgrade 'experiment' . --install --namespace default
