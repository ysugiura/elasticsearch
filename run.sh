#!/bin/bash

set -e

# Ensure the htpasswd file is writable by the non-root user
HTPASSWD_FILE="/usr/share/elasticsearch/htpasswd"
touch $HTPASSWD_FILE
chown elasticsearch:elasticsearch $HTPASSWD_FILE

if [ "${ELASTICSEARCH_USER}" == "**None**" ] && [ "${ELASTICSEARCH_PASS}" == "**None**" ]; then
    echo "=> Starting Elasticsearch with no basic auth ..."
    echo "========================================================================"
    echo "You can now connect to this Elasticsearch Server using:"
    echo ""
    echo "    curl localhost:9200"
    echo ""
    echo "========================================================================"
    exec /usr/share/elasticsearch/bin/elasticsearch
else
    USER=${ELASTICSEARCH_USER:-admin}
    echo "=> Starting Elasticsearch with basic auth ..."
    echo ${ELASTICSEARCH_PASS} | htpasswd -i -c $HTPASSWD_FILE ${USER}
    echo "========================================================================"
    echo "You can now connect to this Elasticsearch Server using:"
    echo ""
    echo "    curl ${USER}:${ELASTICSEARCH_PASS}@localhost:9200"
    echo ""
    echo "========================================================================"
    exec /usr/share/elasticsearch/bin/elasticsearch
fi