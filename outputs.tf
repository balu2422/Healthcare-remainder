output "s3_bucket" {
  value = module.s3.bucket_name
}

output "sns_topic_arn" {
  value = module.sns.topic_arn
}

output "dynamodb_table_name" {
  value = module.dynamodb.table_name
}

output "lambda_role_arn" {
  value = module.iam.lambda_role_arn
}

output "lambda_function_arns" {
  value = {
    upload   = module.lambda.upload_lambda_arn
    update   = module.lambda.update_lambda_arn
    notify   = module.lambda.notifications_lambda_arn
  }
}

output "api_gateway_invoke_urls" {
  value = module.apigateway.invoke_urls
}
