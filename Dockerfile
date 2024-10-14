FROM docker.elastic.co/elasticsearch/elasticsearch:7.17.23

# Install plugins as the elasticsearch user
RUN bin/elasticsearch-plugin install analysis-icu \
    && bin/elasticsearch-plugin install analysis-kuromoji

# Expose the default Elasticsearch port
EXPOSE 9200

# Add a healthcheck to monitor Elasticsearch status
HEALTHCHECK --interval=30s --timeout=10s --retries=5 CMD curl -f http://localhost:9200/_cluster/health || exit 1

# Start Elasticsearch with the discovery.type setting as a command-line argument
CMD ["bin/elasticsearch", "-Ediscovery.type=single-node"]