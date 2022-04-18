#!/bin/sh

IAM_POLICY_ARN=arn:aws:iam::$AWS_ACCOUNT_ID_VALUE:policy$IAM_SERVICE_PATH$IAM_POLICY_NAME
aws iam detach-role-policy --role-name $IAM_ROLE_NAME --policy-arn $IAM_POLICY_ARN
aws iam delete-role-policy --role-name $IAM_ROLE_NAME --policy-name $IAM_POLICY_NAME
aws iam delete-role --role-name $IAM_ROLE_NAME
aws iam delete-policy --policy-arn $IAM_POLICY_ARN
