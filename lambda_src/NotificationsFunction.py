import boto3
import os
import json
import time
import logging
from boto3.dynamodb.conditions import Key

# Logging setup
logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

table_name = os.environ['TABLE_NAME']
topic_arn = os.environ['SNS_TOPIC_ARN']

table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    logger.info(f"Event received: {json.dumps(event)}")

    try:
        # Support both API Gateway and Console Test
        if 'queryStringParameters' in event and event['queryStringParameters']:
            patient_id = event['queryStringParameters'].get('patient_id')
        else:
            patient_id = event.get('patient_id')  # for console test

        if not patient_id:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing 'patient_id'"})
            }

        logger.info(f"Querying DynamoDB for patient_id: {patient_id}")
        response = table.query(
            KeyConditionExpression=Key('patient_id').eq(patient_id)
        )

        upcoming = []
        for item in response.get('Items', []):
            if item.get('record_type') in ['prescription_due', 'checkup_due']:
                upcoming.append({
                    'type': item['record_type'],
                    'due': item.get('due_date', 'N/A')
                })

        # Optional delay (to prevent SNS over-triggering)
        time.sleep(1)

        if upcoming:
            message = f"Upcoming reminders for patient {patient_id}: " + ", ".join(
                [f"{u['type']} due on {u['due']}" for u in upcoming]
            )
            logger.info(f"Sending SNS notification: {message}")
            sns.publish(
                TopicArn=topic_arn,
                Subject="Patient Reminders",
                Message=message
            )

        return {
            "statusCode": 200,
            "body": json.dumps({
                "patient_id": patient_id,
                "upcoming_reminders": upcoming
            })
        }

    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
