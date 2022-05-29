
# Resources created by the scripts

Services used: EC2, EKS, S3, SQS, CodeCommit, CodeBuild, CodePipeline, CloudFront, ELB, CloudWatch, IAM

## Entry point

```
sh ./main_create.sh
```


### Common resources

./s3/create_s3_bucket_codebuild_artifact.sh
> S3 bucket lafleet-codebuild-artifacts-repo-<aws_account_id>

./s3/create_s3_bucket_codepipeline_artifact.sh
> S3 bucket lafleet-codepipeline-artifacts-repo-<aws_account_id>

./s3/create_s3_bucket_object_store.sh
> S3 bucket lafleet-object-store-<aws_account_id>

./sqs/create_queue.sh
> SQS queue lafleet-device-messages


### Devices resources (create_device_resources.sh)

./iot/create_keys_and_certificate.sh
> Create AWS IoT Certificates 2c140cc28******(64 chars long) and set it Active
> Create file certificate-id.txt with Certificate ID inside (also called the principal)
> Copy certificate.pem.crt to s3://lafleet-object-store-<aws_account_id>/certs
> Copy public.pem.key to s3://lafleet-object-store-<aws_account_id>/certs
> Copy private.pem.key to s3://lafleet-object-store-<aws_account_id>/certs
> Copy certificate-id.txt to s3://lafleet-object-store-<aws_account_id>/certs
> Copy root-ca.crt to s3://lafleet-object-store-<aws_account_id>/certs

./iot/create_thing.sh # Set ENV VARS used later
> Create thing mockIotGpsDeviceAwsSdkV2

./iot/create_iot_policy.sh
> Create AWS IoT policy lafleet-device-policy
> Register Thing to the policy and attach certificates created before

./logs/create_cw_iot_device_logs.sh
> Create Log Group /lafleet/iot/lafleet-mockIotGpsDeviceAwsSdkV2-logs

./logs/create_cw_iot_device_error_logs.sh
> Create Log Group /lafleet/iot/lafleet-mockIotGpsDeviceAwsSdkV2-error-logs

./iam/create_cw_logs_write_logs_role.sh
> Create policy lafleet-iot-cw-write-mockIotGpsDeviceAwsSdkV2-logs-policy
> Create role lafleet-iot-cw-write-mockIotGpsDeviceAwsSdkV2-logs-role
> Attach new policy to the new role

./iam/create_cw_logs_write_error_logs_role.sh
> Create policy lafleet-iot-cw-write-mockIotGpsDeviceAwsSdkV2-error-logs-policy
> Create role lafleet-iot-cw-write-mockIotGpsDeviceAwsSdkV2-error-logs-role
> Attach new policy to the new role

./iam/create_iot_rule_sqs_role.sh
> Create policy lafleet-mockIotGpsDeviceAwsSdkV2-sendToSqsRule-policy
> Create role lafleet-mockIotGpsDeviceAwsSdkV2-sendToSqsRule-role
> Attach new policy to the new role

./iot/create_topic_rule.sh
> Create AWS IoT Rule sendToSqsRule


### Devices CICD (create_cicd.sh)

./codecommit/create_repository.sh
> Create CodeCommit repository mockIotGpsDeviceAwsSdkV2

./ecr/create_repository.sh # No dependency
> Create ECR repository mock-iot-gps-device-awssdkv2 for docker images

./logs/create_codebuild_log_group.sh
> Create Log Group /lafleet/codebuild/mockIotGpsDeviceAwsSdkV2

./iam/create_codebuild_role.sh
> Create policy lafleet-codebuild-mockIotGpsDeviceAwsSdkV2-policy
> Create role lafleet-codebuild-mockIotGpsDeviceAwsSdkV2-role
> Attach new policy to the new role
> Create policy lafleet-codebuild-react-frontend-cdn-createinvalidation-policy
> Attach new policy to the new role

./codebuild/create_project.sh
> Create CodeBuild project mockIotGpsDeviceAwsSdkV2

. ./iam/create_codepipeline_role.sh
> Create policy lafleet-codepipeline-mockIotGpsDeviceAwsSdkV2-policy
> Create role lafleet-codepipeline-mockIotGpsDeviceAwsSdkV2-role
> Attach new policy to the new role

./codepipeline/create_pipeline.sh # Dependency: codecommit, codebuild, artifact-location (s3)
> Create CodePipeline mockIotGpsDeviceAwsSdkV2


# To be continued

...
