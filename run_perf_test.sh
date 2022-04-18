#!/bin/sh

DELETE_REDISEARCH="FALSE"
DELETE_CONSUMER="FALSE"
DEPLOY_REDISEARCH="FALSE"
DEPLOY_CONSUMER="FALSE"
FLUSH_DATA="TRUE"
START_TEST="TRUE"
GET_RESULTS="TRUE"
YML_REDIDEARCH=eks/tmp_redisearch_service.yml
YML_CONSUMER=eks/tmp_sqsconsumers.yml
YML_DEVICE=eks/tmp_devices-extreme_deployment.yml
MAX_TIME=120


create_deployment()
{
  NAME=$1
  APP=$2
  WAIT=$3
  YML=$4

  echo "Apply $NAME started"
  echo "Calling kubectl apply -f $YML"
  kubectl apply -f $YML

  if [ "$WAIT" = "TRUE" ]; then
    echo "Apply request sent, waiting"
    kubectl wait pods -n default -l app=$APP --for condition=Ready --timeout=60s
    echo "Apply request completed, finished waiting"
  fi

  echo "Apply $NAME completed"
  echo ""
}

delete_deployment()
{
  NAME=$1
  APP=$2
  WAIT=$3
  YML=$4

  echo "Delete $NAME started"

  CMD_OUTPUT=$(kubectl get deploy | grep $NAME)
  if [ ! -z "$CMD_OUTPUT" ]; then
    echo "Calling kubectl delete -f $YML"
    kubectl delete -f $YML

    if [ "$WAIT" = "TRUE" ]; then
      echo "Delete request sent, waiting"
      kubectl wait pods -n default -l app=$APP --for condition=delete --timeout=60s
      echo "Delete request completed, finished waiting"
    fi
  fi
  echo "Delete $NAME completed"
  echo ""
}


if [ "$DELETE_REDISEARCH" = "TRUE" ]; then
  delete_deployment redisearch redisearch "TRUE" $YML_REDIDEARCH
fi

if [ "$DELETE_CONSUMER" = "TRUE" ]; then
  delete_deployment lafleet-consumers consumers "TRUE" $YML_CONSUMER
fi

if [ "$DEPLOY_REDISEARCH" = "TRUE" ]; then
  create_deployment redisearch redisearch-app "TRUE" $YML_REDIDEARCH
  sleep 5
fi

if [ "$DEPLOY_REDISEARCH" = "TRUE" ] || [ "$FLUSH_DATA" = "TRUE" ]; then
  echo "Start flushing data from redisearch"
  POD_NAME=$(kubectl get pods -o json | jq '.items[] | select(.spec.containers[0].name == "redisearch") | .metadata.name' | tr -d '"')
  INDEX_H3="FT.CREATE topic-h3-idx ON HASH PREFIX 1 DEVLOC: SCHEMA topic TEXT h3r0 TAG h3r1 TAG h3r2 TAG h3r3 TAG h3r4 TAG h3r5 TAG h3r6 TAG h3r7 TAG h3r8 TAG h3r9 TAG h3r10 TAG h3r11 TAG h3r12 TAG h3r13 TAG h3r14 TAG h3r15 TAG dts NUMERIC batt NUMERIC fv TEXT"
  INDEX_LOC="FT.CREATE topic-lnglat-idx ON HASH PREFIX 1 DEVLOC: SCHEMA topic TEXT lnglat GEO dts NUMERIC batt NUMERIC fv TEXT"

  # Note: do not quote the INDEX env var
  kubectl exec $POD_NAME -- redis-cli "FLUSHALL"
  echo "Start creating redisearch indexes"
  kubectl exec $POD_NAME -- redis-cli $INDEX_H3
  kubectl exec $POD_NAME -- redis-cli $INDEX_LOC
  echo "Finished creating redisearch indexes"
  echo ""
fi

if [ "$DEPLOY_CONSUMER" = "TRUE" ]; then
  create_deployment lafleet-consumers consumers-app "TRUE" $YML_CONSUMER
fi


if [ "$START_TEST" = "TRUE" ]; then
  echo "Starting test"
  sleep 5
  DEV_INT=$(cat $YML_DEVICE | yq '.spec.template.spec.containers[0].env[] | select (.name == "INTERVAL") | .value')
  DEV_CNT=$(cat $YML_DEVICE | yq '.spec.template.spec.containers[0].env[] | select (.name == "COUNT") | .value')
  TIME=$(($DEV_INT * $DEV_CNT / 1000))
  echo "Expected time to complete: $TIME seconds (0 means infinite)"
  echo "Maximum time allowed is: $MAX_TIME seconds"

  create_deployment devices devices "TRUE" $YML_DEVICE

  if [ "$TIME" = "0" ]; then
    echo "Sleeping: $MAX_TIME seconds"
    sleep $MAX_TIME
  elif [ $TIME -gt $MAX_TIME ]; then
    echo "Sleeping: $MAX_TIME seconds"
    sleep $MAX_TIME
  else
    WAIT_TIME=$(($TIME - 20))
    echo "Sleeping: $WAIT_TIME seconds (shorter than $TIME to avoid restarts)"
    sleep $WAIT_TIME
  fi

  delete_deployment devices devices "FALSE" $YML_DEVICE
fi

if [ "$GET_RESULTS" = "TRUE" ]; then
  NODESELECTOR='{ "apiVersion": "v1", "spec": { "template": { "spec": { "nodeSelector": { "nodegroup-type": "backend-standard" } } } } }'
  CMD_OUTPUT=$(kubectl get po | grep curl)
  if [ -z "$CMD_OUTPUT" ]; then
    kubectl run curl --image=radial/busyboxplus:curl -i --rm --tty --overrides="$NODESELECTOR"
    kubectl wait pods -n default -l run=curl --for condition=Ready --timeout=60s
  fi
  kubectl exec curl -- curl -s -X POST -H "Content-Type: text/html" http://analytics-service/devices/stats
fi
