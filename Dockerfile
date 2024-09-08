FROM docker.elastic.co/elasticsearch/elasticsearch:7.17.23

# Switch to root user temporarily to install plugins and adjust permissions
USER root

# Install plugins
RUN bin/elasticsearch-plugin install analysis-icu \
    && bin/elasticsearch-plugin install analysis-kuromoji

# Set the correct ownership for the data directory
RUN mkdir -p /usr/share/elasticsearch/data \
    && chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/data

# Switch back to the elasticsearch user to avoid ownership issues
USER elasticsearch

# Set environment variables
ENV discovery.type=single-node

# Expose the default Elasticsearch port
EXPOSE 9200

# Start Elasticsearch
CMD ["bin/elasticsearch"]