import boto3
import os
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

bucket_name = os.environ['BUCKET_NAME']
table_name = os.environ['TABLE_NAME']
sns_topic_arn = os.environ['SNS_TOPIC_ARN']

table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")

    try:
        body = json.loads(event.get('body', '{}'))

        patient_id = body.get('patient_id')
        document_name = body.get('document_name')
        document_content = body.get('document_content')  # base64 or plain string

        if not patient_id or not document_name or not document_content:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing patient_id or document info"})
            }

        # Upload to S3
        s3.put_object(
            Bucket=bucket_name,
            Key=f"{patient_id}/{document_name}",
            Body=document_content
        )

        # Update DynamoDB
        table.put_item(
            Item={
                'patient_id': patient_id,
                'record_type': 'document',
                'document_name': document_name
            }
        )

        # ✅ Publish to SNS
        sns.publish(
            TopicArn=sns_topic_arn,
            Subject="Document Uploaded",
            Message=f"Patient {patient_id} uploaded a document: {document_name}"
        )

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Document uploaded successfully"})
        }

    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
