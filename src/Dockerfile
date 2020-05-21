# CKAN
FROM ehealthafrica/ckan:2.8.4-alpine as base
ENV CKAN_HOME /srv/app/src/ckan/ckan
ENV GRID_HOME /srv/app/src/ckanext-grid

USER root
RUN apk add --update-cache \
            # lib geos are avaiable through alpine edge repo
            --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
            --allow-untrusted \
            geos \
            geos-dev

# TODO: Remove unnecesary libs
RUN apk add --no-cache \
            bash \
            g++ \
            gcc \
            libffi-dev \
            libstdc++ \
            libxml2 \
            libxml2-dev \
            libxslt \
            libxslt-dev \
            make \
            musl-dev \
            pcre \
            python2-dev \
            openssl-dev \
            py-lxml \
            jpeg-dev \
            zlib-dev \
            supervisor

ARG GITHUB_TOKEN

RUN pip install --upgrade pip &&\
    pip install -e git+https://github.com/ckan/ckanext-googleanalytics.git#egg=ckanext-googleanalytics &&\
    pip install -r https://raw.githubusercontent.com/ckan/ckanext-googleanalytics/master/requirements.txt &&\
    pip install -e git+https://github.com/ckan/ckanext-geoview.git#egg=ckanext-geoview &&\
    pip install -r https://raw.githubusercontent.com/ckan/ckanext-geoview/master/pip-requirements.txt

# install what follows from repos cloned locally
ENV EXT_PATH ${APP_DIR}/src/extensions
COPY src/extensions/ ${EXT_PATH}/
RUN pip install -e ${EXT_PATH}/ckanext-biskit &&\
    pip install -r ${EXT_PATH}/ckanext-biskit/requirements.txt


ENV CKAN__PLUGINS envvars biskit googleanalytics datastore datapusher stats image_view text_view \
                  recline_view webpage_view resource_proxy geojson_view

RUN mkdir -p /var/lib/ckan && chown -R ckan:ckan /var/lib/ckan/
VOLUME /var/lib/ckan/

RUN paster --plugin=ckan config-tool ${APP_DIR}/production.ini "ckan.plugins = ${CKAN__PLUGINS}"

ENV CKAN_SITE_URL ${CKAN_SITE_URL}
RUN paster --plugin=ckan config-tool ${APP_DIR}/production.ini "ckan.site_url = ${CKAN_SITE_URL}"

USER ckan

CMD ["/srv/app/start_ckan.sh"]
