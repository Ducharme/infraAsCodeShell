#!/bin/sh

IAM_ROLE_NAME=$PROJECT_NAME-codebuild-$CODEBUILD_NAME-role
IAM_ROLE_ARN=arn:aws:iam::$AWS_ACCOUNT_ID_VALUE:role$IAM_SERVICE_PATH$IAM_ROLE_NAME

CDN_CALLER_REFERENCE=$S3_REACT_WEB.s3.$AWS_REGION_VALUE.amazonaws.com
OAI_CALLER_REFERENCE=access-identity-$CDN_CALLER_REFERENCE
S3_ARN=arn:aws:s3:::$S3_REACT_WEB
JQF=".CloudFrontOriginAccessIdentityList.Items[] | select (.Comment == \"$OAI_CALLER_REFERENCE\") | .Id"
DIST_OAI=$(aws cloudfront list-cloud-front-origin-access-identities | jq "$JQF" | tr -d '"')
OAI_AWS_PRINCIPAL="arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity $DIST_OAI"

TEMPLATE_JSON=./s3/react_bucket_policy_template.json
VALUES_JSON=./s3/tmp_react_bucket_policy-values.json
cp $TEMPLATE_JSON $VALUES_JSON

sed -i 's@OAI_AWS_PRINCIPAL@'"$OAI_AWS_PRINCIPAL"'@g' $VALUES_JSON
sed -i 's@S3_ARN@'"$S3_ARN"'@g' $VALUES_JSON
sed -i 's@IAM_ROLE_ARN@'"$IAM_ROLE_ARN"'@g' $VALUES_JSON

aws s3api put-bucket-policy --bucket $S3_REACT_WEB --policy file://$VALUES_JSON
