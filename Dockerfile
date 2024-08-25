FROM openjdk:11-jre-slim

LABEL maintainer="Yuichiro Sugiura <yucihiro@activewave.com>" \
      version="1.1.0" \
      description="Custom Elasticsearch and Nginx setup with Kuromoji plugin" \
      org.opencontainers.image.source="https://github.com/ysugiura/elasticsearch" \
      org.opencontainers.image.version="1.1.0" \
      org.opencontainers.image.licenses="Apache-2.0"

# Create a non-root user and group
RUN groupadd -r elasticsearch && useradd -r -g elasticsearch elasticsearch

# Install dependencies and Elasticsearch
RUN apt-get update && \
    apt-get install -y curl gnupg2 nginx supervisor apache2-utils && \
    curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list && \
    apt-get update && \
    apt-get install -y elasticsearch=7.10.2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install the Kuromoji plugin
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-kuromoji

# Change ownership of Elasticsearch directories
RUN chown -R elasticsearch:elasticsearch /usr/share/elasticsearch /var/lib/elasticsearch /var/log/elasticsearch

# Set environment variables for Elasticsearch
ENV ELASTICSEARCH_USER=**None**
ENV ELASTICSEARCH_PASS=**None**

# Copy configuration files
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY run.sh /run.sh
COPY nginx_default /etc/nginx/sites-enabled/default

# Set up Nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN chmod +x /run.sh

# Expose port for Elasticsearch
EXPOSE 9200

# Switch to non-root user
USER elasticsearch

# Start the container
CMD ["/run.sh"]
