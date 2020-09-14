#!/usr/bin/env bash
set -Eeuo pipefail

SRC_DIR="./src"
LINE=`printf -v row "%${COLUMNS:-$(tput cols)}s"; echo ${row// /=}`

function check_openssl {
  which openssl > /dev/null
}

function echo_msg {
  if [ -z "$1" ]; then
    echo -e "\033[90m$LINE\033[0m"
  else
    msg=" $1 "
    color=${2:-\\033[39m}
    echo -e "\033[90m${LINE:${#msg}}\033[0m$color$msg\033[0m"
  fi
}

function final_warning {
  HOSTNAME="eoc"
  lin_path="/etc/hosts"
  win_path="C:\Windows\System32\Drivers\etc\hosts"

  echo ""
  echo "Add to your [$lin_path] or [$win_path] file the following line:"
  echo ""
  echo -e "\033[93m127.0.0.1  \033[1m${HOSTNAME}\033[0m"
  echo ""
}

function clone_repos {
  local fetch_all=${1:-"no"}
  if [[ "${fetch_all}" == "--all" ]]; then
    fetch_all="yes"
  fi

  local CKAN_VERSION=ckan-2.8.4
  local DATAPUSHER_VERSION=0.0.14

  local CKAN_GITHUB_BASEURL=git@github.com:ckan
  local CKAN_GITHUB_REPO_NAMES=( "ckan" "datapusher" )

  local EHA_GITHUB_BASEURL=git@github.com:eHealthAfrica
  local EHA_GITHUB_REPO_NAMES=( "ckanext-biskit" )

  if [[ ! -d ${SRC_DIR} ]]; then
    echo_msg "Creating 'src' folder ..."
    mkdir -p ${SRC_DIR}
  fi

  # clone ckan repos locally
  for repo in "${CKAN_GITHUB_REPO_NAMES[@]}"
  do
    if [[ "${fetch_all}" == "yes" ]]; then
      if [[ ! -d ${SRC_DIR}/${repo} ]]; then
        echo_msg "fetching repository for ${repo} ..."
        if [[ "${repo}" == "ckan" ]]; then
          git clone --branch ${CKAN_VERSION} --depth 1 ${CKAN_GITHUB_BASEURL}/${repo}.git ${SRC_DIR}/${repo}
        else
          git clone --branch ${DATAPUSHER_VERSION} --depth 1 ${CKAN_GITHUB_BASEURL}/${repo}.git ${SRC_DIR}/${repo}
        fi
      else
        echo ">> repo exists; ${repo}"
      fi
    fi
  done

  # clone eoc repos locally
  for repo in "${EHA_GITHUB_REPO_NAMES[@]}"
  do
    if [[ ! -d ${SRC_DIR}/${repo} ]]; then
      echo_msg "fetching repository for ${repo} ..."
      git clone ${EHA_GITHUB_BASEURL}/${repo}.git ${SRC_DIR}/${repo}
    else
      echo ">> repo exists; ${repo}"
    fi
  done
}

function gen_random_string {
  openssl rand -hex 16 | tr -d "\n"
}

function gen_env_file {
  export DBNAME=ckan
  export DBUSER=ckan
  export DBPASS=$(gen_random_string)

  export DATASTORE_DBNAME=datastore
  export DATASTORE_RO_USER=datastore
  export DATASTORE_RW_USER=ckan

  export SYSADMIN_PASS=$(gen_random_string)
  export BEAKER_SESSION_SECRET=$(gen_random_string)

  if [[ -e ".env" ]]; then
    echo -e "\033[93;1m[.env]\033[0m file already exists!"
    echo "Remove it if you want to generate a new one."
    final_warning
    exit 0
  fi

  check_openssl
  RET=$?
  if [[ $RET -eq 1 ]]; then
    echo -e "\033[91mPlease install 'openssl'  https://www.openssl.org/\033[0m"
    exit 1
  fi

  set -Eeo pipefail
  envsubst < .env.template > .env
  echo -e "\033[92;1m[.env]\033[0m file generated!"
  final_warning
}

function purge_repos {
  rm -rf src/ckan src/datapusher
  rm -rf src/ckanext-*
}

function show_help {
  echo """
  COMMANDS
  ========
  help          : display this help message
  init [--all]  : sets up a local development environment when '--all' is used the CKAN
                  and datapusher repos are cloned in addition to the main repos
  purge         : deletes all repos clone into './src' if there are any
  """
}

case "${1:-''}" in
  purge )
    echo_msg "Purging the local development env setup ..."
    purge_repos
  ;;

  init )
    if [[ ! -e .env ]]; then
      gen_env_file
      echo -e "\033[93mUpdate created .env file then re-issue 'make init' again\033[0m"
    else
      echo_msg "fetching codes ..."
      clone_repos ${@:2}
      echo_msg "done!"
    fi
  ;;

  * )
    show_help
  ;;
esac
