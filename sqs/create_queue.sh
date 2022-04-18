#!/bin/sh

n=0
until [ "$n" -ge 5 ]
do
  CMD_OUTPUT=$(aws sqs create-queue --queue-name $SQS_QUEUE_NAME --attributes MaximumMessageSize=2048 --query QueueUrl  | tr -d '"')

  GREP_INPUT_EX=$(echo "$CMD_OUTPUT" | grep AWS.SimpleQueueService.QueueDeletedRecently)
  if [ ! "$GREP_INPUT_EX" = *"InvalidInputException"* ]; then
    SQS_QUEUE_URL=$CMD_OUTPUT
    echo "SQS_QUEUE_URL $SQS_QUEUE_URL"
    GET_QUEUE_ARGS="--attribute-names QueueArn --query Attributes.QueueArn"
    SQS_QUEUE_ARN=$(aws sqs get-queue-attributes --queue-url $SQS_QUEUE_URL $GET_QUEUE_ARGS | tr -d '"')
    echo "SQS_QUEUE_ARN $SQS_QUEUE_ARN"

    # Apply SQS queue policy
    SQS_POLICY_ID=$SQS_QUEUE_NAME-policy
    SQS_RESOURCE=arn:aws:sqs:$AWS_REGION_VALUE:$AWS_ACCOUNT_ID_VALUE:$SQS_QUEUE_NAME

    TEMPLATE_JSON=./sqs/sqs_policy_template.json
    VALUES_JSON=./sqs/sqs_policy-values.json
    cp $TEMPLATE_JSON $VALUES_JSON

    sed -i 's@AWS_ACCOUNT_ID_VALUE@'"$AWS_ACCOUNT_ID_VALUE"'@g' $VALUES_JSON
    sed -i 's@SQS_POLICY_ID@'"$SQS_POLICY_ID"'@g' $VALUES_JSON
    sed -i 's@SQS_RESOURCE@'"$SQS_RESOURCE"'@g' $VALUES_JSON
    
    # \"Principal\":{\"AWS\":[\"arn:aws:iam::<aws_account_id>:root\",\"arn:aws:iam::<aws_account_id>:role/lafleet-eks-sa-sqsconsumer\"]}
    #aws sqs set-queue-attributes --queue-url $SQS_QUEUE_URL --attributes file://$VALUES_JSON

    break
  fi
  n=$((n+1))
  sleep 15
done

