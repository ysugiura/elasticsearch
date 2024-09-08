FROM docker.elastic.co/elasticsearch/elasticsearch:8.5.0

USER root

# Install plugins
RUN bin/elasticsearch-plugin install analysis-icu \
    && bin/elasticsearch-plugin install analysis-kuromoji

# Ensure the data directory exists and set the correct ownership
RUN mkdir -p /usr/share/elasticsearch/data \
    && chown -R 1000:1000 /usr/share/elasticsearch/data

# Set environment variables
ENV discovery.type=single-node

# Expose the default Elasticsearch port
EXPOSE 9200

# Start Elasticsearch
CMD ["bin/elasticsearch"]