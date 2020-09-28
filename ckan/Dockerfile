# CKAN
FROM ehealthafrica/ckan:2.8.4.r1 as base

USER root
RUN apt-get -q -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -q -y upgrade \
    && apt-get -q -y install \
       libgeos-dev \
       python-shapely \
       gdal-bin \
       cron

ARG GITHUB_TOKEN

# avoid installing supervisor via apt-get as it needs to be run as ckan user
RUN pip install --upgrade pip &&\
    pip install supervisor future &&\
    pip install -e git+https://github.com/eHealthAfrica/ckanext-hierarchy.git#egg=ckanext-hierarchy &&\
    pip install -e git+https://github.com/ckan/ckanext-googleanalytics.git#egg=ckanext-googleanalytics &&\
    pip install -r https://raw.githubusercontent.com/ckan/ckanext-googleanalytics/master/requirements.txt &&\
    pip install -e git+https://github.com/ckan/ckanext-geoview.git#egg=ckanext-geoview &&\
    pip install -r https://raw.githubusercontent.com/ckan/ckanext-geoview/master/pip-requirements.txt &&\
    pip install -e git+https://${GITHUB_TOKEN}@github.com/eHealthAfrica/ckanext-biskit.git#egg=ckanext-biskit &&\
    pip install -r https://${GITHUB_TOKEN}@raw.githubusercontent.com/eHealthAfrica/ckanext-biskit/master/requirements.txt


ENV CKAN__PLUGINS s3filestore biskit googleanalytics datastore datapusher stats image_view text_view \
                  recline_view webpage_view resource_proxy geojson_view hierarchy_display hierarchy_form \
                  envvars

RUN mkdir -p /var/lib/ckan && chown -R ckan:ckan /var/lib/ckan/
VOLUME /var/lib/ckan/

RUN paster --plugin=ckan config-tool ${APP_DIR}/production.ini "ckan.plugins = ${CKAN__PLUGINS}"

ENV CKAN_SITE_URL ${CKAN_SITE_URL}
RUN paster --plugin=ckan config-tool ${APP_DIR}/production.ini "ckan.site_url = ${CKAN_SITE_URL}"

USER ckan

CMD ["/srv/app/start_ckan.sh"]
