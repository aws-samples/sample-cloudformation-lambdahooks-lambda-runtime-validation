#!/bin/bash

######################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. #
# SPDX-License-Identifier: MIT-0                                     #
######################################################################

# Get the S3 bucket name using the same logic as the deployment script
BUCKET_NAME="validation-lambda-deployments-$(aws sts get-caller-identity --query Account --output text)"

# Delete the CloudFormation stack
echo "Deleting CloudFormation stack 'lambda-lang-version-compliance'..."
aws cloudformation delete-stack --stack-name lambda-lang-version-compliance

# Wait for the stack to be deleted completely
echo "Waiting for stack deletion to complete..."
aws cloudformation wait stack-delete-complete --stack-name lambda-lang-version-compliance

if [ $? -eq 0 ]; then
    echo "Stack 'lambda-lang-version-compliance' has been successfully deleted"
    
    # Empty and delete the S3 bucket
    echo "Emptying S3 bucket '$BUCKET_NAME'..."
    aws s3 rm s3://$BUCKET_NAME --recursive
    
    echo "Deleting S3 bucket '$BUCKET_NAME'..."
    aws s3api delete-bucket --bucket $BUCKET_NAME
    
    echo "Cleanup completed successfully"
else
    echo "Error deleting stack 'lambda-lang-version-compliance'. Please check the AWS Console for details"
fi
