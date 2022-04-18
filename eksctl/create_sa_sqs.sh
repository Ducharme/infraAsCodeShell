#!/bin/sh

eksctl create iamserviceaccount \
    --name $EKS_SQS_SA_NAME \
    --namespace default \
    --cluster $CLUSTER_NAME \
    --attach-policy-arn arn:aws:iam::$AWS_ACCOUNT_ID_VALUE:policy/eks_policy_sqsconsumer \
    --approve \
    --override-existing-serviceaccounts
