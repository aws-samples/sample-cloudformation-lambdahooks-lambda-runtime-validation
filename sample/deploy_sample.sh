#!/bin/bash

######################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. #
# SPDX-License-Identifier: MIT-0                                     #
######################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Deploy CloudFormation stack
aws cloudformation deploy \
  --template-file $SCRIPT_DIR/lambda_template.yml \
  --capabilities CAPABILITY_IAM \
  --stack-name lambda-sample