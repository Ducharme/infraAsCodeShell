#!/bin/sh

aws ecr create-repository --repository-name $IMAGE_REPO_NAME_VALUE --image-tag-mutability MUTABLE \
  --image-scanning-configuration scanOnPush=false --encryption-configuration encryptionType=AES256
