#!/bin/sh

# ./iot/create_topic_rule.sh
IOT_RULE_NAME=sendToSqsRule
aws iot delete-topic-rule --rule-name $IOT_RULE_NAME

# ./iam/create_iot_rule_sqs_role.sh
IOT_RULE_NAME=sendToSqsRule
IAM_POLICY_NAME=$PROJECT_NAME-$CODEBUILD_NAME-$IOT_RULE_NAME-policy
IAM_POLICY_ARN=arn:aws:iam::$AWS_ACCOUNT_ID_VALUE:policy$IAM_SERVICE_PATH$IAM_POLICY_NAME
IAM_ROLE_NAME=$PROJECT_NAME-$CODEBUILD_NAME-$IOT_RULE_NAME-role
IAM_ROLE_ARN=arn:aws:iam::$AWS_ACCOUNT_ID_VALUE:role$IAM_SERVICE_PATH$IAM_ROLE_NAME
. ./iam/delete_role_policy.sh

# ./iam/create_cw_logs_write_error_logs_role.sh
LOG_GROUP=$CW_IOT_DEVICE_ERROR_LOG_GROUP
IAM_POLICY_NAME=$CW_IOT_DEVICE_ERROR_IAM_POLICY_NAME
IAM_POLICY_ARN=$CW_IOT_DEVICE_ERROR_IAM_POLICY_ARN
IAM_ROLE_NAME=$CW_IOT_DEVICE_ERROR_IAM_ROLE_NAME
. ./iam/delete_role_policy.sh

LOG_GROUP=$CW_IOT_DEVICE_LOGS_LOG_GROUP
IAM_POLICY_NAME=$CW_IOT_DEVICE_LOGS_IAM_POLICY_NAME
IAM_POLICY_ARN=$CW_IOT_DEVICE_LOGS_IAM_POLICY_ARN
IAM_ROLE_NAME=$CW_IOT_DEVICE_LOGS_IAM_ROLE_NAME
. ./iam/delete_role_policy.sh

# ./logs/create_cw_iot_device_error_logs.sh
aws logs delete-log-group --log-group-name $CW_IOT_DEVICE_ERROR_LOG_GROUP

# ./logs/create_cw_iot_device_logs.sh
aws logs delete-log-group --log-group-name $CW_IOT_DEVICE_LOGS_LOG_GROUP

# ./iot/create_iot_policy.sh
DEVICE_POLICY_NAME=device-policy
THING_POLICY_NAME=$PROJECT_NAME-$DEVICE_POLICY_NAME
THING_POLICY_ARN=arn:aws:iot:$AWS_REGION_VALUE:$AWS_ACCOUNT_ID_VALUE:policy/$THING_POLICY_NAME
THING_ARN=arn:aws:iot:$AWS_REGION_VALUE:$AWS_ACCOUNT_ID_VALUE:thing/$CODEBUILD_NAME

