#!/bin/sh


#./codepipeline/create_pipeline.sh
echo aws codepipeline delete-pipeline --name $CODEBUILD_NAME
aws codepipeline delete-pipeline --name $CODEBUILD_NAME

# ./iam/create_codepipeline_role.sh
IAM_ROLE_NAME=$PROJECT_NAME-codepipeline-$CODEBUILD_NAME-role
IAM_POLICY_NAME=$PROJECT_NAME-codepipeline-$CODEBUILD_NAME-policy
echo ". ./iam/delete_role_policy.sh (create_codepipeline_role)"
. ./iam/delete_role_policy.sh

# ./codebuild/create_project.sh
echo "aws codebuild delete-project --name $CODEBUILD_NAME"
aws codebuild delete-project --name $CODEBUILD_NAME

# ./iam/create_codebuild_role.sh
IAM_ROLE_NAME=$PROJECT_NAME-codebuild-$CODEBUILD_NAME-role
IAM_POLICY_NAME=$PROJECT_NAME-codebuild-$CODEBUILD_NAME-policy
echo ". ./iam/delete_role_policy.sh (create_codebuild_role)"
AWS_ECR_POL_ARN=arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
aws iam detach-role-policy --role-name $IAM_ROLE_NAME --policy-arn $AWS_ECR_POL_ARN
. ./iam/delete_role_policy.sh

# ./logs/create_codebuild_log_group.sh
echo "aws logs delete-log-group --log-group-name /$PROJECT_NAME/codebuild/$CODEBUILD_NAME"
aws logs delete-log-group --log-group-name /$PROJECT_NAME/codebuild/$CODEBUILD_NAME

# ./ecr/create_repository.sh
echo "aws ecr delete-repository --repository-name $IMAGE_REPO_NAME_VALUE --force"
aws ecr delete-repository --repository-name $IMAGE_REPO_NAME_VALUE --force

# ./codecommit/create_repository.sh
#aws codecommit delete-repository --repository-name $DST_SOURCECODE_REPO_NAME
