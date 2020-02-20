#!/bin/bash

set -e

SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")

"${SCRIPTS_DIR}/helm_dep_update.sh"

helm lint
helm upgrade 'experiment' . --install --namespace default
