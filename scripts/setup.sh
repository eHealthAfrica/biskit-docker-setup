#!/usr/bin/env bash
set -Eeuo pipefail

SRC_DIR="./src"
LINE=`printf -v row "%${COLUMNS:-$(tput cols)}s"; echo ${row// /=}`

declare -A REPO1=([name]=ckan [app]=core [branch]=ckan-2.8.4 [usr]=ckan)
declare -A REPO2=([name]=datapusher [app]=core [branch]=0.0.14 [usr]=ckan)
declare -A REPO3=([name]=ckanext-biskit [app]=biskit [branch]=master [usr]=ehealthafrica)
REPOS=('REPO1' 'REPO2' 'REPO3')
APP="biskit"

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
  local target=$1

  for repo in ${REPOS[@]}; do
    app=$(eval echo "\${${repo}[app]}")
    if [[ "${target}" == "${app}" ]]; then
      branch=$(eval echo "\${${repo}[branch]}")
      name=$(eval echo "\${${repo}[name]}")
      usr=$(eval echo "\${${repo}[usr]}")

      repo_url="git@github.com:${usr}/${name}.git"

      if [[ ! -d ${SRC_DIR}/${name} ]]; then
        echo_msg "fetching ${name} @ ${branch} ..."
        if [[ "${app}" == "core" ]]; then
          git clone --depth 1 --branch ${branch} ${repo_url} ${SRC_DIR}/${name}
        else
          git clone --branch ${branch} ${repo_url} ${SRC_DIR}/${name}
        fi
      else
        echo_msg "repo exists; ${name}"
      fi
    fi
  done
}

function gen_random_string {
  openssl rand -hex 16 | tr -d "\n"
}

function gen_env_file {
  export HOSTNAME=biskit
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
  envsubst < env.template > .env
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
      clone_repos ${APP}

      if [[ "${2:-''}" == "--all" ]]; then
        clone_repos "core"
      fi
      echo_msg "done!"
    fi
  ;;

  * )
    show_help
  ;;
esac
