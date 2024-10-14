#!/bin/bash

# Set your Docker Hub username and repository name here
username="ysugiura"
repository="ysugiura/elasticsearch"

# Use Docker CLI to ensure you're logged in
docker login

# Get authentication token (osxkeychain should handle credentials now)
response=$(curl -s -u "$username" -X POST "https://hub.docker.com/v2/users/login/")

# Extract token from the response
token=$(echo "$response" | jq -r .token)

if [ "$token" == "null" ]; then
    echo "Authentication failed. Please check your username and ensure you're logged in."
    exit 1
fi

# List images with tags, image_id, and last_pushed
echo "Listing tags, image ID, and last pushed date for repository: $repository"
curl -s -H "Authorization: JWT $token" "https://hub.docker.com/v2/repositories/$repository/tags/" | jq '.results[] | {tag: .name, image_id: .images[0].digest, last_pushed: .last_pushed}'