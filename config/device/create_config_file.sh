#!/bin/sh

IOT_ENDPOINT=$(aws iot describe-endpoint --query endpointAddress | tr -d '"')

ENV_PROD_FILENAME=".env.production"
TEMPLATE_CFG="./config/device/$ENV_PROD_FILENAME"_template
VALUES_CFG="./config/device/$ENV_PROD_FILENAME"-values
cp $TEMPLATE_CFG $VALUES_CFG

sed -i 's@IOT_ENDPOINT@'"$IOT_ENDPOINT"'@g' $VALUES_CFG
sed -i 's@THING_TOPIC@'"$THING_TOPIC"'@g' $VALUES_CFG

aws s3 cp $VALUES_CFG s3://$S3_OBJECT_STORE/config/$DST_SOURCECODE_REPO_NAME/$ENV_PROD_FILENAME
