#!/bin/sh

echo "Calling ./codecommit/create_repository.sh"
. ./codecommit/create_repository.sh # No dependency
echo "Calling ./ecr/create_repository.sh"
. ./ecr/create_repository.sh # No dependency
echo "Calling ./logs/create_codebuild_log_group.sh"
. ./logs/create_codebuild_log_group.sh # No dependency
echo "Calling ./iam/create_codebuild_role.sh"
. ./iam/create_codebuild_role.sh # Dependency: log-group, artifact-location (s3), codecommit, codepipeline-*
echo "Calling ./codebuild/create_project.sh"
. ./codebuild/create_project.sh # Dependency: codecommit-repo, codebuild-role-arn
echo "Calling ./iam/create_codepipeline_role.sh"
. ./iam/create_codepipeline_role.sh
sleep 10s # Waits 5 seconds otherwise pipelinemight faildu to rolenot being ready
echo "Calling ./codepipeline/create_pipeline.sh"
. ./codepipeline/create_pipeline.sh # Dependency: codecommit, codebuild, artifact-location (s3)
