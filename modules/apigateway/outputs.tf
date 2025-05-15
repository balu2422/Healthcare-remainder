output "invoke_urls" {
  value = {
    upload        = aws_api_gateway_deployment.deployment.invoke_url
    update        = aws_api_gateway_deployment.deployment.invoke_url
    notifications = aws_api_gateway_deployment.deployment.invoke_url
  }
}
