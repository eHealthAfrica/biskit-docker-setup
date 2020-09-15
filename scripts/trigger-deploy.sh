#!/usr/bin/env bash
set -Eeuo pipefail

# notify Google Cloud Storage the new image
export GOOGLE_APPLICATION_CREDENTIALS="gcp-key-prod.json"
export RELEASE_BUCKET="eha-software-releases";

if [ "$TRAVIS_BRANCH" == "develop" ]; then
    GCS_PROJECTS="biskit-dataportal-dev"
fi

push-app-version --version $TRAVIS_COMMIT --project $GCS_PROJECTS
