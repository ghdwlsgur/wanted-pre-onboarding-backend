resource "aws_sns_topic" "send-alert-message" {
  name = "send-alert-message"
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.send-alert-message.arn
  protocol  = "email"
  endpoint  = var.EMAIL
}
