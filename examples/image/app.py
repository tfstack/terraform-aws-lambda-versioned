import os
import json

def handler(event, context):
    version = os.environ.get("AWS_LAMBDA_FUNCTION_VERSION", "$LATEST")
    print(f"Lambda version: {version}")

    return {
        "statusCode": 200,
        "body": json.dumps({ "version": version })
    }