echo "aws iot list-targets-for-policy"
CERTIFICATE_ARN=$(aws iot list-targets-for-policy --policy-name lafleet-device-policy | jq '.targets[0]' | tr -d '"')
echo CERTIFICATE_ARN "$CERTIFICATE_ARN"
if [ ! "$CERTIFICATE_ARN" = *"ResourceNotFoundException"* ] && [ ! -z "$CERTIFICATE_ARN" ] && [ ! "$CERTIFICATE_ARN" = "null" ]; then
  aws iot detach-policy --target $CERTIFICATE_ARN --policy-name $THING_POLICY_NAME
  aws iot detach-thing-principal --thing-name $THING_NAME --principal $CERTIFICATE_ARN

  CERTIFICATE_ID=${CERTIFICATE_ARN#*/}
  echo "CERTIFICATE_ID (POLICY) $CERTIFICATE_ID"
  aws iot update-certificate --certificate-id $CERTIFICATE_ID --new-status INACTIVE
  aws iot delete-certificate --certificate-id $CERTIFICATE_ID
fi

echo "aws iot list-thing-principals"
ARR=$(aws iot list-thing-principals --thing-name $THING_NAME | grep "arn:aws:iot:" |  tr -d '" ,' )
echo "$ARR" | tr ' ' '\n' | while read item; do
  THING_CERTIFICATE_ARN="$item"
  echo "THING_CERTIFICATE_ARN $THING_CERTIFICATE_ARN";
  if [ -z "$THING_CERTIFICATE_ARN" ] || [ "$THING_CERTIFICATE_ARN" = "null" ]; then
    break
  fi

  aws iot detach-thing-principal --thing-name $THING_NAME --principal $THING_CERTIFICATE_ARN

  THING_CERTIFICATE_ID=${THING_CERTIFICATE_ARN#*/}
  echo "THING_CERTIFICATE_ID (ATTACHED): $THING_CERTIFICATE_ID"
  aws iot update-certificate --certificate-id $THING_CERTIFICATE_ID --new-status INACTIVE
  aws iot delete-certificate --certificate-id $THING_CERTIFICATE_ID
done

# delete all versions (the one attached will fail but it is fine)
echo "THING_POLICY_NAME $THING_POLICY_NAME"
ARR=$(aws iot list-policy-versions --policy-name $THING_POLICY_NAME | jq '.policyVersions[] | .versionId' |  tr -d '"')
echo "$ARR" | tr ' ' '\n' | while read item; do
  IOT_POLICY_VERSION=$item
  echo "IOT_POLICY_VERSION $IOT_POLICY_VERSION"
  aws iot delete-policy-version --policy-name $THING_POLICY_NAME --policy-version-id $IOT_POLICY_VERSION
done

# detach all principals (policy certificates)
ARR=$(aws iot list-targets-for-policy --policy-name $THING_POLICY_NAME | jq '.targets[]' |  tr -d '"')
echo "$ARR" | tr ' ' '\n' | while read item; do
  IOT_POLICY_CERT=$item
  echo "IOT_POLICY_CERT $IOT_POLICY_CERT"
  aws iot detach-policy --policy-name $THING_POLICY_NAME --target $IOT_POLICY_CERT
done

aws iot delete-policy --policy-name $THING_POLICY_NAME
echo "THING_NAME $THING_NAME"
n=0
until [ "$n" -ge 5 ]
do
  CMD_OUTPUT=$(aws iot delete-thing --thing-name $THING_NAME)
  echo "aws iot delete-thing --thing-name $THING_NAME >> $CMD_OUTPUT"
  GREP_CONFLICT_EX=$(echo "$CMD_OUTPUT" | grep DeleteConflictException)
  if [ ! "$GREP_CONFLICT_EX" = *"DeleteConflictException"* ]; then
    echo "aws iot delete-thing >> Breaking"
    break
  fi
  n=$((n+1))
  sleep 3
done


TXT_CRT=$(aws s3 ls s3://$S3_OBJECT_STORE/certs/$THING_TXT_FILENAME | grep $THING_TXT_FILENAME)
if [ "$TXT_CRT" = *"$THING_TXT_FILENAME" ]; then
  aws s3 cp s3://$S3_OBJECT_STORE/certs/$THING_TXT_FILENAME ./$THING_TXT_FILENAME

  DELETE_CERTIFICATE_ID=$(cat ./$THING_TXT_FILENAME)
  echo "THING_CERTIFICATE_ID (DEL): $DELETE_CERTIFICATE_ID"
  aws iot update-certificate --certificate-id $DELETE_CERTIFICATE_ID --new-status INACTIVE
  aws iot delete-certificate --certificate-id $DELETE_CERTIFICATE_ID

  aws s3 rm s3://$S3_OBJECT_STORE/certs/$THING_TXT_FILENAME
  aws s3 rm s3://$S3_OBJECT_STORE/certs/$THING_CRT_FILENAME
  aws s3 rm s3://$S3_OBJECT_STORE/certs/$THING_PUB_FILENAME
  aws s3 rm s3://$S3_OBJECT_STORE/certs/$THING_PRV_FILENAME
  aws s3 rm s3://$S3_OBJECT_STORE/certs/$THING_RCA_FILENAME
  rm $THING_TXT_FILENAME
fi
