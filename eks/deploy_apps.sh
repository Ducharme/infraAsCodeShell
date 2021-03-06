#!/bin/sh

export EKSCTL_ENABLE_CREDENTIAL_CACHE=1
EKSCTL_ENABLE_CREDENTIAL_CACHE=1
export KUBECONFIG=~/.kube/eksctl/clusters/lafleet-cluster
KUBECONFIG=~/.kube/eksctl/clusters/lafleet-cluster

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
#helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
helm repo update
#helm install --generate-name prometheus-community/prometheus


##########   set_common_env-vars.sh   ##########

. ./set_common_env-vars.sh

########## eks/redisearch_service.yml ##########

kubectl apply -f ./eks/redisearch_service.yml

n=0
until [ "$n" -ge 10 ]
do
  POD_STATUS=$(kubectl get pods -o json | jq '.items[] | select(.spec.containers[0].name == "redisearch") | .status.phase' | tr -d '"')
  if [ "$POD_STATUS" = "Running" ]; then
    break
  fi
  n=$((n+1)) 
  sleep 5
done

POD_NAME=$(kubectl get pods -o json | jq '.items[] | select(.spec.containers[0].name == "redisearch") | .metadata.name' | tr -d '"')
INDEX_H3="FT.CREATE topic-h3-idx ON HASH PREFIX 1 DEVLOC: SCHEMA topic TEXT h3r0 TAG h3r1 TAG h3r2 TAG h3r3 TAG h3r4 TAG h3r5 TAG h3r6 TAG h3r7 TAG h3r8 TAG h3r9 TAG h3r10 TAG h3r11 TAG h3r12 TAG h3r13 TAG h3r14 TAG h3r15 TAG dts NUMERIC batt NUMERIC fv TEXT"
INDEX_LOC="FT.CREATE topic-lnglat-idx ON HASH PREFIX 1 DEVLOC: SCHEMA topic TEXT lnglat GEO dts NUMERIC batt NUMERIC fv TEXT"

# Note: do not quote the INDEX env var
kubectl exec $POD_NAME -- redis-cli $INDEX_H3
kubectl exec $POD_NAME -- redis-cli $INDEX_LOC


########## eks/redisearch-performance-analytics-py_service.yml ##########

. ./set_analytics_env-vars.sh

IMAGE_VALUE=$AWS_ACCOUNT_ID_VALUE.dkr.ecr.$AWS_REGION_VALUE.amazonaws.com/$IMAGE_REPO_NAME_VALUE:latest

TEMPLATE_YAML=./eks/redisearch-performance-analytics-py_service_template.yml
VALUES_YAML=./eks/redisearch-performance-analytics-py_service.yml
cp $TEMPLATE_YAML $VALUES_YAML

sed -i 's@IMAGE_VALUE@'"$IMAGE_VALUE"'@g' $VALUES_YAML

kubectl apply -f ./eks/redisearch-performance-analytics-py_service.yml


########## eks/sqsconsumer-toredisearch-js_deployment.yml ##########

. ./set_consumer_env-vars.sh

IMAGE_VALUE=$AWS_ACCOUNT_ID_VALUE.dkr.ecr.$AWS_REGION_VALUE.amazonaws.com/$IMAGE_REPO_NAME_VALUE:latest
SQS_QUEUE_URL=$(aws sqs get-queue-url --queue-name $SQS_QUEUE_NAME --query QueueUrl | tr -d '"')

TEMPLATE_YAML=./eks/sqsconsumer-toredisearch-js_deployment_template.yml
VALUES_YAML=./eks/sqsconsumer-toredisearch-js_deployment.yml
cp $TEMPLATE_YAML $VALUES_YAML

sed -i 's@AWS_REGION_VALUE@'"$AWS_REGION_VALUE"'@g' $VALUES_YAML
sed -i 's@SQS_QUEUE_URL_VALUE@'"$SQS_QUEUE_URL"'@g' $VALUES_YAML
sed -i 's@IMAGE_VALUE@'"$IMAGE_VALUE"'@g' $VALUES_YAML

kubectl apply -f $VALUES_YAML


########## eks/devices-extreme_job.yml ##########

. ./set_device_env-vars.sh

IMAGE_VALUE=$AWS_ACCOUNT_ID_VALUE.dkr.ecr.$AWS_REGION_VALUE.amazonaws.com/$IMAGE_REPO_NAME_VALUE:latest
IOT_ENDPOINT=$(aws iot describe-endpoint --query endpointAddress | tr -d '"')

TEMPLATE_YAML=./eks/devices-extreme_job_template.yml
VALUES_YAML=./eks/devices-extreme_job.yml
cp $TEMPLATE_YAML $VALUES_YAML

sed -i 's@IOT_ENDPOINT@'"$IOT_ENDPOINT"'@g' $VALUES_YAML
sed -i 's@SQS_QUEUE_URL_VALUE@'"$SQS_QUEUE_URL"'@g' $VALUES_YAML
sed -i 's@IMAGE_VALUE@'"$IMAGE_VALUE"'@g' $VALUES_YAML

# kubectl apply -f ./eks/devices-extreme_job.yml
##kubectl apply -f ./eks/devices-slow_deployment.yml
##kubectl apply -f ./eks/devices-extreme_deployment.yml
##kubectl apply -f ./eks/devices-fast_job.yml


########## eks/eks/redisearch-query_deployment.yml ##########

. ./set_query_env-vars.sh

IMAGE_VALUE=$AWS_ACCOUNT_ID_VALUE.dkr.ecr.$AWS_REGION_VALUE.amazonaws.com/$IMAGE_REPO_NAME_VALUE:latest

TEMPLATE_YAML=./eks/redisearch-query_service_template.yml
VALUES_YAML=./eks/redisearch-query_service.yml
cp $TEMPLATE_YAML $VALUES_YAML

sed -i 's@IMAGE_VALUE@'"$IMAGE_VALUE"'@g' $VALUES_YAML

kubectl apply -f $VALUES_YAML

##########   HA Proxy for ingress via ELB on CDN  ##########

# https://www.haproxy.com/documentation/kubernetes/latest/installation/community/aws/

helm repo add haproxytech https://haproxytech.github.io/helm-charts
helm repo update
helm install kubernetes-ingress haproxytech/kubernetes-ingress \
     --create-namespace --namespace haproxy-controller \
     --set controller.service.type=LoadBalancer

