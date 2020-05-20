# README

This directory contains scripts and other necessary files to setup and support a local
docker-based development environment. The CKAN extensions in development are cloned
into the `src/extensions` directory by the setup script and excluded from git commits.

## Setup Environment

To setup a local docker-based development environment, execute the commands as outlined
below. This setup is geared towards easing extensions development.

```bash
# clone necessary ckan extensions into `src/extension`
$ make init

# run dev setup
$ make up
```
