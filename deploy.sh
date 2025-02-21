#!/bin/bash

######################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. #
# SPDX-License-Identifier: MIT-0                                     #
######################################################################

# Build and package the Lambda function
cd ./hook-lambda && npm install && npm run package

# Create S3 bucket if it doesn't exist
REGION=$(aws configure get region)
BUCKET_NAME="validation-lambda-deployments-$(aws sts get-caller-identity --query Account --output text)"
aws s3api create-bucket --bucket $BUCKET_NAME --create-bucket-configuration LocationConstraint=${REGION} 2>/dev/null || true

# Upload Lambda package to S3
aws s3 cp hook-lambda.zip s3://$BUCKET_NAME/hook-lambda.zip

# Deploy CloudFormation stack
aws cloudformation deploy \
  --template-file ../template.yml \
  --stack-name lambda-lang-version-compliance \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    DeploymentBucket=$BUCKET_NAME
