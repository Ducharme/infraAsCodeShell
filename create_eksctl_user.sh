#!/bin/sh

aws iam create-user --user-name $AWS_ADMIN_USER
aws iam attach-user-policy --user-name $AWS_ADMIN_USER --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

AWS_ADMIN_PASS=$(openssl rand -base64 15)
aws iam create-login-profile --user-name $AWS_ADMIN_USER --password $AWS_ADMIN_PASS --no-password-reset-required
aws iam create-access-key --user-name $AWS_ADMIN_USER > $AWS_ADMIN_USER_access-key.json
AWS_ADMIN_ARN=$(aws iam get-user --user-name $AWS_ADMIN_USER --query User.Arn | tr -d '"')
