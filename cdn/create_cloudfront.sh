#!/bin/sh

CDN_CALLER_REFERENCE=$S3_REACT_WEB.s3.$AWS_REGION_VALUE.amazonaws.com
OAI_CALLER_REFERENCE=access-identity-$CDN_CALLER_REFERENCE

# lafleet-react-web-<aws_account_id>.s3.<aws_region>.amazonaws.com
JQF=".DistributionList.Items[] | select (.Origins.Items[0].Id == \"$CDN_CALLER_REFERENCE\") | .Id"
DIST_ID=$(aws cloudfront list-distributions | jq "$JQF" | tr -d '"')

if [ -z "$DIST_ID" ]; then
 
   echo "Creating new CloudFront distribution"
   OAI_ID=$(aws cloudfront create-cloud-front-origin-access-identity \
     --cloud-front-origin-access-identity-config \
     CallerReference="$OAI_CALLER_REFERENCE",Comment="$OAI_CALLER_REFERENCE" \
     --query "CloudFrontOriginAccessIdentity.Id" --output text)
   CDN_ORIGIN_ACCESS_IDENTITY=origin-access-identity/cloudfront/$OAI_ID

   TEMPLATE_JSON=./cdn/distribution_config.json
   VALUES_JSON=./cdn/tmp_distribution_config-values.json
   cp $TEMPLATE_JSON $VALUES_JSON

   sed -i 's@CDN_CALLER_REFERENCE@'"$CDN_CALLER_REFERENCE"'@g' $VALUES_JSON
   sed -i 's@CDN_ORIGIN_ACCESS_IDENTITY@'"$CDN_ORIGIN_ACCESS_IDENTITY"'@g' $VALUES_JSON
   sed -i 's@AWS_REGION_VALUE@'"$AWS_REGION_VALUE"'@g' $VALUES_JSON

   DIST_ID=$(aws cloudfront create-distribution --distribution-config file://$VALUES_JSON | jq '.Distribution.Id' | tr -d '"')
   aws cloudfront wait distribution-deployed --id $DIST_ID

else

   echo "CloudFront distribution $DIST_ID will be re-used"

fi
