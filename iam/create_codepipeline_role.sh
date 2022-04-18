#!/bin/sh

# Specific values for this build
IAM_POLICY_NAME=$PROJECT_NAME-codepipeline-$CODEBUILD_NAME-policy
IAM_ROLE_NAME=$PROJECT_NAME-codepipeline-$CODEBUILD_NAME-role
IAM_POLICY_ARN=arn:aws:iam::$AWS_ACCOUNT_ID_VALUE:policy$IAM_SERVICE_PATH$IAM_POLICY_NAME

IAM_TRUST_POLICY=./iam/codepipeline_role_trust_policy.json
TEMPLATE_JSON=./iam/codepipeline_policy_template.json
VALUES_JSON=./iam/tmp_codepipeline_policy_$CODEBUILD_NAME-values.json
cp $TEMPLATE_JSON $VALUES_JSON

aws iam create-policy --policy-name $IAM_POLICY_NAME --path $IAM_SERVICE_PATH --policy-document file://$VALUES_JSON
aws iam create-role --role-name $IAM_ROLE_NAME --path $IAM_SERVICE_PATH --assume-role-policy-document file://$IAM_TRUST_POLICY
aws iam attach-role-policy --policy-arn $IAM_POLICY_ARN --role-name $IAM_ROLE_NAME
