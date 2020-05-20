FROM solr:6.6.5

USER root

COPY mycores /opt/solr/server/solr/mycores

RUN chown -R solr:solr /opt/solr/server/solr/mycores

USER solr
