#!/bin/bash

######################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. #
# SPDX-License-Identifier: MIT-0                                     #
######################################################################

# Delete the CloudFormation stack
aws cloudformation delete-stack --stack-name lambda-sample

# Wait for the stack to be deleted completely
echo "Waiting for stack deletion to complete..."
aws cloudformation wait stack-delete-complete --stack-name lambda-sample

if [ $? -eq 0 ]; then
    echo "Stack 'lambda-sample' has been successfully deleted"
else
    echo "Error deleting stack 'lambda-sample'. Please check the AWS Console for details"
fi
