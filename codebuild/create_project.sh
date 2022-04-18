#!/bin/sh

SOURCE_LOCATION=https://git-codecommit.$AWS_REGION_VALUE.amazonaws.com/v1/repos/$DST_SOURCECODE_REPO_NAME

TEMPLATE_JSON=./codebuild/codebuild_template.json
VALUES_JSON=./codebuild/tmp_codebuild_$CODEBUILD_NAME-values.json
cp $TEMPLATE_JSON $VALUES_JSON

sed -i 's@AWS_REGION_VALUE@'"$AWS_REGION_VALUE"'@g' $VALUES_JSON
sed -i 's@AWS_ACCOUNT_ID_VALUE@'"$AWS_ACCOUNT_ID_VALUE"'@g' $VALUES_JSON
sed -i 's@PROJECT_NAME@'"$PROJECT_NAME"'@g' $VALUES_JSON
sed -i 's@CODEBUILD_ARTIFACT@'"$CODEBUILD_ARTIFACT"'@g' $VALUES_JSON
sed -i 's@CODEBUILD_NAME@'"$CODEBUILD_NAME"'@g' $VALUES_JSON
sed -i 's@BUILD_DESCRIPTION@'"$BUILD_DESCRIPTION"'@g' $VALUES_JSON
sed -i 's@IMAGE_REPO_NAME_VALUE@'"$IMAGE_REPO_NAME_VALUE"'@g' $VALUES_JSON
sed -i 's@S3_OBJECT_STORE_VALUE@'"$S3_OBJECT_STORE"'@g' $VALUES_JSON
sed -i 's@SOURCE_LOCATION@'"$SOURCE_LOCATION"'@g' $VALUES_JSON
sed -i 's@IAM_ROLE_ARN@'"$IAM_ROLE_ARN"'@g' $VALUES_JSON
sed -i 's@ENCRYPTION_KEY_VALUE@'"$ENCRYPTION_KEY_VALUE"'@g' $VALUES_JSON
sed -i 's@CODEBUILD_BRANCH_NAME@'"$CODEBUILD_BRANCH_NAME"'@g' $VALUES_JSON


n=0
until [ "$n" -ge 5 ]
do
  CMD_OUTPUT=$(aws codebuild create-project --cli-input-json file://$VALUES_JSON)
  echo "$CMD_OUTPUT" > ./codebuild/tmp_create_project_output.json
  GREP_INPUT_EX=$(echo "$CMD_OUTPUT" | grep InvalidInputException)
  GREP_STRUCT_EX=$(echo "$CMD_OUTPUT" | grep InvalidStructureException)
  if [ ! -z "$CMD_OUTPUT" ] && [ ! "$GREP_INPUT_EX" = *"InvalidInputException"* ] && [ ! "$GREP_STRUCT_EX" = *"InvalidStructureException"* ]; then
    break
  fi
  n=$((n+1))
  sleep 3
done
