import pytest
import subprocess
import requests
import time

# Full path to docker executable
DOCKER_PATH = "/Applications/Docker.app/Contents/Resources/bin/docker"

# Fixture to start and stop Elasticsearch
@pytest.fixture(scope="module")
def elasticsearch():
    # Start Elasticsearch before tests
    subprocess.run([DOCKER_PATH, "compose", "up", "-d"], check=True)
    time.sleep(10)  # Initial sleep to give Elasticsearch time to start

    # Provide the test with Elasticsearch running
    yield

    # Stop Elasticsearch after tests
    subprocess.run([DOCKER_PATH, "compose", "down"], check=True)

# Check if Elasticsearch is running and healthy
def is_elasticsearch_healthy():
    try:
        response = requests.get("http://localhost:9200/_cluster/health")
        if response.status_code == 200:
            health_status = response.json().get("status")
            return health_status in ["green", "yellow"]
        return False
    except requests.exceptions.RequestException:
        return False

# Test if Elasticsearch is healthy (runs after the fixture has started Elasticsearch)
def test_elasticsearch_health(elasticsearch):
    # Wait until Elasticsearch is healthy
    for _ in range(5):
        if is_elasticsearch_healthy():
            break
        time.sleep(5)

    assert is_elasticsearch_healthy(), "Elasticsearch is not healthy"

# Test basic Elasticsearch operations
def test_elasticsearch_operations(elasticsearch):
    # Wait until Elasticsearch is healthy
    for _ in range(5):
        if is_elasticsearch_healthy():
            break
        time.sleep(5)

    assert is_elasticsearch_healthy(), "Elasticsearch is not healthy"

    # Create an index
    create_index_response = requests.put("http://localhost:9200/my_test_index?pretty")
    assert create_index_response.status_code == 200, "Failed to create index"

    # Insert a document
    document = {
        "user": "test_user",
        "message": "Testing Elasticsearch"
    }
    insert_doc_response = requests.post("http://localhost:9200/my_test_index/_doc/1?pretty", json=document)
    assert insert_doc_response.status_code == 201, "Failed to insert document"

    # Retrieve the document
    retrieve_doc_response = requests.get("http://localhost:9200/my_test_index/_doc/1?pretty")
    assert retrieve_doc_response.status_code == 200, "Failed to retrieve document"
    assert retrieve_doc_response.json()['_source'] == document, "Document does not match"
