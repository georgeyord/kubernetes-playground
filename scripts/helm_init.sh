#!/bin/bash

set -e

helm plugin ls | \
  grep diff | \
  helm plugin install https://github.com/databus23/helm-diff --version master

