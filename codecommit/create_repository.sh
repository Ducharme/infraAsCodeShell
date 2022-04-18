#!/bin/sh

aws codecommit create-repository --repository-name "$DST_SOURCECODE_REPO_NAME" --repository-description "$DST_SOURCECODE_REPO_DESC"

git clone https://github.com/Ducharme/$SRC_SOURCECODE_REPO_NAME
cd $SRC_SOURCECODE_REPO_NAME
git push https://git-codecommit.$AWS_REGION_VALUE.amazonaws.com/v1/repos/$DST_SOURCECODE_REPO_NAME
cd ..
rm -rf $SRC_SOURCECODE_REPO_NAME
