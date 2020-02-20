#!/bin/bash

set -e

"${SCRIPTS_DIR}/helm_dep_update.sh"

helm diff upgrade 'experiment' . -f values.yaml --context 3
