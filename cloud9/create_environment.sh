#!/bin/sh

CLOUD9_ENV_ID=$(aws cloud9 create-environment-ec2 --name $PROJECT_NAME-eks-client --description "LaFleet - Cloud9 client" --instance-type t3.small --automatic-stop-time-minutes 30 --owner-arn $AWS_ADMIN_ARN)
aws cloud9 create-environment-membership --environment-id $CLOUD9_ENV_ID --user-arn arn:aws:iam::$AWS_ACCOUNT_ID_VALUE:root --permissions read-write
