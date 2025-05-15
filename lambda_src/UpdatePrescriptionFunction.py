import boto3
import os
import json

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

table_name = os.environ['TABLE_NAME']
topic_arn = os.environ['SNS_TOPIC_ARN']

table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    try:
        # Handle API Gateway JSON body
        if 'body' in event:
            event = json.loads(event['body'])

        patient_id = event['patient_id']
        updates = []

        if 'prescription_due_date' in event:
            table.put_item(Item={
                'patient_id': patient_id,
                'record_type': 'prescription_due',
                'due_date': event['prescription_due_date']
            })
            sns.publish(
                TopicArn=topic_arn,
                Subject="Prescription Due Reminder",
                Message=f"Patient {patient_id} has a prescription due on {event['prescription_due_date']}"
            )
            updates.append("prescription_due")

        if 'checkup_due_date' in event:
            table.put_item(Item={
                'patient_id': patient_id,
                'record_type': 'checkup_due',
                'due_date': event['checkup_due_date']
            })
            sns.publish(
                TopicArn=topic_arn,
                Subject="Checkup Reminder",
                Message=f"Patient {patient_id} has a checkup due on {event['checkup_due_date']}"
            )
            updates.append("checkup_due")

        return {
            'statusCode': 200,
            'body': json.dumps({
                "message": "Updates stored and notifications sent",
                "updated": updates
            })
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                "error": str(e)
            })
        }
