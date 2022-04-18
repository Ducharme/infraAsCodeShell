#!/bin/sh

DELETE_COMMON="FALSE"
DELETE_DEVICE="FALSE"
DELETE_WEBSITE="FALSE"
DELETE_CONSUMER="FALSE"
DELETE_QUERY="FALSE"
DELETE_ANALYTICS="FALSE"
DELETE_KUBERNETES="FALSE"
DELETE_APPS="FALSE"

##################################################
##########          Common           #############
##################################################

. ./set_common_env-vars.sh


##################################################
##########           Apps            #############
##################################################

if [ "$DELETE_APPS" = "TRUE" ]; then
    echo "Calling kubectl delete -f metrics-server"
    kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    echo "Calling helm uninstall kubernetes-ingress"
    helm uninstall kubernetes-ingress
    echo "Calling kubectl -n default delete pod,svc,job --all"
    kubectl -n default delete pod,svc,job --all
fi

##################################################
##########         Kubernetes        #############
##################################################

if [ "$DELETE_KUBERNETES" = "TRUE" ]; then
    echo "Calling ./eksctl/delete_cluster.sh"
    . ./eksctl/delete_cluster.sh
    echo "Deleting AWS EKS log group"
    aws logs delete-log-group --log-group-name /aws/eks/$PROJECT_NAME-cluster/cluster
fi

##################################################
##########         Analytics         #############
##################################################

if [ "$DELETE_ANALYTICS" = "TRUE" ]; then
    . ./set_analytics_env-vars.sh

    . ./delete_cicd.sh # ./create_cicd.sh
fi

##################################################
##########           Query           #############
##################################################

if [ "$DELETE_QUERY" = "TRUE" ]; then
    . ./set_query_env-vars.sh

    . ./delete_cicd.sh # ./create_cicd.sh
fi

##################################################
##########         Consumer          #############
##################################################

if [ "$DELETE_CONSUMER" = "TRUE" ]; then
    . ./set_consumer_env-vars.sh

    . ./delete_cicd.sh # ./create_cicd.sh
fi

##################################################
##########          Website          #############
##################################################

if [ "$DELETE_WEBSITE" = "TRUE" ]; then
    . ./set_react_env-vars.sh

    . ./delete_cicd.sh # ./create_cicd.sh
    . ./delete_react_resources.sh # ./create_react_resources.sh
fi

##################################################
##########          Device           #############
##################################################

if [ "$DELETE_DEVICE" = "TRUE" ]; then
    . ./set_device_env-vars.sh

    . ./delete_cicd.sh # ./create_cicd.sh
    . ./delete_device_resources.sh # ./create_device_resources.sh
fi


##################################################
##########          Common           #############
##################################################

if [ "$DELETE_COMMON" = "TRUE" ]; then
  . ./delete_common_resources.sh
fi

echo "FINISHED!"
