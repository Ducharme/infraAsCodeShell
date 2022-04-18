#!/bin/sh

echo "Calling ./s3/create_s3_bucket.sh for $CODEBUILD_ARTIFACT"
S3_BUCKET_NAME_TO_CREATE=$CODEBUILD_ARTIFACT
. ./s3/create_s3_bucket.sh

echo "Calling ./s3/create_s3_bucket.sh for $CODEPIPELINE_ARTIFACT"
S3_BUCKET_NAME_TO_CREATE=$CODEPIPELINE_ARTIFACT
. ./s3/create_s3_bucket.sh

echo "Calling ./s3/create_s3_bucket.sh for $S3_OBJECT_STORE"
S3_BUCKET_NAME_TO_CREATE=$S3_OBJECT_STORE
. ./s3/create_s3_bucket.sh

echo "Calling ./sqs/create_queue.sh"
. ./sqs/create_queue.sh
