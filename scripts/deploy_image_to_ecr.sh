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
ECR_REPOSITORY_NAME="activewave/elasticsearch"
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

# Authenticate to AWS ECR
authenticate_ecr

# Create the repository (if it doesn't exist)
echo "Creating the AWS ECR repository $ECR_REPOSITORY_NAME if it doesn't exist..."
aws ecr create-repository --repository-name $ECR_REPOSITORY_NAME --region $REGION --profile $PROFILE || echo "Repository $ECR_REPOSITORY_NAME already exists."

# Build the Docker image
echo "Building the Docker image $ECR_REPOSITORY_NAME:$IMAGE_VERSION..."
docker build -t $ECR_REPOSITORY_NAME:$IMAGE_VERSION .
if [ $? -ne 0 ]; then
  echo "Failed to build the Docker image."
  exit 1
fi

# Tag the image for AWS ECR
echo "Tagging the image for AWS ECR as: $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPOSITORY_NAME:$IMAGE_VERSION"
docker tag $ECR_REPOSITORY_NAME:$IMAGE_VERSION $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPOSITORY_NAME:$IMAGE_VERSION
docker tag $ECR_REPOSITORY_NAME:$IMAGE_VERSION $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPOSITORY_NAME:latest

# Push the image to AWS ECR
echo "Pushing the image to AWS ECR: $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPOSITORY_NAME:$IMAGE_VERSION"
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPOSITORY_NAME:$IMAGE_VERSION
if [ $? -ne 0 ]; then
  echo "Push to AWS ECR failed. Trying to reauthenticate and push again..."
  authenticate_ecr
  docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPOSITORY_NAME:$IMAGE_VERSION
  if [ $? -ne 0 ]; then
    echo "Failed to push the Docker image to AWS ECR after reauthentication."
    exit 1
  fi
fi

# Clean up unused Docker images
echo "Cleaning up unused Docker images..."
docker image prune -f

echo "Docker image $ECR_REPOSITORY_NAME:$IMAGE_VERSION has been pushed successfully to AWS ECR."