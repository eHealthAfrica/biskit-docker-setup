#!/bin/bash

echo "[extra_scripts.sh] Start supervisor"
supervisord -c /etc/supervisor/supervisord.conf

echo "[extra_scripts.sh] Clear index and rebuild index with all datasets"
paster --plugin=ckan search-index rebuild -c /srv/app/production.ini
