#!/bin/bash

set -e

echo >&2 -e "\n\n########## Helm dependencies update ########## \n"
helm repo add stable https://kubernetes-charts.storage.googleapis.com

echo >&2 "Updating helm charts..." && sleep 0.2
helm dependencies update
