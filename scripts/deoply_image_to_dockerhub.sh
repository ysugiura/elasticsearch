#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if IMAGE_VERSION is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <IMAGE_VERSION>"
  exit 1
fi

# Variables
IMAGE_VERSION=$1
DOCKERHUB_REPOSITORY_NAME="elasticsearch"
DOCKERHUB_USERNAME="ysugiura"

# Function to authenticate and log in to Docker Hub
authenticate_dockerhub() {
  echo "Logging into Docker Hub..."
  docker login --username $DOCKERHUB_USERNAME
  if [ $? -ne 0 ]; then
    echo "Failed to log into Docker Hub. Please check your credentials."
    exit 1
  fi
}

# Authenticate to Docker Hub
authenticate_dockerhub

# Ensure docker buildx is set up
echo "Setting up Docker buildx..."
docker buildx create --use || true # Create and switch to buildx builder if not already created

# Build the Docker image for multiple platforms (amd64, arm64)
echo "Building the Docker image $DOCKERHUB_USERNAME/$DOCKERHUB_REPOSITORY_NAME:$IMAGE_VERSION for multiple platforms..."
docker buildx build --platform linux/amd64,linux/arm64 -t $DOCKERHUB_USERNAME/$DOCKERHUB_REPOSITORY_NAME:$IMAGE_VERSION --push .
if [ $? -ne 0 ]; then
  echo "Failed to build the Docker image."
  exit 1
fi

# Tag the image for Docker Hub as 'latest'
echo "Tagging the image for Docker Hub as: $DOCKERHUB_USERNAME/$DOCKERHUB_REPOSITORY_NAME:latest"
docker buildx build --platform linux/amd64,linux/arm64 -t $DOCKERHUB_USERNAME/$DOCKERHUB_REPOSITORY_NAME:latest --push .
if [ $? -ne 0 ]; then
  echo "Failed to tag and push the Docker image to Docker Hub."
  exit 1
fi

# Clean up unused Docker images
echo "Cleaning up unused Docker images..."
docker image prune -f

echo "Docker image $DOCKERHUB_REPOSITORY_NAME:$IMAGE_VERSION has been successfully built and pushed to Docker Hub."