#!/bin/bash

set -e

helm dependencies update
helm upgrade 'experiment' . --install --namespace default
