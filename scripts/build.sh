#!/bin/bash

set -ex

envsubst < .env.template > .env

# build Docker image
docker-compose build ckan solr
