#!/bin/bash

set -ex

envsubst < .env.template > .env

# build Docker image
docker-compose  build --build-arg GITHUB_TOKEN=${GITHUB_TOKEN} ckan solr
