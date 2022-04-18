#!/bin/sh

IAM_TRUST_POLICY=./iam/iot_trust_policy.json
TEMPLATE_JSON=./iam/iot_logs_policy_template.json
VALUES_JSON=./iam/tmp_iot_logs_policy_$CODEBUILD_NAME-values.json
cp $TEMPLATE_JSON $VALUES_JSON

sed -i 's@AWS_REGION_VALUE@'"$AWS_REGION_VALUE"'@g' $VALUES_JSON
sed -i 's@AWS_ACCOUNT_ID_VALUE@'"$AWS_ACCOUNT_ID_VALUE"'@g' $VALUES_JSON
sed -i 's@LOG_GROUP@'"$LOG_GROUP"'@g' $VALUES_JSON

aws iam create-policy --policy-name $IAM_POLICY_NAME --path $IAM_SERVICE_PATH --policy-document file://$VALUES_JSON
aws iam create-role --role-name $IAM_ROLE_NAME --path $IAM_SERVICE_PATH --assume-role-policy-document file://$IAM_TRUST_POLICY
aws iam attach-role-policy --policy-arn $IAM_POLICY_ARN --role-name $IAM_ROLE_NAME
