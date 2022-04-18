#!/bin/sh

TEMPLATE_JSON=./iot/thing_topic_rule_template.json
VALUES_JSON=./iot/tmp_thing_topic_rule-values.json
cp $TEMPLATE_JSON $VALUES_JSON

SQS_IAM_ROLE_ARN=$IAM_ROLE_ARN # To avoid clashes with other ARNs below
sed -i 's@THING_TOPIC@'"$THING_TOPIC"'@g' $VALUES_JSON
sed -i 's@SQS_QUEUE_URL@'"$SQS_QUEUE_URL"'@g' $VALUES_JSON
sed -i 's@SQS_IAM_ROLE_ARN@'"$SQS_IAM_ROLE_ARN"'@g' $VALUES_JSON
sed -i 's@CW_IOT_DEVICE_LOGS_LOG_GROUP@'"$CW_IOT_DEVICE_LOGS_LOG_GROUP"'@g' $VALUES_JSON
sed -i 's@CW_IOT_DEVICE_LOGS_IAM_ROLE_ARN@'"$CW_IOT_DEVICE_LOGS_IAM_ROLE_ARN"'@g' $VALUES_JSON
sed -i 's@CW_IOT_DEVICE_ERROR_LOG_GROUP@'"$CW_IOT_DEVICE_ERROR_LOG_GROUP"'@g' $VALUES_JSON
sed -i 's@CW_IOT_DEVICE_ERROR_IAM_ROLE_ARN@'"$CW_IOT_DEVICE_ERROR_IAM_ROLE_ARN"'@g' $VALUES_JSON

n=0
until [ "$n" -ge 5 ]
do
  aws iot create-topic-rule --rule-name $IOT_RULE_NAME --topic-rule-payload file://$VALUES_JSON && break
  n=$((n+1)) 
  sleep 3
done
