#!/bin/sh

# Specific values for this build
IOT_RULE_NAME=sendToSqsRule
IAM_POLICY_NAME=$PROJECT_NAME-$CODEBUILD_NAME-$IOT_RULE_NAME-policy
IAM_POLICY_ARN=arn:aws:iam::$AWS_ACCOUNT_ID_VALUE:policy$IAM_SERVICE_PATH$IAM_POLICY_NAME
IAM_ROLE_NAME=$PROJECT_NAME-$CODEBUILD_NAME-$IOT_RULE_NAME-role
IAM_ROLE_ARN=arn:aws:iam::$AWS_ACCOUNT_ID_VALUE:role$IAM_SERVICE_PATH$IAM_ROLE_NAME

IAM_TRUST_POLICY=./iam/iot_trust_policy.json
TEMPLATE_JSON=./iam/iot_rule_sqs_policy_template.json
VALUES_JSON=./iam/tmp_iot_rule_sqs_policy-values.json
cp $TEMPLATE_JSON $VALUES_JSON

sed -i 's@AWS_REGION_VALUE@'"$AWS_REGION_VALUE"'@g' $VALUES_JSON
sed -i 's@AWS_ACCOUNT_ID_VALUE@'"$AWS_ACCOUNT_ID_VALUE"'@g' $VALUES_JSON
sed -i 's@SQS_QUEUE_NAME@'"$SQS_QUEUE_NAME"'@g' $VALUES_JSON

aws iam create-policy --policy-name $IAM_POLICY_NAME --path $IAM_SERVICE_PATH --policy-document file://$VALUES_JSON
aws iam create-role --role-name $IAM_ROLE_NAME --path $IAM_SERVICE_PATH --assume-role-policy-document file://$IAM_TRUST_POLICY
aws iam attach-role-policy --policy-arn $IAM_POLICY_ARN --role-name $IAM_ROLE_NAME
