#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

helm3 dependencies update

helm3 lint

helm3 upgrade 'experiment' . --install --namespace default
