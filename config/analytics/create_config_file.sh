#!/bin/sh

ENV_PROD_FILENAME=".env.production"
VALUES_CFG="./config/analytics/$ENV_PROD_FILENAME"_template
aws s3 cp $VALUES_CFG s3://$S3_OBJECT_STORE/config/$DST_SOURCECODE_REPO_NAME/$ENV_PROD_FILENAME
