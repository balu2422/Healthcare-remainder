module "s3" {
  source = "./modules/s3"
  bucket_name = "medical-records-bucket-health"
}

module "sns" {
  source = "./modules/sns"
  topic_name = "PatientNotificationTopic"
  subscription_email = "balureddy112211@gmail.com"
}

module "dynamodb" {
  source = "./modules/dynamodb"
  table_name = "PatientRecords"
}

module "iam" {
  source = "./modules/iam"
  lambda_role_name = "LambdaExecutionRole"
}

module "lambda" {
  source = "./modules/lambda"

  lambda_source_dir = var.lambda_source_dir
}

module "apigateway" {
  source = "./modules/apigateway"
  
  lambda_functions = {
    UploadPatientDocumentFunction = module.lambda.upload_lambda_arn
    UpdatePrescriptionFunction    = module.lambda.update_lambda_arn
    NotificationsFunction         = module.lambda.notifications_lambda_arn
  }
}
