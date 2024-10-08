FROM docker.elastic.co/elasticsearch/elasticsearch:7.17.23

# Install plugins as the elasticsearch user (default user)
RUN bin/elasticsearch-plugin install analysis-icu \
    && bin/elasticsearch-plugin install analysis-kuromoji

# Set environment variables
ENV discovery.type=single-node

# Expose the default Elasticsearch port
EXPOSE 9200

# Start Elasticsearch
CMD ["bin/elasticsearch"]