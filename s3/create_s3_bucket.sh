#!/bin/sh

bucketstatus=$(aws s3 ls "s3://$S3_BUCKET_NAME_TO_CREATE" 2>&1)
if echo "${bucketstatus}" | grep -q 'NoSuchBucket';
then
  echo "Bucket doesn't exist so will be created";
  aws s3 mb s3://$S3_BUCKET_NAME_TO_CREATE
elif echo "${bucketstatus}" | grep 'Forbidden';
then
  echo "Bucket s3://$S3_BUCKET_NAME_TO_CREATE exists but not owned"
elif echo "${bucketstatus}" | grep 'Bad Request';
then
  echo "Bucket name s3://$S3_BUCKET_NAME_TO_CREATE specified is less than 3 or greater than 63 characters"
else
  echo "Bucket s3://$S3_BUCKET_NAME_TO_CREATE owned and already exists";
fi
