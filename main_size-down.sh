#!/bin/sh

ARR_NODES=$(kubectl get nodes -o json | jq '.items[] | select ( .spec.taints != null ) | .metadata.name' |  tr -d '" ,')

ARR_KEYS=$(kubectl get nodes -o json | jq '.items[] | select ( .spec.taints != null ) | .spec.taints[] | select ( .effect == "NoSchedule" and .value == "true" ) | .key' |  tr -d '" ,')

echo "Removing taints"

if [ -z "$ARR_NODES" ] || [ -z "$ARR_KEYS" ]; then

  echo "No nodes found"

else

  echo "$ARR_NODES" | tr ' ' '\n' | while read item1; do
    NODE_NAME="$item1"
    echo "NODE_NAME=$NODE_NAME";

    echo "$ARR_KEYS" | tr ' ' '\n' | while read item2; do
      TAINT_KEY="$item2"
      echo "TAINT_KEY=$TAINT_KEY";
      kubectl taint no $NODE_NAME $TAINT_KEY=true:NoSchedule-
    done
  done
fi

#kubectl get deploy -o json | jq '.items[] | select ( .spec.replicas > 1 ) | {name: .metadata.name, namespace: .metadata.namespace}'
# ARR_RS=$(kubectl get deploy -o json | jq '.items[] | select ( .spec.replicas > 1 ) | .metadata.name' |  tr -d '" ,')

# echo "Scaling down replicaSets"
# echo "$ARR_RS" | tr ' ' '\n' | while read item3; do
#   REPLICA_SET="$item3"
#   echo "REPLICA_SET=$REPLICA_SET";

#   ARR_RS_NAME=$(kubectl get rs -o=custom-columns=NAME:.metadata.name | grep "$REPLICA_SET")
#   echo "$ARR_RS_NAME" | tr ' ' '\n' | while read item4; do
#     REPLICA_SET_NAME="$item4"
#     echo "REPLICA_SET_NAME=$REPLICA_SET_NAME";
#     kubectl scale --replicas=1 rs/$REPLICA_SET_NAME
#     --min=10 --max=15
#   done
  
# done

kubectl scale --replicas=1 -f ./eks/devices-extreme_deployment.yml
#kubectl scale --replicas=1 -f ./eks/redisearch-performance-analytics-py_service.yml
kubectl scale --replicas=1 -f ./eks/redisearch-query_service.yml
kubectl scale --replicas=1 -f ./eks/sqsconsumer-toredisearch-js_deployment.yml
kubectl scale --replicas=1 -f ./eks/ingress/echo-app-service.yaml
#kubectl scale --replicas=1 -f ./eks/redisearch_service.yml
kubectl scale --replicas=1 deploy/kubernetes-ingress-default-backend -n haproxy-controller
kubectl scale --replicas=1 deploy/kubernetes-ingress -n haproxy-controller
kubectl scale --replicas=1 deploy/coredns -n kube-system
