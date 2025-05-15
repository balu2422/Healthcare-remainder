
resource "aws_api_gateway_rest_api" "api" {
  name = "PatientManagementAPI"
}

resource "aws_api_gateway_resource" "upload" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "upload"
}

resource "aws_api_gateway_resource" "update" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "update"
}

resource "aws_api_gateway_resource" "notifications" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "notifications"
}

resource "aws_api_gateway_method" "upload_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.upload.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "update_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.update.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "notifications_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.notifications.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "upload_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.upload.id
  http_method             = aws_api_gateway_method.upload_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_functions["UploadPatientDocumentFunction"]
}

resource "aws_api_gateway_integration" "update_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.update.id
  http_method             = aws_api_gateway_method.update_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_functions["UpdatePrescriptionFunction"]
}

resource "aws_api_gateway_integration" "notifications_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.notifications.id
  http_method             = aws_api_gateway_method.notifications_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_functions["NotificationsFunction"]
}

resource "aws_lambda_permission" "upload_api" {
  statement_id  = "AllowAPIGatewayInvokeUpload"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_functions["UploadPatientDocumentFunction"]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/POST/upload"
}

resource "aws_lambda_permission" "update_api" {
  statement_id  = "AllowAPIGatewayInvokeUpdate"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_functions["UpdatePrescriptionFunction"]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/POST/update"
}

resource "aws_lambda_permission" "notifications_api" {
  statement_id  = "AllowAPIGatewayInvokeNotifications"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_functions["NotificationsFunction"]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/GET/notifications"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.upload_lambda,
    aws_api_gateway_integration.update_lambda,
    aws_api_gateway_integration.notifications_lambda,
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}

output "invoke_urls" {
  value = {
    upload        = "${aws_api_gateway_deployment.deployment.invoke_url}/upload"
    update        = "${aws_api_gateway_deployment.deployment.invoke_url}/update"
    notifications = "${aws_api_gateway_deployment.deployment.invoke_url}/notifications"
  }
}
