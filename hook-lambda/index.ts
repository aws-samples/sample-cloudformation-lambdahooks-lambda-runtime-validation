// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
import { Context, Handler } from 'aws-lambda';
import { ParameterStoreService } from './services/parameter-store'

const parameterStoreService = new ParameterStoreService();

export const handler: Handler = async (
    event: any,
    context: Context
) => {
    console.log('Event:', JSON.stringify(event, null, 2));

    try {

        const parameterName = process.env.PERMITTED_RUNTIMES_PARAM;

        if (!parameterName) {
            throw new Error('Permitted Runtimes Parameter is not set');
        }

        const resourceProperties = event.requestData.targetModel.resourceProperties;

        // Check if this is a Lambda function resource
        if (event.requestData.targetType !== 'AWS::Lambda::Function') {
            console.error("Resource is not a Lambda function, skipping");
            return {
                hookStatus: 'SUCCESS',
                message: 'Not a Lambda function resource, skipping validation',
                clientRequestToken: event.clientRequestToken
            };
        }

        // Check runtime version compliance
        const runtime = resourceProperties.Runtime;
        if (!runtime) {
            console.error("Runtime not defined, failing");
            return {
                hookStatus: 'FAILURE',
                errorCode: 'NonCompliant',
                message: 'Runtime is required for Lambda functions',
                clientRequestToken: event.clientRequestToken
            };
        }



        // Retrieve configuration from Parameter Store
        const compliantRuntimes = await parameterStoreService.getParameterFromStore(parameterName);

        // Check if Lambda runtime is permitted or not
        if (!compliantRuntimes.includes(runtime)) {
            console.error("Runtime " + runtime + " not compliant ");
            return {
                hookStatus: 'FAILURE',
                errorCode: 'NonCompliant',
                message: `Runtime ${runtime} is not compliant. Please use one of: ${compliantRuntimes.join(', ')}`,
                clientRequestToken: event.clientRequestToken
            };
        }

        console.log('Runtime is compliant, deployment can proceed');

        return {
            hookStatus: 'SUCCESS',
            message: 'Runtime version compliance check passed',
            clientRequestToken: event.clientRequestToken
        };

    } catch (error) {
        console.error('Error:', error);
        return {
            hookStatus: 'FAILURE',
            errorCode: 'InternalFailure',
            message: 'Error during validation: ' + (error as Error).message,
            clientRequestToken: event.clientRequestToken
        };
    }
};