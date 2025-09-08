const https = require('https');

/**
 * VPC Connectivity Test Lambda Function
 *
 * This function demonstrates that a Lambda function deployed in a VPC can still
 * access external APIs and services over the internet. It queries an external
 * API to verify VPC configuration, NAT Gateway setup, and security group rules.
 */
module.exports.handler = async (event) => {
  const version = process.env.AWS_LAMBDA_FUNCTION_VERSION;
  const startTime = Date.now();

  console.log('VPC Connectivity Test - Lambda version:', version);
  console.log('Event:', JSON.stringify(event, null, 2));

  try {
    // Query an external API to demonstrate internet connectivity from VPC
    const externalData = await queryExternalAPI();
    const executionTime = Date.now() - startTime;

    const response = {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'X-Lambda-Version': version,
        'X-Execution-Time': `${executionTime}ms`
      },
      body: JSON.stringify({
        message: 'VPC Connectivity Test: Lambda successfully accessed external API from VPC',
        test: 'VPC Internet Connectivity',
        status: 'PASSED',
        lambdaVersion: version,
        executionTime: `${executionTime}ms`,
        externalAPI: {
          status: 'success',
          data: externalData
        },
        timestamp: new Date().toISOString(),
        environment: {
          region: process.env.AWS_REGION,
          functionName: process.env.AWS_LAMBDA_FUNCTION_NAME,
          memorySize: process.env.AWS_LAMBDA_FUNCTION_MEMORY_SIZE
        }
      })
    };

    console.log('Response:', JSON.stringify(response, null, 2));
    return response;

  } catch (error) {
    console.error('Error:', error);

    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'X-Lambda-Version': version
      },
      body: JSON.stringify({
        message: 'VPC Connectivity Test: Failed to access external API',
        test: 'VPC Internet Connectivity',
        status: 'FAILED',
        lambdaVersion: version,
        error: error.message,
        timestamp: new Date().toISOString()
      })
    };
  }
};

// Helper function to query external API
function queryExternalAPI() {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'httpbin.org',
      port: 443,
      path: '/json',
      method: 'GET',
      timeout: 5000
    };

    const req = https.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const jsonData = JSON.parse(data);
          resolve({
            url: `https://${options.hostname}${options.path}`,
            statusCode: res.statusCode,
            response: jsonData
          });
        } catch (parseError) {
          resolve({
            url: `https://${options.hostname}${options.path}`,
            statusCode: res.statusCode,
            response: data,
            parseError: parseError.message
          });
        }
      });
    });

    req.on('error', (error) => {
      reject(new Error(`External API request failed: ${error.message}`));
    });

    req.on('timeout', () => {
      req.destroy();
      reject(new Error('External API request timed out'));
    });

    req.end();
  });
}
