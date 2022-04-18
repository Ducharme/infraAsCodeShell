#!/bin/sh

CREATE_KUBERNETES="TRUE"


##################################################
##########          Common           #############
##################################################

echo "Common >> Calling ./set_common_env-vars.sh"
. ./set_common_env-vars.sh

##################################################
##########    Kubernetes Cluster     #############
##################################################

if [ "$CREATE_KUBERNETES" = "TRUE" ]; then
  echo "Calling ./eksctl/create_cluster.sh"
  . ./eksctl/create_cluster.sh
fi

##################################################
##########      Kubernetes Apps      #############
##################################################

if [ "$CREATE_APPS" = "TRUE" ]; then
  echo "Calling ./eks/deploy_apps.sh"
  . ./eks/deploy_apps.sh
  echo "Calling ./cdn/add_elb.sh"
  . ./cdn/add_elb.sh
fi


echo "FINISHED!"
