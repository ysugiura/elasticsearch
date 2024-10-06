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

# Build the Docker image
echo "Building the Docker image $DOCKERHUB_USERNAME/$DOCKERHUB_REPOSITORY_NAME:$IMAGE_VERSION..."
docker build -t $DOCKERHUB_REPOSITORY_NAME:$IMAGE_VERSION .
if [ $? -ne 0 ]; then
  echo "Failed to build the Docker image."
  exit 1
fi

# Tag the image for Docker Hub
echo "Tagging the image for Docker Hub as: $DOCKERHUB_USERNAME/$DOCKERHUB_REPOSITORY_NAME:$IMAGE_VERSION"
docker tag $DOCKERHUB_REPOSITORY_NAME:$IMAGE_VERSION $DOCKERHUB_USERNAME/$DOCKERHUB_REPOSITORY_NAME:$IMAGE_VERSION
docker tag $DOCKERHUB_REPOSITORY_NAME:$IMAGE_VERSION $DOCKERHUB_USERNAME/$DOCKERHUB_REPOSITORY_NAME:latest

# Push the image to Docker Hub
echo "Pushing the image to Docker Hub: $DOCKERHUB_USERNAME/$DOCKERHUB_REPOSITORY_NAME:$IMAGE_VERSION"
docker push $DOCKERHUB_USERNAME/$DOCKERHUB_REPOSITORY_NAME:$IMAGE_VERSION
if [ $? -ne 0 ]; then
  echo "Failed to push the Docker image to Docker Hub."
  exit 1
fi

# Clean up unused Docker images
echo "Cleaning up unused Docker images..."
docker image prune -f

echo "Docker image $DOCKERHUB_REPOSITORY_NAME:$IMAGE_VERSION has been pushed successfully to Docker Hub."