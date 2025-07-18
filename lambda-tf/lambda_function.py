# This is the main function AWS Lambda will call when invoked.
def lambda_handler(event, context):
    return {
        'statusCode': 200,  # HTTP status code
        'body': 'Hello from Terraform Lambda!'  # Response body
    }