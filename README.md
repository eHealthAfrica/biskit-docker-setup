# BISKIT Data Portal Setup

* [Introduction](#introdcution)
* [Basic structure](#basicsetup)
  * [CKAN](#ckan)
  * [Postgres](#postgres)
  * [SOLR](#solr)
  * [DataPusher](#datapusher)
  * [Redis](#redis)
* [Envvars](#envvars)
* [Quick Start](#quickstart)

## Introduction

This repository contains set of Docker images and configuration files to run a BISKIT data portal
which is based on CKAN.

## Basic structure

Project orchestration is made via `docker-compose.yml` file where all of the required services for
the BISKIT portal are added.

### CKAN

The Docker images for CKAN are located in the `ckan/` folder respectively for the specific portal
folder. Each `Dockerfile`  contains basic setup for CKAN portal including required extensions. It
use base CKAN image built from [docker-ckan](https://github.com/eHealthAfrica/docker-ckan). This
folder can contain additional scripts for executing various commands depending of the included
extensions or if you want to modify some of the default CKAN scripts.

### Postgres

Specific `postgres` setup is located in the `postgres/` folder, where are the two shell scripts
required to create and enable the database. In the setup official PostgresSQL image is used.

### SOLR

For `solr`, provided are the default configuration files including the required `schema.xml` for
the specific CKAN version.  In the setup official SOLR image is used.

### DataPusher

Datapusher image is built from [docker-ckan-datapusher](https://github.com/eHealthAfrica/docker-ckan-datapusher).

### Redis

Official [Redis](https://hub.docker.com/_/redis) image based on Alpine Linux is used for `redis`
setup.

## Add new extensions

New extensions should be included in the `portal/ckan/Dockerfile`. Install extensions from the
official repository and include requirements file e.g:

```sh
RUN  pip install -e git+https://github.com/ckan/ckanext-googleanalytics.git#egg=ckanext-googleanalytics &&\
     pip install -r https://raw.githubusercontent.com/ckan/ckanext-googleanalytics/master/requirements.txt &&\
```

Then add extension in `ckan_plugins` e.g:

```sh
ENV CKAN__PLUGINS envvars s3filestore googleanalytics
```

## Envars

Environment variables are loaded from `.env` file. The base CKAN image included in the `ckan/Dockerfile`
loads [ckanext-envvars](https://github.com/okfn/ckanext-envvars) extension for reading the variables.

To setup the env vars rename `env.template` to `.env` and modify it depending on your own needs.
The Envvars extension checks for environmental variables conforming to an expected format and
updates the corresponding CKAN config settings with its value.

Follow the name formatting explained in the [official docs](https://github.com/okfn/ckanext-envvars#ckanext-envvars)
for adding new variables.

> **NOTE** Using default values in the template will **NOT** create working instance

## Quick start

> **Bash v4.x and above is required**

To set up a local development environment begin by running:

```sh
./scripts/setup.sh init
```

This creates a `.env` file using `env.template`. The `.env` file defines environment variables
required to run the setup. Review and update the `.env` file as necessary. Update the following
environment variables:

* `GITHUB_TOKEN`: Generate your GitHub token and input the value. Instructions are [here](
  https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line).
* Update value for `CKAN_SYSADMIN_NAME` & `CKAN_SYSADMIN_PASSWORD` to set the login credentials
  for the BISKIT Data Portal installation as a system administrator.

Afterwards run:

```sh
./scripts/setup.sh init
```

This time, all repositories for the setup will be cloned into the `src` folder.

To start the portal use:

```sh
docker-compose up --build
```

Open `http://localhost:5000` or `http://biskit:5000` in your browser. In order to use `http://biskit:5000` add

```text
127.0.0.1    biskit
```

to your `/etc/hosts` file.

To stop the portal use:

```sh
docker-compose down
```

Make sure that the solr directory has the right ownership `sudo chown -R 8983:8983 solr` or simply
start the project by running `make up`.
