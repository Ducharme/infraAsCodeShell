#!/bin/sh

# Specific values for this build
CODEPIPELINE_NAME=$CODEBUILD_NAME
CODEPIPELINE_ARN=arn:aws:iam::$AWS_ACCOUNT_ID_VALUE:role$IAM_SERVICE_PATH$IAM_ROLE_NAME
CODEPIPELINE_REPOSITORY_NAME=$CODEBUILD_NAME
CODEPIPELINE_PROJECT_NAME=$CODEPIPELINE_REPOSITORY_NAME
CODEPIPELINE_OBJECT_KEY=$CODEPIPELINE_REPOSITORY_NAME-codepipeline.zip

TEMPLATE_JSON=./codepipeline/codepipeline_template.json
VALUES_JSON=./codepipeline/tmp_codepipeline_$CODEBUILD_NAME-values.json
cp $TEMPLATE_JSON $VALUES_JSON

sed -i 's@AWS_REGION_VALUE@'"$AWS_REGION_VALUE"'@g' $VALUES_JSON
sed -i 's@AWS_ACCOUNT_ID_VALUE@'"$AWS_ACCOUNT_ID_VALUE"'@g' $VALUES_JSON
sed -i 's@CODEPIPELINE_NAME@'"$CODEPIPELINE_NAME"'@g' $VALUES_JSON
sed -i 's@CODEPIPELINE_ARN@'"$CODEPIPELINE_ARN"'@g' $VALUES_JSON
sed -i 's@CODEPIPELINE_ARTIFACT@'"$CODEPIPELINE_ARTIFACT"'@g' $VALUES_JSON
sed -i 's@CODEBUILD_BRANCH_NAME@'"$CODEBUILD_BRANCH_NAME"'@g' $VALUES_JSON
sed -i 's@CODEPIPELINE_REPOSITORY_NAME@'"$CODEPIPELINE_REPOSITORY_NAME"'@g' $VALUES_JSON
sed -i 's@CODEPIPELINE_PROJECT_NAME@'"$CODEPIPELINE_PROJECT_NAME"'@g' $VALUES_JSON
sed -i 's@CODEPIPELINE_OBJECT_KEY@'"$CODEPIPELINE_OBJECT_KEY"'@g' $VALUES_JSON


n=0
until [ "$n" -ge 5 ]
do
  CMD_OUTPUT=$(aws codepipeline create-pipeline --cli-input-json file://$VALUES_JSON)
  echo "$CMD_OUTPUT" > ./codepipeline/tmp_create_codepipeline_output.json
  GREP_INPUT_EX=$(echo "$CMD_OUTPUT" | grep InvalidInputException)
  GREP_STRUCT_EX=$(echo "$CMD_OUTPUT" | grep InvalidStructureException)
  if [ ! -z "$CMD_OUTPUT" ] && [ ! "$GREP_INPUT_EX" = *"InvalidInputException"* ] && [ ! "$GREP_STRUCT_EX" = *"InvalidStructureException"* ]; then
    break
  fi
  n=$((n+1))
  sleep 3
done
