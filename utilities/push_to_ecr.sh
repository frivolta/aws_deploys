#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

# Replace with your AWS region
AWS_ACCOUNT_ID="062634955764"
AWS_REGION="eu-west-1"
ECR_REPOSITORY="ecs-default-main-ecr"
GIT_COMMIT_HASH=$(git rev-parse --short HEAD)
DOCKER_IMAGE_TAG="${GIT_COMMIT_HASH}"
DOCKERFILE_PATH="Dockerfile" # Specify the custom Dockerfile path here
DOCKER_IMAGE_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${DOCKER_IMAGE_TAG}"
AWS_PROFILE="fantasia" # Specify your custom AWS CLI profile name here

########### just styles ###############
# Define colors using ANSI escape codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to echo with green color
green_echo() {
  echo -e "${GREEN}$1${NC}"
}

# Function to echo with red color
red_echo() {
  echo -e "${RED}$1${NC}"
}
########### ./just styles ###############

# Build the Docker image
green_echo "Building Docker image..."
docker build -t "${DOCKER_IMAGE_URI}" -f "${DOCKERFILE_PATH}" .

# Authenticate Docker to ECR
green_echo "Authenticating Docker to ECR..."
if ! aws --profile "${AWS_PROFILE}" ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"; then
  red_echo "Error: Docker login to ECR failed!"
  exit 1
fi

# Push the Docker image to ECR
green_echo "Pushing Docker image to ECR..."
if ! docker push "${DOCKER_IMAGE_URI}"; then
  red_echo "Error: Docker push to ECR failed!"
  exit 1
fi

green_echo "Docker image pushed successfully to ECR!"
