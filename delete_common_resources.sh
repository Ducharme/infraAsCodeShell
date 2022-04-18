#!/bin/sh


# ./sqs/create_queue.sh
. ./sqs/delete_queue.sh

# ./s3/create_s3_bucket_object_store.sh
S3_BUCKET_NAME_TO_CREATE=$S3_OBJECT_STORE
. ./s3/delete_s3_bucket.sh

# ./s3/create_s3_bucket_codepipeline_artifact.sh
S3_BUCKET_NAME_TO_CREATE=$CODEPIPELINE_ARTIFACT
. ./s3/delete_s3_bucket.sh

# ./s3/create_s3_bucket_codebuild_artifact.sh
S3_BUCKET_NAME_TO_CREATE=$CODEBUILD_ARTIFACT
. ./s3/delete_s3_bucket.sh
