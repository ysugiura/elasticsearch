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
REGION="ap-northeast-1"
ACCOUNT_ID="188950198779"
REPOSITORY_NAME="activewave/elasticsearch"
PROFILE="ecr"

# Function to authenticate and log in to AWS ECR
authenticate_ecr() {
  echo "Logging into AWS ECR using profile $PROFILE..."
  aws ecr get-login-password --region $REGION --profile $PROFILE | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
  if [ $? -ne 0 ]; then
    echo "Failed to log into AWS ECR. Please check your credentials."
    exit 1
  fi
}

# Authenticate before starting the process
authenticate_ecr

# Create the repository (if it doesn't exist)
echo "Creating the repository $REPOSITORY_NAME..."
aws ecr create-repository --repository-name $REPOSITORY_NAME --region $REGION --profile $PROFILE || echo "Repository $REPOSITORY_NAME already exists."

# Build the Docker image
echo "Building the Docker image $REPOSITORY_NAME:$IMAGE_VERSION..."
docker build -t $REPOSITORY_NAME:$IMAGE_VERSION .
if [ $? -ne 0 ]; then
  echo "Failed to build the Docker image."
  exit 1
fi

# Tag the image
echo "Tagging the image..."
docker tag $REPOSITORY_NAME:$IMAGE_VERSION $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:$IMAGE_VERSION
docker tag $REPOSITORY_NAME:$IMAGE_VERSION $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:latest

if [ $? -ne 0 ]; then
  echo "Failed to tag the Docker image."
  exit 1
fi

# Push the image to the registry with reauthentication if the token has expired
push_image() {
  echo "Pushing the image to the ECR repository..."
  docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:$IMAGE_VERSION
  if [ $? -ne 0 ]; then
    echo "Push failed. Trying to reauthenticate and push again..."
    authenticate_ecr
    docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:$IMAGE_VERSION
    if [ $? -ne 0 ]; then
      echo "Failed to push the Docker image after reauthentication."
      exit 1
    fi
  fi
}

# Attempt to push the image
push_image

echo "Docker image $REPOSITORY_NAME:$IMAGE_VERSION has been pushed successfully."