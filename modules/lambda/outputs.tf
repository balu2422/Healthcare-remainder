output "upload_lambda_arn" {
value = aws_lambda_function.upload_patient_document.arn
}

output "update_lambda_arn" {
value = aws_lambda_function.update_prescription.arn
}

output "notifications_lambda_arn" {
value = aws_lambda_function.notifications.arn
}
