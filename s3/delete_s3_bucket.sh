#!/bin/sh

bucketstatus=$(aws s3 ls "s3://$S3_BUCKET_NAME_TO_CREATE" 2>&1)
if echo "${bucketstatus}" | grep -q 'NoSuchBucket';
then
  echo "Bucket doesn't exist so nothing to do";
else
  echo "Bucket s3://$S3_BUCKET_NAME_TO_CREATE exists so will be deleted";
  aws s3 rm s3://$S3_BUCKET_NAME_TO_CREATE # --force
fi
