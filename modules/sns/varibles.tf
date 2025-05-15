variable "topic_name" {
  type        = string
  description = "SNS Topic Name"
}

variable "subscription_email" {
  type        = string
  description = "Email address to subscribe to the SNS topic (optional)"
  default     = "balureddy112211@gmail.com"
}
