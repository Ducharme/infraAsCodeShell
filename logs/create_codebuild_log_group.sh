#!/bin/sh

aws logs create-log-group --log-group-name /$PROJECT_NAME/codebuild/$CODEBUILD_NAME
