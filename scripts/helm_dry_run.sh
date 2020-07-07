#!/bin/bash

set -e

SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")

export HELM_NO_PREPARE="${HELM_NO_PREPARE:-0}"
if [[ "$1" == "-f" ]]; then HELM_NO_PREPARE=1; shift; fi

if [ -z "$1" ]; then echo >&2 "Release is required as the first argument"; exit 1; fi
if [ -z "$2" ]; then echo >&2 "Namespace is required as the second argument"; exit 1; fi

type schelm >/dev/null 2>&1 || { echo >&2 -e "The 'schelm' command is required for this script to run.\n\n --> Installation: https://github.com/databus23/schelm"; exit 1; }

"${SCRIPTS_DIR}/helm_prepare.sh"

RELEASE="$1"
NAMESPACE="${2}"

echo >&2 -e "\n########## Dry run - Release: ${RELEASE} ########## \n"

mkdir -p /tmp/schelm

helm upgrade \
  "${RELEASE}" \
  . \
  --install \
  --dry-run \
  --namespace "${NAMESPACE}" \
  -f "values.${RELEASE}.yaml" \
  -f values.custom.yaml
# | schelm -f /tmp/schelm/${RELEASE}

echo >&2 -e "You can find the hydrated Kubernetes configuration files here: /tmp/schelm/${RELEASE}"