#!/bin/sh

IAM_POLICY_NAME=$PROJECT_NAME-codebuild-$CODEBUILD_NAME-policy
IAM_POLICY_ARN=arn:aws:iam::$AWS_ACCOUNT_ID_VALUE:policy$IAM_SERVICE_PATH$IAM_POLICY_NAME
IAM_ROLE_NAME=$PROJECT_NAME-codebuild-$CODEBUILD_NAME-role
IAM_ROLE_ARN=arn:aws:iam::$AWS_ACCOUNT_ID_VALUE:role$IAM_SERVICE_PATH$IAM_ROLE_NAME

IAM_TRUST_POLICY=./iam/codebuild_role_trust_policy.json
TEMPLATE_JSON=./iam/codebuild_policy_template.json
VALUES_JSON=./iam/tmp_codebuild_policy_$CODEBUILD_NAME-values.json
cp $TEMPLATE_JSON $VALUES_JSON

sed -i 's@AWS_REGION_VALUE@'"$AWS_REGION_VALUE"'@g' $VALUES_JSON
sed -i 's@AWS_ACCOUNT_ID_VALUE@'"$AWS_ACCOUNT_ID_VALUE"'@g' $VALUES_JSON
sed -i 's@PROJECT_NAME@'"$PROJECT_NAME"'@g' $VALUES_JSON
sed -i 's@CODEBUILD_NAME@'"$CODEBUILD_NAME"'@g' $VALUES_JSON
sed -i 's@CODEBUILD_ARTIFACT@'"$CODEBUILD_ARTIFACT"'@g' $VALUES_JSON
sed -i 's@CODEPIPELINE_ARTIFACT@'"$CODEPIPELINE_ARTIFACT"'@g' $VALUES_JSON
sed -i 's@S3_OBJECT_STORE@'"$S3_OBJECT_STORE"'@g' $VALUES_JSON

aws iam create-policy --policy-name $IAM_POLICY_NAME --path $IAM_SERVICE_PATH --policy-document file://$VALUES_JSON
aws iam create-role --role-name $IAM_ROLE_NAME --path $IAM_SERVICE_PATH --assume-role-policy-document file://$IAM_TRUST_POLICY
aws iam attach-role-policy --policy-arn $IAM_POLICY_ARN --role-name $IAM_ROLE_NAME


if [ "$DST_SOURCECODE_REPO_NAME" = "reactFrontend" ]; then

  IAM_POLICY_NAME2=$PROJECT_NAME-codebuild-react-frontend-cdn-createinvalidation-policy
  IAM_POLICY_ARN2=arn:aws:iam::$AWS_ACCOUNT_ID_VALUE:policy$IAM_SERVICE_PATH$IAM_POLICY_NAME2

  TEMPLATE_JSON2=./iam/codebuild_policy_cdn_createinvalidation_template.json
  VALUES_JSON2=./iam/tmp_codebuild_policy_cdn_createinvalidation-values.json
  cp $TEMPLATE_JSON2 $VALUES_JSON2

  sed -i 's@AWS_ACCOUNT_ID_VALUE@'"$AWS_ACCOUNT_ID_VALUE"'@g' $VALUES_JSON2
  sed -i 's@CDN_DIST_ID@'"$DIST_ID"'@g' $VALUES_JSON2

  aws iam create-policy --policy-name $IAM_POLICY_NAME2 --path $IAM_SERVICE_PATH --policy-document file://$VALUES_JSON2
  aws iam attach-role-policy --policy-arn $IAM_POLICY_ARN2 --role-name $IAM_ROLE_NAME

fi
