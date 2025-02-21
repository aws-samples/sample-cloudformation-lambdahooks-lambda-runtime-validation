// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
import { SSMClient, GetParameterCommand } from '@aws-sdk/client-ssm';

const ssmClient = new SSMClient({});

export class ParameterStoreService {
    constructor() {

    }

    async getParameterFromStore(parameterName: string): Promise<string[]> {
        try {

            const command = new GetParameterCommand({
                Name: parameterName
            });

            const response = await ssmClient.send(command);

            return response.Parameter?.Value?.split(',') || [];
        } catch (error) {
            console.error('Error retrieving compliant runtimes from Parameter Store:', error);
            throw error;
        }
    }
}
