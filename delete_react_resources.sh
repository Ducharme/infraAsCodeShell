#!/bin/sh

# TODO: Not tested yet

echo "Calling aws cloudfront delete-cloud-front-origin-access-identity"
CDN_CALLER_REFERENCE=$S3_REACT_WEB.s3.$AWS_REGION_VALUE.amazonaws.com

echo "Calling cloudfront update-distribution (can take a while)"
JQF=".DistributionList.Items[] | select(.Origins.Items[0].Id == \"$CDN_CALLER_REFERENCE\") | .Id"
DIST_ID=$(aws cloudfront list-distributions | jq "$JQF" | tr -d '"')
CONFIG_JSON=tmp_distribution-config-$DIST_ID.json
aws cloudfront get-distribution-config --id $DIST_ID | jq '. | .DistributionConfig' > $CONFIG_JSON
sed -i 's@"Enabled": true,@"Enabled": false,@g' $CONFIG_JSON
ETAG=$(aws cloudfront get-distribution-config --id $DIST_ID | jq '.ETag' | tr -d '"')
aws cloudfront update-distribution --id $DIST_ID --if-match $ETAG --distribution-config file://$CONFIG_JSON
aws cloudfront wait distribution-deployed --id $DIST_ID

echo "Calling cloudfront delete-distribution"
ETAG=$(aws cloudfront get-distribution-config --id $DIST_ID | jq '.ETag' | tr -d '"')
aws cloudfront delete-distribution --id $DIST_ID --if-match $ETAG

OAI_CALLER_REFERENCE=access-identity-$CDN_CALLER_REFERENCE
JQF=".CloudFrontOriginAccessIdentityList.Items[] | select(.Comment == \"$OAI_CALLER_REFERENCE\") | .Id"
OAI_ID=$(aws cloudfront list-cloud-front-origin-access-identities | jq "$JQF" | tr -d '"')
ETAG=$(aws cloudfront get-cloud-front-origin-access-identity-config --id $OAI_ID | jq '.ETag' | tr -d '"')
aws cloudfront delete-cloud-front-origin-access-identity --id $OAI_ID --if-match $ETAG
