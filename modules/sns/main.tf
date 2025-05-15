resource "aws_sns_topic" "topic" {
  name = var.topic_name
}

resource "aws_sns_topic_subscription" "email_subscription" {
  count     = var.subscription_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = var.subscription_email
}
