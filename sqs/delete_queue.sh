#!/bin/sh

SQS_QUEUE_URL=$(aws sqs create-queue --queue-name $SQS_QUEUE_NAME --query QueueUrl  | tr -d '"')
aws sqs delete-queue --queue-url $SQS_QUEUE_URL
