resource "aws_lambda_function" "upload_patient_document" {
  filename         = "${path.module}/upload_patient_document.zip"
  function_name    = "UploadPatientDocumentFunction"
  role             = var.lambda_role_arn
  handler          = "UploadPatientDocumentFunction.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("${path.module}/upload_patient_document.zip")

  environment {
    variables = {
      BUCKET_NAME   = var.s3_bucket
      TABLE_NAME    = var.dynamodb_table
      TOPIC_ARN     = var.sns_topic_arn
    }
  }
}

resource "aws_lambda_function" "update_prescription" {
  filename         = "${path.module}/update_prescription.zip"
  function_name    = "UpdatePrescriptionFunction"
  role             = var.lambda_role_arn
  handler          = "UpdatePrescriptionFunction.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("${path.module}/update_prescription.zip")

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table
      TOPIC_ARN  = var.sns_topic_arn
    }
  }
}

resource "aws_lambda_function" "notifications" {
  filename         = "${path.module}/notifications.zip"
  function_name    = "NotificationsFunction"
  role             = var.lambda_role_arn
  handler          = "NotificationsFunction.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("${path.module}/notifications.zip")

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table
      TOPIC_ARN  = var.sns_topic_arn
    }
  }
}

# Zip files are assumed to be created manually or via local-exec outside TF for now
