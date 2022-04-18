#!/bin/sh

CREATE_APPS="TRUE"


##################################################
##########          Common           #############
##################################################

echo "Common >> Calling ./set_common_env-vars.sh"
. ./set_common_env-vars.sh

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
