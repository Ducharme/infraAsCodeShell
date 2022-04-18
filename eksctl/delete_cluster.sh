#!/bin/sh

export EKSCTL_ENABLE_CREDENTIAL_CACHE=1
CLUSTER_NAME=$PROJECT_NAME-cluster
EKS_SQS_SA_NAME=$PROJECT_NAME-eks-sa-sqsconsumer
export KUBECONFIG=$KUBECONFIG:~/.kube/eksctl/clusters/$CLUSTER_NAME

eksctl delete cluster -f ./eksctl/lafleet.yaml --wait
#eksctl delete cluster -f ./eksctl/lafleet-small.yaml --wait
