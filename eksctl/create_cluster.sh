#!/bin/sh

export EKSCTL_ENABLE_CREDENTIAL_CACHE=1
CLUSTER_NAME=$PROJECT_NAME-cluster
EKS_SQS_SA_NAME=$PROJECT_NAME-eks-sa-sqsconsumer
export KUBECONFIG=$KUBECONFIG:~/.kube/eksctl/clusters/$CLUSTER_NAME


eksctl create cluster -f ./eksctl/lafleet.yaml --auto-kubeconfig
#eksctl create cluster -f ./eksctl/lafleet-small.yaml --auto-kubeconfig
#eksctl utils write-kubeconfig --cluster=$CLUSTER_NAME --kubeconfig=lafleet-auto.yaml --set-kubeconfig-context=true
#eksctl create nodegroup --config-file=./eksctl/lafleet-small.yaml

# Next 3 lines needed for creating an ARM nodegroup kube-proxy
eksctl utils update-coredns --cluster $CLUSTER_NAME
eksctl utils update-kube-proxy --cluster $CLUSTER_NAME --approve
eksctl utils update-aws-node --cluster $CLUSTER_NAME --approve
