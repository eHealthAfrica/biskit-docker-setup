#!/bin/bash

set -ex

envsubst < env.template > .env

# build Docker image
docker-compose -f docker-compose.yml \
               -f docker-compose.prod.yml \
               build --build-arg GITHUB_TOKEN=${GITHUB_TOKEN} \
               ckan solr
