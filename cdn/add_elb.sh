#!/bin/sh

echo "Calling cloudfront update-distribution (can take a while)"
CDN_CALLER_REFERENCE=$S3_REACT_WEB.s3.$AWS_REGION_VALUE.amazonaws.com
JQF=".DistributionList.Items[] | select(.Origins.Items[0].Id == \"$CDN_CALLER_REFERENCE\") | .Id"
DIST_ID=$(aws cloudfront list-distributions | jq "$JQF" | tr -d '"')

CURRENT_CONFIG_JSON=./cdn/tmp_current_dist_config.json
aws cloudfront get-distribution-config --id $DIST_ID > $CURRENT_CONFIG_JSON

ELB_DNS_NAME=$(kubectl get svc -n haproxy-controller -o json | jq '.items[] | select( .spec.type == "LoadBalancer" ) | .status.loadBalancer.ingress[0].hostname' | tr -d '"')
ELB_MATCH=$(cat $CURRENT_CONFIG_JSON | jq ".DistributionConfig.Origins.Items[] | select ( .Id == \"$ELB_DNS_NAME\" ) | .Id ")

if [ -z "$ELB_MATCH" ]; then

  DIST_ETAG=$(cat $CURRENT_CONFIG_JSON | jq ".ETag" | tr -d '"')

  # Add ELB Origin

  TEMPLATE_ORIGIN_JSON=./cdn/cdn-add-elb-origin.json
  NEW_CONFIG_WITH_ELB_TMP_JSON=./cdn/tmp_new_dist_config_with_elb_origin_tmp.json
  NEW_CONFIG_WITH_ELB_JSON=./cdn/tmp_new_dist_config_with_elb_origin.json
  jq --argjson neworigin "$(cat $TEMPLATE_ORIGIN_JSON)" '.DistributionConfig.Origins.Items += [$neworigin]' $CURRENT_CONFIG_JSON > $NEW_CONFIG_WITH_ELB_TMP_JSON
  ORIGIN_COUNT=$(jq '.DistributionConfig.Origins.Items | length' $NEW_CONFIG_WITH_ELB_TMP_JSON)
  jq ".DistributionConfig.Origins.Quantity=$ORIGIN_COUNT" $NEW_CONFIG_WITH_ELB_TMP_JSON > $NEW_CONFIG_WITH_ELB_JSON

  # Add 2 ELB Cache Behaviors

  TEMPLATE_CACHEBEHAVIOR_JSON=./cdn/cdn-add-elb-cachebehavior.json

  NEW_CONFIG_WITH_ELB_CB_QUERY_TMP_JSON=./cdn/tmp_new_dist_config_with_elb_cb_query_tmp.json
  jq --argjson newcachebehavior "$(cat $TEMPLATE_CACHEBEHAVIOR_JSON)" '.DistributionConfig.CacheBehaviors.Items += [$newcachebehavior]' $NEW_CONFIG_WITH_ELB_JSON > $NEW_CONFIG_WITH_ELB_CB_QUERY_TMP_JSON
  PATH_PATTERN_QUERY='/query/*'
  sed -i 's@PATH_PATTERN@'"$PATH_PATTERN_QUERY"'@g' $NEW_CONFIG_WITH_ELB_CB_QUERY_TMP_JSON

  NEW_CONFIG_WITH_ELB_CB_ANALYTICS_TMP_JSON=./cdn/tmp_new_dist_config_with_elb_cb_analytics_tmp.json
  jq --argjson newcachebehavior "$(cat $TEMPLATE_CACHEBEHAVIOR_JSON)" '.DistributionConfig.CacheBehaviors.Items += [$newcachebehavior]' $NEW_CONFIG_WITH_ELB_CB_QUERY_TMP_JSON > $NEW_CONFIG_WITH_ELB_CB_ANALYTICS_TMP_JSON
  PATH_PATTERN_ANALYTICS='/analytics/*'
  sed -i 's@PATH_PATTERN@'"$PATH_PATTERN_ANALYTICS"'@g' $NEW_CONFIG_WITH_ELB_CB_ANALYTICS_TMP_JSON

  NEW_CONFIG_WITH_ELB_CBS_JSON=./cdn/tmp_new_dist_config_with_elb_cbs.json
  CACHEBEHAVIOR_COUNT=$(jq '.DistributionConfig.CacheBehaviors.Items | length' $NEW_CONFIG_WITH_ELB_CB_ANALYTICS_TMP_JSON)
  jq ".DistributionConfig.CacheBehaviors.Quantity=$CACHEBEHAVIOR_COUNT" $NEW_CONFIG_WITH_ELB_CB_ANALYTICS_TMP_JSON > $NEW_CONFIG_WITH_ELB_CBS_JSON

  # Extract DistributionConfig

  NEW_CONFIG_JSON_WITH_ELB_TMP=./cdn/tmp_new_dist_config_with_elb_tmp.json
  cat $NEW_CONFIG_WITH_ELB_CBS_JSON | jq '.DistributionConfig' > $NEW_CONFIG_JSON_WITH_ELB_TMP
  VALUES_JSON=./cdn/tmp_new_dist_config-values.json
  cp $NEW_CONFIG_JSON_WITH_ELB_TMP $VALUES_JSON
  sed -i 's@ELB_DNS_NAME@'"$ELB_DNS_NAME"'@g' $VALUES_JSON

  DIST_UPDATE=$(aws cloudfront update-distribution --id $DIST_ID --if-match $DIST_ETAG --distribution-config file://$VALUES_JSON)

else

   echo "CloudFront distribution $DIST_ID is already up to date with ELB $ELB_DNS_NAME"

fi
