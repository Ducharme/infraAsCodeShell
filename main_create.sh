#!/bin/sh

CREATE_COMMON="TRUE"
CREATE_DEVICE="TRUE"
CREATE_WEBSITE="TRUE"
CREATE_CONSUMER="TRUE"
CREATE_QUERY="TRUE"
CREATE_ANALYTICS="TRUE"


##################################################
##########          Common           #############
##################################################

echo "Common >> Calling ./set_common_env-vars.sh"
. ./set_common_env-vars.sh

if [ "$CREATE_COMMON" = "TRUE" ]; then
  echo "Common >> Calling ./create_common_resources.sh"
  . ./create_common_resources.sh
fi

##################################################
##########          Device           #############
##################################################

if [ "$CREATE_DEVICE" = "TRUE" ]; then
  echo "Device >> Calling ./set_device_env-vars.sh"
  . ./set_device_env-vars.sh
  echo "Device >> Calling ./create_device_resources.sh"
  . ./create_device_resources.sh
  echo "Device >> Calling ./create_cicd.sh"
  . ./create_cicd.sh
  echo "Device >> Calling ./config/device/create_config_file.sh"
  . ./config/device/create_config_file.sh
fi

##################################################
##########          Website          #############
##################################################

if [ "$CREATE_WEBSITE" = "TRUE" ]; then
  echo "Website >> Calling ./set_react_env.sh"
  . ./set_react_env-vars.sh
  echo "Website >> Calling ./create_react_resources.sh"
  . ./create_react_resources.sh
  echo "Website >> Calling ./create_cicd.sh"
  . ./create_cicd.sh
  echo "Website >> Calling ./udpate_react_resources.sh"
  . ./udpate_react_resources.sh
fi

##################################################
##########          Consumer         #############
##################################################

if [ "$CREATE_CONSUMER" = "TRUE" ]; then
  echo "Consumer >> Calling ./set_consumer_env-vars.sh"
  . ./set_consumer_env-vars.sh
  echo "Consumer >> Calling ./create_cicd.sh"
  . ./create_cicd.sh
  echo "Consumer >> Calling ./config/consumer/create_config_file.sh"
  . ./config/consumer/create_config_file.sh
fi

##################################################
##########           Query           #############
##################################################

if [ "$CREATE_QUERY" = "TRUE" ]; then
  echo "Query >> Calling ./set_query_env-vars.sh"
  . ./set_query_env-vars.sh
  echo "Query >> Calling ./create_cicd.sh"
  . ./create_cicd.sh
fi

##################################################
##########         Analytics         #############
##################################################

if [ "$CREATE_ANALYTICS" = "TRUE" ]; then
  echo "Analytics >> Calling ./set_analytics_env-vars.sh"
  . ./set_analytics_env-vars.sh
  echo "Analytics >> Calling ./create_cicd.sh"
  . ./create_cicd.sh
  echo "Analytics >> Calling ./config/analytics/create_config_file.sh"
  . ./config/analytics/create_config_file.sh
fi

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
