#!/bin/bash
set -e

IMAGE_REPO="eu.gcr.io"
APP="biskit-dataportal"

if [ "$TRAVIS_BRANCH" == "develop" ]; then
  ENV="dev"
  export CKAN_SITE_URL="https://data-dev.biskit.org"
  PROJECT="development-000000"
  docker login -u _json_key -p "$(cat gcp-key.json)" https://eu.gcr.io
fi

# tag images
docker tag biskit-ckan "$IMAGE_REPO/$PROJECT/$APP/ckan:$ENV"
docker tag biskit-ckan "$IMAGE_REPO/$PROJECT/$APP/ckan:$TRAVIS_COMMIT"
docker tag ckan-solr "$IMAGE_REPO/$PROJECT/$APP/solr:$ENV"
docker tag ckan-solr "$IMAGE_REPO/$PROJECT/$APP/solr:$TRAVIS_COMMIT"

# push Docker image
docker push "$IMAGE_REPO/$PROJECT/$APP/solr:$ENV"
docker push "$IMAGE_REPO/$PROJECT/$APP/solr:$TRAVIS_COMMIT"
docker push "$IMAGE_REPO/$PROJECT/$APP/ckan:$ENV"
docker push "$IMAGE_REPO/$PROJECT/$APP/ckan:$TRAVIS_COMMIT"

