#!/usr/bin/env bash
set -Eeuo pipefail

LINE=`printf -v row "%${COLUMNS:-$(tput cols)}s"; echo ${row// /=}`

function echo_msg {
  if [ -z "$1" ]; then
    echo -e "\033[90m$LINE\033[0m"
  else
    msg=" $1 "
    color=${2:-\\033[39m}
    echo -e "\033[90m${LINE:${#msg}}\033[0m$color$msg\033[0m"
  fi
}

function purge_env {
  rm -rf src/core
  rm -rf src/extensions

  if [[ $# -gt 1 ]]; then
    shift
    if [[ $1 == "-a" || $1 == "--all" ]]; then
      echo "Purging volumes also ..."
      rm -rf ./.data
    fi
  fi
}

function fetch_codes {
  local CKAN_VERSION=ckan-2.8.3
  local DATAPUSHER_VERSION=0.0.14

  local CKAN_GITHUB_BASEURL=git@github.com:ckan
  local CKAN_GITHUB_REPO_NAMES=( "ckan" "datapusher" )

  local CORE_BASEDIR=./src/core
  local CKANEXT_BASEDIR=./src/extensions
  local EHA_GITHUB_BASEURL=git@github.com:eHealthAfrica
  local EHA_GITHUB_REPO_NAMES=( "ckanext-biskit" )

  # clone ckan repos locally
  if [[ ! -d ${CORE_BASEDIR} ]]; then
    echo_msg "Creating core folder ..."
    mkdir -p ${CORE_BASEDIR}
  fi

  for repo in "${CKAN_GITHUB_REPO_NAMES[@]}"
  do
    if [[ ! -d ${CORE_BASEDIR}/${repo} ]]; then
      if [[ "${repo}" == "ckan" ]]; then
        git clone --branch ${CKAN_VERSION} --depth 1 ${CKAN_GITHUB_BASEURL}/${repo}.git ${CORE_BASEDIR}/${repo}
      else
        git clone --branch ${DATAPUSHER_VERSION} --depth 1 ${CKAN_GITHUB_BASEURL}/${repo}.git ${CORE_BASEDIR}/${repo}
      fi
    else
      echo ">> repo exists; ${repo}"
    fi
  done

  # clone eoc repos locally
  if [[ ! -d ${CKANEXT_BASEDIR} ]]; then
    echo_msg "Creating extensions folder ..."
    mkdir -p ${CKANEXT_BASEDIR}
  fi

  for repo in "${EHA_GITHUB_REPO_NAMES[@]}"
  do
    if [[ ! -d ${CKANEXT_BASEDIR}/${repo} ]]; then
      git clone ${EHA_GITHUB_BASEURL}/${repo}.git ${CKANEXT_BASEDIR}/${repo}
    else
      echo ">> repo exists; ${repo}"
    fi
  done
}

if [[ $# -gt 0 ]]; then
  case "$1" in
    purge )
      echo_msg "Purging the local development env setup ..."
      purge_env $*
    ;;

    init )
      if [ ! -e .env ]; then
        ./src/bin/gen_env_file.sh
        echo -e "\033[93mUpdate created .env file then re-issue 'make init' again\033[0m"
      else
        echo_msg "fetching codes ..."
        fetch_codes
        echo_msg "done!"
      fi
    ;;
  esac
fi
