#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

# Replace with your AWS region
AWS_REGION="eu-west-1"
ECR_REPOSITORY="ecs-default-main-ecr"
GIT_COMMIT_HASH=$(git rev-parse --short HEAD)
DOCKER_IMAGE_TAG="${GIT_COMMIT_HASH}"
DOCKER_IMAGE_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${DOCKER_IMAGE_TAG}"

# Build the Docker image
echo "Building Docker image..."
docker build -t "${DOCKER_IMAGE_URI}" .

# Authenticate Docker to ECR
echo "Authenticating Docker to ECR..."
if ! aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"; then
  echo "Error: Docker login to ECR failed!"
  exit 1
fi

# Push the Docker image to ECR
echo "Pushing Docker image to ECR..."
if ! docker push "${DOCKER_IMAGE_URI}"; then
  echo "Error: Docker push to ECR failed!"
  exit 1
fi

echo "Docker image pushed successfully to ECR!"
