import requests
import json
import time

# Elasticsearch host
ES_HOST = "http://localhost:9200"
HEADERS = {"Content-Type": "application/json"}

# Example usage variables
INDEX_NAME = "my_index"
NEW_INDEX_NAME = "my_new_index"
SETTINGS = {
    "analysis": {
        "analyzer": {
            "custom_kuromoji_analyzer": {
                "tokenizer": "kuromoji_tokenizer",
                "filter": ["kuromoji_baseform", "lowercase"]
            }
        }
    }
}

def close_index(index_name):
    response = requests.post(f"{ES_HOST}/{index_name}/_close")
    if response.status_code == 200:
        print(f"Index '{index_name}' successfully closed.")
    else:
        print(f"Failed to close index '{index_name}': {response.text}")


def modify_settings(index_name, settings):
    response = requests.put(f"{ES_HOST}/{index_name}/_settings", headers=HEADERS, data=json.dumps(settings))
    if response.status_code == 200:
        print(f"Settings for index '{index_name}' successfully modified.")
    else:
        print(f"Failed to modify settings for index '{index_name}': {response.text}")


def open_index(index_name):
    response = requests.post(f"{ES_HOST}/{index_name}/_open")
    if response.status_code == 200:
        print(f"Index '{index_name}' successfully reopened.")
    else:
        print(f"Failed to reopen index '{index_name}': {response.text}")


def reindex_data(source_index, dest_index):
    # Define the reindex payload
    reindex_payload = {
        "source": {
            "index": source_index
        },
        "dest": {
            "index": dest_index
        }
    }

    response = requests.post(f"{ES_HOST}/_reindex", headers=HEADERS, data=json.dumps(reindex_payload))
    if response.status_code == 200:
        print(f"Data successfully reindexed from '{source_index}' to '{dest_index}'.")
    else:
        print(f"Failed to reindex data: {response.text}")


def create_new_index(index_name, settings):
    # Create a new index with the updated settings
    response = requests.put(f"{ES_HOST}/{index_name}", headers=HEADERS, data=json.dumps({
        "settings": settings,
        "mappings": {
            "properties": {
                "text": {
                    "type": "text",
                    "analyzer": "custom_kuromoji_analyzer"
                }
            }
        }
    }))
    if response.status_code == 200:
        print(f"Index '{index_name}' successfully created.")
    else:
        print(f"Failed to create index '{index_name}': {response.text}")


def main():
    # Close the index
    close_index(INDEX_NAME)

    # Modify the settings
    modify_settings(INDEX_NAME, SETTINGS)

    # Reopen the index
    open_index(INDEX_NAME)

    # Optionally reindex data into a new index
    # create_new_index(NEW_INDEX_NAME, SETTINGS)
    # reindex_data(INDEX_NAME, NEW_INDEX_NAME)


if __name__ == '__main__':
    main()