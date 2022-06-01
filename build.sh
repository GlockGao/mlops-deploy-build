#!/bin/bash

WORK_DIR=${PWD}


##########################################################
# 1. Deploy AI service (Here is 'boston housing service')

# 1.1 Logging in to Amazon ECR
echo "Logging in to Amazon ECR."

# Get the account number associated with the current IAM credentials
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
TAG=$(echo "${CODEBUILD_RESOLVED_SOURCE_VERSION}" | head -c 8)

echo "###################################"
echo "Image name : ${IMAGE}"
echo "Image tags : ${TAG}"
echo "Account    : ${ACCOUNT}"
echo "Region     : ${REGION}"
echo "###################################"

# Get full ECR repo name
ECR_REPO_FULL_NAME="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${IMAGE}"

# If the repository doesn't exist in ECR, create it.
aws ecr describe-repositories --repository-names "${IMAGE}" > /dev/null 2>&1
if [ $? -ne 0 ]
then
    aws ecr create-repository --repository-name "${IMAGE}" > /dev/null
fi

# Get the login command from ECR and execute it directly
aws ecr get-login-password --region "${REGION}" | docker login --username AWS --password-stdin "${ACCOUNT}".dkr.ecr."${REGION}".amazonaws.com

## 1.2 Build AI service image
echo "Building boston housing image."
aws s3 cp "${MODEL_URI}" ./model --recursive
docker build -t "${ECR_REPO_FULL_NAME}:latest" -f Dockerfile . || exit
docker tag "${ECR_REPO_FULL_NAME}:latest" "${ECR_REPO_FULL_NAME}:${TAG}" || exit

# 1.3 Push AI service image
echo "Pushing boston housing image."
docker push "${ECR_REPO_FULL_NAME}:latest" || exit
docker push "${ECR_REPO_FULL_NAME}:${TAG}" || exit
