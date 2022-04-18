#!/bin/sh

echo "Calling ./s3/create_s3_bucket_react_web.sh"
S3_BUCKET_NAME_TO_CREATE=$S3_REACT_WEB
. ./s3/create_s3_bucket.sh

echo "Calling ./cdn/create_cloudfront.sh >> $ECHO_SUFFIX (can take a while)" yn
. ./cdn/create_cloudfront.sh


ENV_PROD_FILENAME=".env.production"
REACT_ENV_PROD_CFG=tmp_react.env.production-values
DIST_DOMAIN_NAME=$(aws cloudfront get-distribution --id $DIST_ID | jq '.Distribution.DomainName' | tr -d '"')
if [ -f $REACT_ENV_PROD_CFG ]; then rm $REACT_ENV_PROD_CFG; fi
echo "CDN_DIST_ID=$DIST_ID" > $REACT_ENV_PROD_CFG
echo "S3_WEB_BUCKET=$S3_REACT_WEB" >> $REACT_ENV_PROD_CFG
echo "GET_CNT_FCN=https://$DIST_DOMAIN_NAME/query/h3/aggregate/device-count" >> $REACT_ENV_PROD_CFG
echo "MAPBOX_TOKEN=$MAPBOX_TOKEN" >> $REACT_ENV_PROD_CFG
echo "MAPBOX_STYLE_LIGHT=mapbox://styles/mapbox/light-v9" >> $REACT_ENV_PROD_CFG
echo "MAPBOX_STYLE_BASIC=mapbox://styles/mapbox/basic-v9" >> $REACT_ENV_PROD_CFG
aws s3 cp ./$REACT_ENV_PROD_CFG s3://$S3_OBJECT_STORE/config/$DST_SOURCECODE_REPO_NAME/$ENV_PROD_FILENAME
