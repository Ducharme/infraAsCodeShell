#!/bin/sh

# Same values for all builds
PROJECT_NAME=lafleet
AWS_REGION_VALUE=$(aws configure get region)
AWS_ACCOUNT_ID_VALUE=$(aws sts get-caller-identity --query "Account" --output text)
CODEBUILD_ARTIFACT=$PROJECT_NAME-codebuild-artifacts-repo-$AWS_ACCOUNT_ID_VALUE # S3_BUCKET_NAME
CODEPIPELINE_ARTIFACT=$PROJECT_NAME-codepipeline-artifacts-repo-$AWS_ACCOUNT_ID_VALUE # S3_BUCKET_NAME
S3_OBJECT_STORE=$PROJECT_NAME-object-store-$AWS_ACCOUNT_ID_VALUE
S3_REACT_WEB=$PROJECT_NAME-react-web-$AWS_ACCOUNT_ID_VALUE
ENCRYPTION_KEY_VALUE=arn:aws:kms:$AWS_REGION_VALUE:$AWS_ACCOUNT_ID_VALUE:alias/aws/s3
AWS_ADMIN_USER=$PROJECT_NAME-ekscluster-admin
SQS_QUEUE_NAME=$PROJECT_NAME-device-messages
IAM_SERVICE_PATH=/service-role/
